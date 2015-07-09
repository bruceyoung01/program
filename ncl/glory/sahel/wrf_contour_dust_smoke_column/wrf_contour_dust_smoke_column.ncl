; $ID: wrf_contour_dust_column.ncl V01 03/29/2012 09:26 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_contour_dust_column PLOTS DUST CONCENTRATION ALONG THE COLUMN.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (03/29/2012)
;******************************************************************************

; LOAD LIBRARIES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ca_2003/wrf_contour_h/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_wrf_contour_variable_dust.ncl"


begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_wrf_contour_dust_column_sahel_v01")

;  OPEN WRF/CHEM OUTPUT FILES
;  LIST THE NC FILES AND READ NC FILES
   wdir       = "/home/bruce/sshfs/shw/data/wrf_output/wrfout_sahel_85_smoke_dust_650/"
   wfilelist  = "2008_wrfout_d01"
   wname      = asciiread(wdir+wfilelist, -1, "string")
   nwname     = dimsizes(wname)

;  DEFINE BAD VALUE
   bv2        = -9999.

;  SET UP LIMITED REGION
;                         OMALINK  NE_NEST2     NE_NEST1    NE      WA       CA     SAHEL 
   minlat     =-15.0      ;40.5    ;39.5       ; 30.0    ; 25.0   ; 30.0    ; 10    ;-15.0
   maxlat     = 35.0      ;41.5    ;42.0       ; 43.0    ; 45.0   ; 45.0    ; 45    ; 35.0
   minlon     =-25.0      ;-97.0   ;-99.0      ;-115.0   ;-115.0  ;-130.0   ;-115   ;-25.0
   maxlon     = 45.0      ;-95.5   ;-94.5      ;-93.0    ;-90.0   ;-110.0   ;-65    ; 45.0

;  GET THE DIMENSION OF VARIABLES
   a         = addfile(wdir+wname(0) + ".nc", "r")
   variable  = wrf_user_getvar(a, "DUST_1", 0)
   ndim      = dimsizes(variable)
   nleveln   = ndim(0)
   nlatn     = ndim(1)
   nlonn     = ndim(2)
   cdust_monthly = new((/nlatn, nlonn/), float, bv2)

;  DO LOOP TO PLOT THE WRF/CHEM DATA
   cdust_monthly = 0.0 
   icount = 0
   do i = 0, nwname-1
    print("START TIME : ")
    system("date")

;  READ WRF/CHEM DATA
    wf          = addfile(wdir + wname(i) + ".nc", "r")
    times       = wf->Times
    print("NOW WORKING ON : " + times)
    wdust       = getvar(wf, "DUST_1", 0)
    wlat        = getvar(wf, "XLAT", 0)
    wlon        = getvar(wf, "XLONG", 0)
    wz          = getvar(wf, "z", 0)
;  CONVERT THE UNIT FROM ug TO mg OR g
    factor      = 10^-3
    wdust       = wdust*factor
;  CALCULATE THE COLUMN DUST CONCENTRATION
    dimwdust    = dimsizes(wdust)
    nlevel      = dimwdust(0)
    nlat        = dimwdust(1)
    nlon        = dimwdust(2)
    ldust       = new((/nlevel, nlat, nlon/), float, bv2)
    wza         = new((/nlevel, nlat, nlon/), float, bv2)
    do j = 0, nlevel-1
     if (j .eq. 0) then
      wza(j, :, :) = wz(0, :, :)
     end if
     if (j .gt. 0) then
      wza(j, :, :) = wz(j, :, :)-wz(j-1, :, :)
     end if
    end do
    cdust       = new((/nlat, nlon/), float, bv2)
    ldust       = wdust*wza
    cdust       = dim_sum_n(ldust, 0)
    cdust@lat2d = wlat
    cdust@lon2d = wlon
;  CALL SUBROUTINE plot_wrf_contour_variable_dust TO PLOT CONTOUR
    plot_wrf_contour_variable_dust \
    (wks, minlat, maxlat, minlon, maxlon, cdust, times)
    icount = icount + 1
    cdust_monthly = cdust_monthly + cdust
   end do
    cdust_monthly = cdust_monthly/icount
    cdust_monthly@lat2d = wlat
    cdust_monthly@lon2d = wlon
;  CALL SUBROUTINE plot_wrf_contour_variable_dust TO PLOT CONTOUR
   plot_wrf_contour_variable_dust \
   (wks, minlat, maxlat, minlon, maxlon, cdust_monthly, times(0, 0:6))

end
