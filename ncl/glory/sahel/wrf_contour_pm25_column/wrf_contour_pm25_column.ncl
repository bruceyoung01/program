; $ID: wrf_contour_pm25_column.ncl V01 03/29/2012 09:26 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_contour_pm25_column PLOTS PM2.5 CONCENTRATION ALONG THE COLUMN.
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
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_wrf_contour_variable_pm25.ncl"


begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_wrf_contour_pm25_column_sahel_v02_smoke_dust")
   gsn_define_colormap(wks,"WhGrYeOrReVi200")

;  OPEN WRF/CHEM OUTPUT FILES
;  LIST THE NC FILES AND READ NC FILES
   wdir       = "/home/bruce/sshfs/shw/model/wrfchem34_2/WRFV3/test/em_real/wrfout_sahel_smoke_dust_v01/wrfout/"
   wfilelist  = "2008_wrfout_d01_feb"
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
   variable  = wrf_user_getvar(a, "PM2_5_DRY", 0)
   ndim      = dimsizes(variable)
   nleveln   = ndim(0)
   nlatn     = ndim(1)
   nlonn     = ndim(2)
   cpm25_monthly = new((/nlatn, nlonn/), float, bv2)

;  DO LOOP TO PLOT THE WRF/CHEM DATA
   cpm25_monthly = 0.0 
   icount = 0
   do i = 0, nwname-1
    print("START TIME : ")
    system("date")

;  READ WRF/CHEM DATA
    wf          = addfile(wdir + wname(i) + ".nc", "r")
    times       = wf->Times
    print("NOW WORKING ON : " + times)
    wpm25       = getvar(wf, "PM2_5_DRY", 0)
    wlat        = getvar(wf, "XLAT", 0)
    wlon        = getvar(wf, "XLONG", 0)
    wz          = getvar(wf, "z", 0)
;  CONVERT THE UNIT FROM ug TO mg OR g
    factor      = 10^-3
    wpm25       = wpm25*factor
;  CALCULATE THE COLUMN PM2.5 CONCENTRATION
    dimwpm25    = dimsizes(wpm25)
    nlevel      = dimwpm25(0)
    nlat        = dimwpm25(1)
    nlon        = dimwpm25(2)
    lpm25       = new((/nlevel, nlat, nlon/), float, bv2)
    wza         = new((/nlevel, nlat, nlon/), float, bv2)
    do j = 0, nlevel-1
     if (j .eq. 0) then
      wza(j, :, :) = wz(0, :, :)
     end if
     if (j .gt. 0) then
      wza(j, :, :) = wz(j, :, :)-wz(j-1, :, :)
     end if
    end do
    cpm25       = new((/nlat, nlon/), float, bv2)
    lpm25       = wpm25*wza
    cpm25       = dim_sum_n(lpm25, 0)
    print(max(cpm25))
    cpm25@lat2d = wlat
    cpm25@lon2d = wlon
;  CALL SUBROUTINE plot_wrf_contour_variable_pm25 TO PLOT CONTOUR
    plot_wrf_contour_variable_pm25 \
    (wks, minlat, maxlat, minlon, maxlon, cpm25, times)
    icount = icount + 1
    cpm25_monthly = cpm25_monthly + cpm25
   end do
    cpm25_monthly = cpm25_monthly/icount
    cpm25_monthly@lat2d = wlat
    cpm25_monthly@lon2d = wlon
;  CALL SUBROUTINE plot_wrf_contour_variable_pm25 TO PLOT CONTOUR
   plot_wrf_contour_variable_pm25 \
   (wks, minlat, maxlat, minlon, maxlon, cpm25_monthly, times(0, 0:6))

end
