; $ID: wrf_contour_pm25_column_wind.ncl V01 03/29/2012 09:26 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_contour_pm25_column_wind PLOTS PM2.5 CONCENTRATION ALONG 
;  THE COLUMN WITH WIND VECTOR OVERLAID
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (03/29/2012)
;  (2 ) MODIFIED FROM wrf_contour_pm25_column.ncl. (10/15/2012)
;******************************************************************************

; LOAD LIBRARIES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ca_2003/wrf_contour_h/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_wrf_contour_variable_pm25.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_wrf_contour_vector_pm25_column.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_wrf_contour_pm10_column_wind_sahel_v03_smoke_dust_850")
   gsn_define_colormap(wks,"WhGrYeOrReVi200")

;  OPEN WRF/CHEM OUTPUT FILES
;  LIST THE NC FILES AND READ NC FILES
   wdir       = "/home/bruce/sshfs/shw/data/wrf_output/wrfout_sahel_85_smoke_dust_650/wrfout/"
   wfilelist  = "2008_wrfout_d01"
   wname      = asciiread(wdir+wfilelist, -1, "string")
   nwname     = dimsizes(wname)

;  DEFINE BAD VALUE
   bv2        = -9999.

;  SET UP LIMITED REGION
;                         SAHEL 
   minlat     =-15.0      ;-15.0
   maxlat     = 35.0      ; 35.0
   minlon     =-25.0      ;-25.0
   maxlon     = 45.0      ; 45.0

;  SPECIFY DIFFERENT LEVEL WITH PRESSURE
   level     = 850
   plot      = new(1, graphic)

;  GET THE DIMENSION OF VARIABLES
   a         = addfile(wdir+wname(0) + ".nc", "r")
   variable  = wrf_user_getvar(a, "PM10", 0)
   ndim      = dimsizes(variable)
   nleveln   = ndim(0)
   nlatn     = ndim(1)
   nlonn     = ndim(2)
   u_monthly     = new((/nlatn, nlonn/), float, bv2)
   v_monthly     = new((/nlatn, nlonn/), float, bv2)
   cpm25_monthly = new((/nlatn, nlonn/), float, bv2)


;  DO LOOP TO PLOT THE WRF/CHEM DATA
   u_monthly     = 0.0
   v_monthly     = 0.0
   cpm25_monthly = 0.0 
   icount = 0
   do i = 0, nwname-1
    print("START TIME : ")
    system("date")
;  READ WRF/CHEM DATA
    wf          = addfile(wdir + wname(i) + ".nc", "r")
    times       = wf->Times
    print("NOW WORKING ON : " + times)
    wpm251      = getvar(wf, "PM10", 0)
    wpm252      = getvar(wf, "PM2_5_DRY", 0)
    wpm25       = wpm251 + wpm252
    wlat        = getvar(wf, "XLAT", 0)
    wlon        = getvar(wf, "XLONG", 0)
    wz          = getvar(wf, "z", 0)
    wp          = wrf_user_getvar(wf, "pressure", 0)
    u           = wrf_user_getvar(wf, "ua", 0)
    v           = wrf_user_getvar(wf, "va", 0)
    wpm25@lat2d = wf->XLAT(0,:,:)
    wpm25@lon2d = wf->XLONG(0,:,:)
    u@lat2d     = wf->XLAT(0,:,:)
    u@lon2d     = wf->XLONG(0,:,:)
    v@lat2d     = wf->XLAT(0,:,:)
    v@lon2d     = wf->XLONG(0,:,:)

;  INTERPOLATE HEIGHT AND WIND INTO THE SPECIFIC PRESSURE LEVEL
    z_plane     = wrf_user_intrp3d(wz, wp, "h", level, 0., False)
printVarSummary(z_plane)
    u_plane     = wrf_user_intrp3d(u,  wp, "h", level, 0., False)
    v_plane     = wrf_user_intrp3d(v,  wp, "h", level, 0., False)
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

; CALL SUBROUTINE plot_wrf_contour_vector_pm25_column TO PLOT CONTOUR AND WIND VECTOR
    plot_wrf_contour_vector_pm25_column \
             (wks, minlat, maxlat, minlon, maxlon, times,\
              u_plane, v_plane, cpm25, \
              plot)
    icount = icount + 1
    u_monthly     = u_monthly + u_plane
    v_monthly     = v_monthly + v_plane
    cpm25_monthly = cpm25_monthly + cpm25
   end do
    u_monthly     = u_monthly/icount
    v_monthly     = v_monthly/icount
    cpm25_monthly = cpm25_monthly/icount
    u_monthly@lat2d     = wlat
    u_monthly@lon2d     = wlon
    v_monthly@lat2d     = wlat
    v_monthly@lon2d     = wlon
    cpm25_monthly@lat2d = wlat
    cpm25_monthly@lon2d = wlon
;  CALL SUBROUTINE plot_wrf_contour_variable_pm25 TO PLOT CONTOUR
   plot_wrf_contour_variable_pm25 \
   (wks, minlat, maxlat, minlon, maxlon, cpm25_monthly, times(0, 0:6))

; CALL SUBROUTINE plot_wrf_contour_vector_pm25_column TO PLOT CONTOUR AND WIND VECTOR
    plot_wrf_contour_vector_pm25_column \
             (wks, minlat, maxlat, minlon, maxlon, times(0, 0:6),\
              u_monthly, v_monthly, cpm25_monthly, \
              plot)

end
