; $ID: wrf_contour_dust_column_wind_pressure.ncl V01 03/29/2012 09:26 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_contour_dust_column_wind_pressure PLOTS PM2.5 CONCENTRATION ALONG 
;  THE COLUMN WITH WIND VECTOR OVERLAID
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (03/29/2012)
;  (2 ) MODIFIED FROM wrf_contour_dust_column.ncl. (10/15/2012)
;******************************************************************************

; LOAD LIBRARIES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ca_2003/wrf_contour_h/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_wrf_contour_variable_dust.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_wrf_contour_vector_dust_column.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_wrf_contour_dust_column_wind_sahel_v05_dust_700")
   gsn_define_colormap(wks,"WhAqGrYeOrReVi200")

;  OPEN WRF/CHEM OUTPUT FILES
;  LIST THE NC FILES AND READ NC FILES
   wdir1      = "/home/bruce/sshfs/shw/data/wrf_output/wrfout_sahel_85_smoke_dust_650/wrfout/"
   wfilelist1 = "2008_wrfout_d01"
   wname1     = asciiread(wdir1+wfilelist1, -1, "string")
   nwname1    = dimsizes(wname1)
   wdir2      = "/home/bruce/sshfs/shw/data/wrf_output/wrfout_sahel_85_smoke_650/wrfout/"
   wfilelist2 = "2008_wrfout_d01"
   wname2     = asciiread(wdir2+wfilelist2, -1, "string")
   nwname2    = dimsizes(wname2)

;  DEFINE BAD VALUE
   bv2        = -9999.

;  SET UP LIMITED REGION
;                         SAHEL 
   minlat     =-15.0      ;-15.0
   maxlat     = 35.0      ; 35.0
   minlon     =-25.0      ;-25.0
   maxlon     = 45.0      ; 45.0

;  SPECIFY DIFFERENT LEVEL WITH PRESSURE
   level     = 700
   plot      = new(1, graphic)

;  GET THE DIMENSION OF VARIABLES
   a         = addfile(wdir1 + wname1(0) + ".nc", "r")
   variable  = wrf_user_getvar(a, "DUST_1", 0)
   ndim      = dimsizes(variable)
   nleveln   = ndim(0)
   nlatn     = ndim(1)
   nlonn     = ndim(2)
   u_monthly     = new((/nlatn, nlonn/), float, bv2)
   v_monthly     = new((/nlatn, nlonn/), float, bv2)
   cdust_monthly = new((/nlatn, nlonn/), float, bv2)


;  DO LOOP TO PLOT THE WRF/CHEM DATA
   u_monthly     = 0.0
   v_monthly     = 0.0
   cdust_monthly = 0.0 
   icount = 0
   do i = 0, 0;nwname-1
    print("START TIME : ")
    system("date")
;  READ WRF/CHEM DATA
    wf1         = addfile(wdir1 + wname1(i) + ".nc", "r")
    wf2         = addfile(wdir2 + wname2(i) + ".nc", "r")
    times       = wf1->Times
    print("NOW WORKING ON : " + times)
    wdust1      = getvar(wf1, "DUST_1", 0)
    wdust2      = getvar(wf1, "DUST_2", 0)
    wdust3      = getvar(wf1, "DUST_3", 0)
    wdust4      = getvar(wf1, "DUST_4", 0)
    wdust5      = getvar(wf1, "DUST_5", 0)
    aird        = getvar(wf2, "ALT",    0)
;  ORIGINALLY DUST UNIT IN nc FILE IS ug/kg-dryair
;  aird IS INVERSED DRY AIR DENSITY, WHOSE UNIT IS m3/kg
;  HERE WE USE DRY AIR DENSITY TO CONVERT ug/kg-dryair TO ug/m3
    wdust       = (wdust1 + wdust2 + wdust3 + wdust4 + wdust5)*aird
    wlat        = getvar(wf1, "XLAT", 0)
    wlon        = getvar(wf1, "XLONG", 0)
    wz          = getvar(wf1, "z", 0)
    wp          = wrf_user_getvar(wf1, "pressure", 0)
    u           = wrf_user_getvar(wf1, "ua", 0)
    v           = wrf_user_getvar(wf1, "va", 0)
    wdust@lat2d = wf1->XLAT(0,:,:)
    wdust@lon2d = wf1->XLONG(0,:,:)
    u@lat2d     = wf1->XLAT(0,:,:)
    u@lon2d     = wf1->XLONG(0,:,:)
    v@lat2d     = wf1->XLAT(0,:,:)
    v@lon2d     = wf1->XLONG(0,:,:)

;  INTERPOLATE HEIGHT AND WIND INTO THE SPECIFIC PRESSURE LEVEL
    z_plane     = wrf_user_intrp3d(wz, wp, "h", level, 0., False)
    u_plane     = wrf_user_intrp3d(u,  wp, "h", level, 0., False)
    v_plane     = wrf_user_intrp3d(v,  wp, "h", level, 0., False)
;  CONVERT THE UNIT FROM ug TO mg OR g
    factor      = 10^-3
    wdust       = wdust*factor
;  CALCULATE THE COLUMN PM2.5 CONCENTRATION
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
;   plot_wrf_contour_variable_dust \
;   (wks, minlat, maxlat, minlon, maxlon, cdust, times)

; CALL SUBROUTINE plot_wrf_contour_vector_dust_column TO PLOT CONTOUR AND WIND VECTOR
    plot_wrf_contour_vector_dust_column \
             (wks, minlat, maxlat, minlon, maxlon, times,\
              u_plane, v_plane, cdust, \
              plot)
    icount = icount + 1
    u_monthly     = u_monthly + u_plane
    v_monthly     = v_monthly + v_plane
    cdust_monthly = cdust_monthly + cdust
   end do
    u_monthly     = u_monthly/icount
    v_monthly     = v_monthly/icount
    cdust_monthly = cdust_monthly/icount
    u_monthly@lat2d     = wlat
    u_monthly@lon2d     = wlon
    v_monthly@lat2d     = wlat
    v_monthly@lon2d     = wlon
    cdust_monthly@lat2d = wlat
    cdust_monthly@lon2d = wlon
;  CALL SUBROUTINE plot_wrf_contour_variable_dust TO PLOT CONTOUR
;  plot_wrf_contour_variable_dust \
;  (wks, minlat, maxlat, minlon, maxlon, cdust_monthly, times(0, 0:6))

; CALL SUBROUTINE plot_wrf_contour_vector_dust_column TO PLOT CONTOUR AND WIND VECTOR
    plot_wrf_contour_vector_dust_column \
             (wks, minlat, maxlat, minlon, maxlon, times(0, 0:6),\
              u_monthly, v_monthly, cdust_monthly, \
              plot)

end
