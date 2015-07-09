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
load "/home/bruce/program/ncl/tutorial/test/wrf_contour_h/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/pro_fun.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/map.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/plot_wrf_contour_variable.ncl"


begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_wrf_contour_pm25_column_2008_0201_0229_v01_fb_ndust")

;  OPEN WRF/CHEM OUTPUT FILES
;  LIST THE NC FILES AND READ NC FILES
   wdir       = "/home/bruce/sshfs/pfw/model/wrfchem2/WRFV3/test/em_real/wrfout_sahel_650/"
   wfilelist  = "wrfout_d01_2008"
   wname      = asciiread(wdir+wfilelist, -1, "string")
   nwname     = dimsizes(wname)

;  DEFINE BAD VALUE
   bv2        = -9999.

;  RANGE OF STUDY AREA
   minlat     = -15.0
   maxlat     =  35.0
   minlon     = -25.0
   maxlon     =  45.0

;  DO LOOP TO PLOT THE WRF/CHEM DATA
   do i = 0, nwname-1
    print("START TIME : ")
    system("date")

;  READ WRF/CHEM DATA
    wf          = addfile(wdir + wname(i) + ".nc", "r")
    times       = wf->Times
    wpm25       = getvar(wf, "PM2_5_DRY", 0)
    wlat        = getvar(wf, "XLAT", 0)
    wlon        = getvar(wf, "XLONG", 0)
    wz          = getvar(wf, "z", 0)
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
;  CALL SUBROUTINE map.ncl TO PLOT MAP
    mpplot      = new(1, graphic)
    map(wks, minlat, maxlat, minlon, maxlon, mpplot)

;  CALL SUBROUTINE plot_wrf_contour_variable TO PLOT CONTOUR
    plot_wrf_contour_variable(wks, mpplot, cpm25, times)
    delete(mpplot)
   end do
end
