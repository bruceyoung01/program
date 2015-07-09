; $ID: wrf_contour_ph_wind_tp.ncl V01 08/29/2012 23:22 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_contour_ph_wind_tp PLOTS THE CROSS SECTION OF WRFCHEM OUTPUT AND 
;  WIND ALONG TWO POINTS ON THE MAP.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/29/2012)
;******************************************************************************

;  LOAD LIBRARIES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/universal/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_wrf_contour_vector_ph.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_wrf_contour_vector_ph_monthly.ncl"

begin

;  SET UP THE PLOT PLATFORM
   type = "x11"
;  type = "pdf"
;  type = "png"
   wks  = gsn_open_wks(type, "1plt_contour_ph_wind_tp_sahel_we_v01")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  ASSIGNMENT CONSTANT AND ABBRAVIATION
   bv1       = -9999. 
   bv2       = -9999
   nfv       = "No_FillValue"
   str       = "string"
   hpatopa   = 100.

;  READ WRFCHEM OUTPUT NC FILE
;  THIS NEEDS TO HAVE A ".nc" APPENDED
   dirn      = "/home/bruce/sshfs/shw/model/wrfchem2/WRFV3/test/em_real/wrfout_sahel_650/"
   filelistn = "wrfout_d01_2008"
   namen     = asciiread(dirn+filelistn, -1, str)
   nfnamen   = dimsizes(namen)
   daten     = new((/nfnamen/), string, nfv)
   timen     = new((/nfnamen/), string, nfv)

;  READ OUT DATE AND TIME OF WRFCHEM INTO AN ARRARY
   do i = 0, nfnamen-1
    daten(i) = str_get_cols(namen(i), 11, 20)
    timen(i) = str_get_cols(namen(i), 22, 23)
   end do
   yyyymm    = str_get_cols(namen(0), 11, 17)

;  DEFINE THE PRESSURE LEVELS
;  MINIMUM PRESSURE, MAXIMUM PRESSURE, INTERVAL
   minpres   = 105.
   maxpres   = 1000.
   deltapres = -5.0
   intpres   = 180
   pressure  = fspan(maxpres, minpres, intpres)
   pressure@units = "hPa"

;  SPECIFY DIRECTION AND SELECTED POINT
;  FOR SAHEL CASE, THE SELECTED POINTS LISTED BELOW
;  sn : 30, 55, 70
;  we : 20, 30, 45
   wesn      = "we"
   np        = 20
   npts      = 6

;  GET THE DIMENSION OF VARIABLES
   a         = addfile(dirn+namen(0), "r")
   variable  = wrf_user_getvar(a, "PM2_5_DRY", 0)
   ndim      = dimsizes(variable)
   nleveln   = ndim(0)
   nlatn     = ndim(1)
   nlonn     = ndim(2)

;  DEFINE NEW ARRAYS FOR PLOT
   pm25h_monthly = new((/intpres, nlatn, nlonn/), float)
   uh_monthly    = new((/intpres, nlatn, nlonn/), float)
   vh_monthly    = new((/intpres, nlatn, nlonn/), float)
   wh_monthly    = new((/intpres, nlatn, nlonn/), float)
   plot          = new(1, graphic)
   pm25h_monthly!0   = "lev"
   pm25h_monthly&lev = pressure
   uh_monthly!0      = "lev"
   uh_monthly&lev    = pressure
   vh_monthly!0      = "lev"
   vh_monthly&lev    = pressure
   wh_monthly!0      = "lev"
   wh_monthly&lev    = pressure

;  DO THE FILE LOOP TO READ VARIABLES
   pm25h_monthly = 0.0
   uh_monthly    = 0.0
   vh_monthly    = 0.0
   wh_monthly    = 0.0
   icount        = 0
   do i = 0, nfnamen-1
    print("NOW WORKING ON : " + daten(i) + "_" + timen(i))
    fn       = addfile(dirn+namen(i), "r")
    pm25n    = wrf_user_getvar(fn, "PM2_5_DRY", 0)
    pb       = wrf_user_getvar(fn, "PB", 0)
    uwind    = wrf_user_getvar(fn, "U", 0)
    vwind    = wrf_user_getvar(fn, "V", 0)
    wwind    = wrf_user_getvar(fn, "W", 0)
    latn     = wrf_user_getvar(fn, "XLAT", 0)
    lonn     = wrf_user_getvar(fn, "XLONG", 0)
    dimpm25n = dimsizes(pm25n)

;  OMEGA IS SIGNIFICANT SMALLER THAN V, SO WE WILL SCALE IT 
;  SO THAT SOME VERTICAL MOTION IS VISIBLE
    wavg     = avg(wwind)
    uavg     = avg(uwind)
    vavg     = avg(vwind)
    wvscale  = fabs(vavg/wavg)
    wuscale  = fabs(uavg/wavg)
    if (wesn .eq. "sn") then
     wwind    = wwind*wvscale/2.0
    else if (wesn .eq. "we") then
     wwind    = wwind*wuscale/2.0
    end if
    end if

;  DEFINE A NEW ARRAY FOR VERTICAL VARAIBLE
    pm25h    = new((/intpres, nlatn,nlonn/),float, bv1)
    uh       = new((/intpres, nlatn,nlonn/),float, bv1)
    vh       = new((/intpres, nlatn,nlonn/),float, bv1)
    wh       = new((/intpres, nlatn,nlonn/),float, bv1)
    pm25h!0  = "lev"
    pm25h&lev= pressure
    uh!0     = "lev"
    uh&lev   = pressure
    vh!0     = "lev"
    vh&lev   = pressure
    wh!0     = "lev"
    wh&lev   = pressure

;  INTERPOLATE THE VARAIBLE TO THE VERTICAL PROFILE
    do ip = 0, intpres-1
     pm25h(ip,:,:) = wrf_user_intrp3d(pm25n, pb, "h", pressure(ip), 0., False)
     uh(ip,:,:)    = wrf_user_intrp3d(uwind(:, :, 0:nlonn-1),   pb, "h", pressure(ip), 0., False)
     vh(ip,:,:)    = wrf_user_intrp3d(vwind(:, 0:nlatn-1, :),   pb, "h", pressure(ip), 0., False)
     wh(ip,:,:)    = wrf_user_intrp3d(wwind(0:nleveln-1, :, :), pb, "h", pressure(ip), 0., False)
    end do
    pm25h_monthly = pm25h_monthly + pm25h
    uh_monthly    = uh_monthly + uh
    vh_monthly    = vh_monthly + vh
    wh_monthly    = wh_monthly + wh
    icount        = icount + 1

    if (wesn .eq. "sn") then
     ; CALL SUBROUTINE plot_wrf_contour_vector_ph.ncl TO PLOT WRF CROSS SECTION
     plot_wrf_contour_vector_ph \
     (wks, nlatn, npts, latn(:, np), lonn(:, np), \
      daten(i), timen(i), vh(:, :, np), wh(:, :, np), pm25h(:, :, np), plot)
    else if (wesn .eq. "we") then
     ; CALL SUBROUTINE plot_wrf_contour_vector_ph.ncl TO PLOT WRF CROSS SECTION
     plot_wrf_contour_vector_ph \
     (wks, nlonn, npts, latn(np, :), lonn(np, :), \
      daten(i), timen(i), uh(:, np, :), wh(:, np, :), pm25h(:, np, :), plot)
    end if
    end if

   end do

   pm25h_monthly = pm25h_monthly/icount
   uh_monthly    = uh_monthly/icount
   vh_monthly    = vh_monthly/icount
   wh_monthly    = wh_monthly/icount
   if (wesn .eq. "sn") then
    ; CALL SUBROUTINE plot_wrf_contour_vector_ph_monthly.ncl TO PLOT WRF CROSS SECTION
    plot_wrf_contour_vector_ph_monthly \
    (wks, nlatn, npts, latn(:, np), lonn(:, np), \
     yyyymm, vh_monthly(:, :, np), wh_monthly(:, :, np),\
     pm25h_monthly(:, :, np), plot)
   else if (wesn .eq. "we") then
    ; CALL SUBROUTINE plot_wrf_contour_vector_ph_monthly.ncl TO PLOT WRF CROSS SECTION
    plot_wrf_contour_vector_ph_monthly \
    (wks, nlonn, npts, latn(np, :), lonn(np, :), \
     yyyymm, uh_monthly(:, np, :), wh_monthly(:, np, :),\
     pm25h_monthly(:, np, :), plot)
   end if
   end if

end
