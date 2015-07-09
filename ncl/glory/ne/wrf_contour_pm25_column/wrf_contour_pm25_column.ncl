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
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/ne/plot_wrf_contour_variable_pm25.ncl"


begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_wrf_contour_pm25_column_ne_v01_d01_small")

;  OPEN WRF/CHEM OUTPUT FILES
;  LIST THE NC FILES AND READ NC FILES
   wdir       = "/home/bruce/sshfs/shw/model/wrfchem2/WRFV3/test/em_real/wrfout_ne_flambe_650/"
   wfilelist  = "2011_wrfout_d01"
   wname      = asciiread(wdir+wfilelist, -1, "string")
   nwname     = dimsizes(wname)

;  DEFINE BAD VALUE
   bv2        = -9999.

;  SET UP LIMITED REGION
;                         OMALINK  NE_NEST2     NE_NEST1    NE      WA       CA     SAHEL 
   minlat     = 32.0      ;40.5    ;39.5       ; 30.0    ; 25.0   ; 30.0    ; 10    ;-15.0
   maxlat     = 45.0      ;41.5    ;42.0       ; 43.0    ; 45.0   ; 45.0    ; 45    ; 35.0
   minlon     =-112.0     ;-97.0   ;-99.0      ;-115.0   ;-115.0  ;-130.0   ;-115   ;-25.0
   maxlon     =-90.0      ;-95.5   ;-94.5      ;-93.0    ;-90.0   ;-110.0   ;-65    ; 45.0

;  DO LOOP TO PLOT THE WRF/CHEM DATA
   do i = 0, nwname-1
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
    cpm25@lat2d = wlat
    cpm25@lon2d = wlon
;  CALL SUBROUTINE plot_wrf_contour_variable_pm25 TO PLOT CONTOUR
    plot_wrf_contour_variable_pm25 \
    (wks, minlat, maxlat, minlon, maxlon, cpm25, times)
   end do
end
