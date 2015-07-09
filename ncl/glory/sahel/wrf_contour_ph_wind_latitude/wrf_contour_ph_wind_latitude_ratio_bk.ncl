; $ID: wrf_contour_ph_wind_tp_latitude_ratio.ncl V01 08/29/2012 23:22 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_contour_ph_wind_tp_latitude_ratio PLOTS THE CROSS SECTION OF 
;  WRFCHEM OUTPUT AND WIND ALONG TWO POINTS ON THE MAP.
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
;  type = "x11"
   type = "pdf"
;  type = "png"
   wks  = gsn_open_wks(type, "1plt_contour_ph_wind_tp_latitude_sahel_v03_ratio_3")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  ASSIGNMENT CONSTANT AND ABBRAVIATION
   bv1       = -9999. 
   bv2       = -9999
   nfv       = "No_FillValue"
   str       = "string"
   hpatopa   = 100.

;  READ WRFCHEM OUTPUT NC FILE
;  THIS NEEDS TO HAVE A ".nc" APPENDED
   dirn      = "/home/bruce/sshfs/shw/data/wrf_output/wrfout_sahel_85_smoke_650/wrfout/"
   filelistn = "2008_wrfout_d01_3hr"
   namen     = asciiread(dirn+filelistn, -1, str)
   nfnamen   = dimsizes(namen)
   daten     = new((/nfnamen/), string, nfv)
   timen     = new((/nfnamen/), string, nfv)

   dirn2     = "/home/bruce/sshfs/shw/data/wrf_output/wrfout_sahel_85_smoke_dust_650/wrfout/"
   filelistn2= "2008_wrfout_d01_3hr"
   namen2    = asciiread(dirn2+filelistn2, -1, str)

;  READ OUT DATE AND TIME OF WRFCHEM INTO AN ARRARY
   do i = 0, nfnamen-1
    daten(i) = str_get_cols(namen(i), 11, 20)
    timen(i) = str_get_cols(namen(i), 22, 23)
   end do
   yyyymm    = str_get_cols(namen(0), 11, 17)

;  DEFINE THE PRESSURE LEVELS
;  MINIMUM PRESSURE, MAXIMUM PRESSURE, INTERVAL
   minpres   = 100.
   maxpres   = 1000.
   deltapres = -5.0
   intpres   = 181
   pressure  = fspan(maxpres, minpres, intpres)
   pressure@units = "hPa"

;  SPECIFY THE LATITUDE THROUGH WHICH TO PLOT CROSS SECTION
;  LATITUDE : -5.0, 5.0, 15.0
   cross_lat = 15.0
   npts      = 6
   uvwfactor = 300.0

;  GET THE DIMENSION OF VARIABLES
   a         = addfile(dirn+namen(0) + ".nc", "r")
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
   spm25h_monthly= new((/intpres, nlonn/), float)
   suh_monthly   = new((/intpres, nlonn/), float)
   svh_monthly   = new((/intpres, nlonn/), float)
   swh_monthly   = new((/intpres, nlonn/), float)
   plot          = new(1, graphic)
   spm25h_monthly!0   = "lev"
   spm25h_monthly&lev = pressure
   suh_monthly!0      = "lev"
   suh_monthly&lev    = pressure
   svh_monthly!0      = "lev"
   svh_monthly&lev    = pressure
   swh_monthly!0      = "lev"
   swh_monthly&lev    = pressure

;  DO THE FILE LOOP TO READ VARIABLES
   spm25h_monthly = 0.0
   suh_monthly    = 0.0
   svh_monthly    = 0.0
   swh_monthly    = 0.0
   icount        = 0
   do i = 0, nfnamen-1
    print("NOW WORKING ON : " + daten(i) + "_" + timen(i))
    fn       = addfile(dirn+namen(i) + ".nc", "r")
    fn2      = addfile(dirn2+namen2(i) + ".nc", "r")
    pm25n    = wrf_user_getvar(fn, "PM2_5_DRY", 0)
    pm25n1   = wrf_user_getvar(fn2, "DUST_1", 0)
    pm25n2   = wrf_user_getvar(fn2, "DUST_2", 0)
    pm25n3   = wrf_user_getvar(fn2, "DUST_3", 0)
    pm25n4   = wrf_user_getvar(fn2, "DUST_4", 0)
    pm25n5   = wrf_user_getvar(fn2, "DUST_5", 0)
    pb       = wrf_user_getvar(fn, "PB", 0)
    uwind    = wrf_user_getvar(fn, "U", 0)
    vwind    = wrf_user_getvar(fn, "V", 0)
    wwind    = wrf_user_getvar(fn, "W", 0)
    latn     = wrf_user_getvar(fn, "XLAT", 0)
    lonn     = wrf_user_getvar(fn, "XLONG", 0)
    pm25nd   = pm25n1 + pm25n2 + pm25n3 + pm25n4 + pm25n5

;   RESET THE SMALL VALUE TO GET BETTER RATIO
    npm25n   = dimsizes(pm25n)
    onedpm25n= ndtooned(pm25n)
    onedpm25nd = ndtooned(pm25nd)
    pm25nind = ind_resolve(ind(onedpm25n .le. 4.0), npm25n)
    pm25ndind= ind_resolve(ind(onedpm25nd .le. 5.0), npm25n)
    npm25nind= dimsizes(pm25nind)
    pm25npts = npm25nind(0)
    ndimpm25n= npm25nind(1)
    do j = 0, pm25npts-1
     pm25n(pm25nind(j, 0), pm25nind(j, 1), pm25nind(j, 2)) = 1000.0
    end do

    npm25ndind= dimsizes(pm25ndind)
    pm25ndpts = npm25ndind(0)
    ndimpm25nd= npm25ndind(1)
    do j = 0, pm25ndpts-1
     pm25nd(pm25ndind(j, 0), pm25ndind(j, 1), pm25ndind(j, 2)) = 1.0
    end do
    delete([/pm25nind, pm25ndind/])

;   CALCULATE SMOKE/(SMOKE+DUST) RATIO
    pm25n    = pm25n/(pm25n+pm25nd)

;  OMEGA IS SIGNIFICANT SMALLER THAN V, SO WE WILL SCALE IT 
;  SO THAT SOME VERTICAL MOTION IS VISIBLE
    wavg     = avg(wwind)
    uavg     = avg(uwind)
    vavg     = avg(vwind)
    wvscale  = fabs(vavg/wavg)
    wuscale  = fabs(uavg/wavg)
    wwind    = wwind*uvwfactor

;  DEFINE A NEW ARRAY FOR VERTICAL VARAIBLE
    pm25h     = new((/intpres, nlatn,nlonn/),float, bv1)
    uh        = new((/intpres, nlatn,nlonn/),float, bv1)
    vh        = new((/intpres, nlatn,nlonn/),float, bv1)
    wh        = new((/intpres, nlatn,nlonn/),float, bv1)
    slatn     = new((/nlonn/),float, bv1)
    slonn     = new((/nlonn/),float, bv1)
    spm25h    = new((/intpres, nlonn/),float, bv1)
    suh       = new((/intpres, nlonn/),float, bv1)
    svh       = new((/intpres, nlonn/),float, bv1)
    swh       = new((/intpres, nlonn/),float, bv1)
    dis       = new((/nlatn/),float, bv1)
    slatn(:)  = cross_lat

;  INTERPOLATE THE VARAIBLE TO THE VERTICAL PROFILE
    do ip = 0, intpres-1
     pm25h(ip,:,:) = wrf_user_intrp3d(pm25n, pb, "h", pressure(ip), 0., False)
     uh(ip,:,:)    = wrf_user_intrp3d(uwind(:, :, 0:nlonn-1),   pb, "h", pressure(ip), 0., False)
     vh(ip,:,:)    = wrf_user_intrp3d(vwind(:, 0:nlatn-1, :),   pb, "h", pressure(ip), 0., False)
     wh(ip,:,:)    = wrf_user_intrp3d(wwind(0:nleveln-1, :, :), pb, "h", pressure(ip), 0., False)
    end do

;  SELECT THE SAME LATITUDE GRID BOX FROM WRF-Chem
    l = 0
    do j = 0, nlonn-1
     do k = 0, nlatn-1
      dis(k) = gc_latlon(latn(k, j), lonn(k, j), cross_lat, lonn(k, j), 2, 3)
     end do
     dis_qsort  = dim_pqsort(dis, 1)
     slonn(l)     = lonn(dis_qsort(0), j)
     spm25h(:, l) = pm25h(:, dis_qsort(0), j)
     suh(:, l)    = uh(:, dis_qsort(0), j)
     svh(:, l)    = vh(:, dis_qsort(0), j)
     swh(:, l)    = wh(:, dis_qsort(0), j)
     l = l + 1
    end do
    slonn_qsort = dim_pqsort(slonn, 1)
    slonn       = slonn(slonn_qsort)
    spm25h      = spm25h(:, slonn_qsort)
    suh         = suh(:, slonn_qsort)
    svh         = svh(:, slonn_qsort)
    swh         = swh(:, slonn_qsort)
    spm25h!0  = "lev"
    spm25h&lev= pressure
    suh!0     = "lev"
    suh&lev   = pressure
    svh!0     = "lev"
    svh&lev   = pressure
    swh!0     = "lev"
    swh&lev   = pressure
    spm25h_monthly = spm25h_monthly + spm25h
    suh_monthly    = suh_monthly + suh
    svh_monthly    = svh_monthly + svh
    swh_monthly    = swh_monthly + swh
    icount         = icount + 1
    nselect        = num(.not.ismissing(slonn))

    ; CALL SUBROUTINE plot_wrf_contour_vector_ph.ncl TO PLOT WRF CROSS SECTION
;   plot_wrf_contour_vector_ph \
;   (wks, nselect, npts, \
;    slatn((nlonn-nselect+1):(nlonn-1)), \
;    slonn((nlonn-nselect+1):(nlonn-1)), \
;    daten(i), timen(i),                 \
;    suh(:, (nlonn-nselect+1):(nlonn-1)),\
;    swh(:, (nlonn-nselect+1):(nlonn-1)),\
;    spm25h(:, (nlonn-nselect+1):(nlonn-1)), plot)

    delete([/spm25h, suh, svh, swh/])
   end do

   spm25h_monthly = spm25h_monthly/icount
   suh_monthly    = suh_monthly/icount
   svh_monthly    = svh_monthly/icount
   swh_monthly    = swh_monthly/icount
;  OMEGA IS SIGNIFICANT SMALLER THAN V, SO WE WILL SCALE IT 
;  SO THAT SOME VERTICAL MOTION IS VISIBLE
    wavg_monthly     = avg(swh_monthly)
    uavg_monthly     = avg(suh_monthly)
    vavg_monthly     = avg(svh_monthly)
    wvscale_monthly  = fabs(vavg_monthly/wavg_monthly)
    wuscale_monthly  = fabs(uavg_monthly/wavg_monthly)
    wwind_monthly    = swh_monthly*wuscale_monthly/uvwfactor

   ; CALL SUBROUTINE plot_wrf_contour_vector_ph_monthly.ncl TO PLOT WRF CROSS SECTION
   plot_wrf_contour_vector_ph_monthly \
   (wks, nselect, npts, \
    slatn((nlonn-nselect+1):(nlonn-1)), \
    slonn((nlonn-nselect+1):(nlonn-1)), \
    yyyymm, suh_monthly(:, (nlonn-nselect+1):(nlonn-1)), \
            swh_monthly(:, (nlonn-nselect+1):(nlonn-1)), \
            spm25h_monthly(:, (nlonn-nselect+1):(nlonn-1)), plot)
    delete([/spm25h_monthly, suh_monthly, svh_monthly, swh_monthly/])

end
