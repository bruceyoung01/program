; $ID: wrf_polymarker_ph_wind_tp_longitude_2dct.ncl V01 08/29/2012 23:22 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_polymarker_ph_wind_tp_longitude_2dct PLOTS THE CROSS SECTION OF 
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
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_wrf_polymarker_vector_ph.ncl"

begin

;  SET UP THE PLOT PLATFORM
;  type = "x11"
   type = "pdf"
;  type = "png"
   wks  = gsn_open_wks(type, "1plt_polymarker_ph_wind_tp_longitude_2dct_v03")
   gsn_define_colormap(wks,"color_map_2d_200")

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
   intpres   = 181
   pressure  = fspan(maxpres, minpres, intpres)
   pressure@units = "hPa"

;  SPECIFY THE LONGITUDE THROUGH WHICH TO PLOT CROSS SECTION
;  LONGITUDE : -5.0, 15.0, 35.0
   cross_lon = 15.0
   npts      = 6
   uvwfactor = -300.0

;  GET THE DIMENSION OF VARIABLES
   a         = addfile(dirn+namen(0) + ".nc", "r")
   variable  = wrf_user_getvar(a, "PM2_5_DRY", 0)
   ndim      = dimsizes(variable)
   nleveln   = ndim(0)
   nlatn     = ndim(1)
   nlonn     = ndim(2)

;  DEFINE NEW ARRAYS FOR PLOT
   pm25h_monthly   = new((/intpres, nlatn, nlonn/), float)
   pm25hd_monthly  = new((/intpres, nlatn, nlonn/), float)
   uh_monthly      = new((/intpres, nlatn, nlonn/), float)
   vh_monthly      = new((/intpres, nlatn, nlonn/), float)
   wh_monthly      = new((/intpres, nlatn, nlonn/), float)
   spm25h_monthly  = new((/intpres, nlatn/), float)
   spm25hd_monthly = new((/intpres, nlatn/), float)
   tpm25h_monthly  = new((/intpres, nlatn/), float)
   suh_monthly     = new((/intpres, nlatn/), float)
   svh_monthly     = new((/intpres, nlatn/), float)
   swh_monthly     = new((/intpres, nlatn/), float)
   ratio_pm        = new((/intpres, nlatn/), float)
   ratio_pm_monthly= new((/intpres, nlatn/), float)
   plot            = new(1, graphic)
   spm25h_monthly!0   = "lev"
   spm25h_monthly&lev = pressure
   spm25hd_monthly!0  = "lev"
   spm25hd_monthly&lev= pressure
   suh_monthly!0      = "lev"
   suh_monthly&lev    = pressure
   svh_monthly!0      = "lev"
   svh_monthly&lev    = pressure
   swh_monthly!0      = "lev"
   swh_monthly&lev    = pressure

;  DO THE FILE LOOP TO READ VARIABLES
   spm25h_monthly = 0.0
   spm25hd_monthly= 0.0
   suh_monthly    = 0.0
   svh_monthly    = 0.0
   swh_monthly    = 0.0
   icount         = 0
   do i = 0, nfnamen-1
    system("date")

    print("NOW WORKING ON : " + daten(i) + "_" + timen(i))
    fn       = addfile(dirn+namen(i) + ".nc", "r")
    fn2      = addfile(dirn2+namen2(i) + ".nc", "r")
    pm25n    = wrf_user_getvar(fn2, "PM2_5_DRY", 0)
    pm25n1   = wrf_user_getvar(fn2, "DUST_1", 0)
    pm25n2   = wrf_user_getvar(fn2, "DUST_2", 0)
    pm25n3   = wrf_user_getvar(fn2, "DUST_3", 0)
    pm25n4   = wrf_user_getvar(fn2, "DUST_4", 0)
    pm25n5   = wrf_user_getvar(fn2, "DUST_5", 0)
    aird     = wrf_user_getvar(fn , "ALT", 0)
    pb       = wrf_user_getvar(fn, "PB", 0)
    uwind    = wrf_user_getvar(fn, "U", 0)
    vwind    = wrf_user_getvar(fn, "V", 0)
    wwind    = wrf_user_getvar(fn, "W", 0)
    latn     = wrf_user_getvar(fn, "XLAT", 0)
    lonn     = wrf_user_getvar(fn, "XLONG", 0)
    pm25nd   = (pm25n1 + pm25n2 + pm25n3 + pm25n4 + pm25n5)*aird

;  CHANGE THE WIND DIRECTION ACCORDING TO THE PLOT DIRECTION
    uwind    = -1*uwind
    vwind    = -1*vwind
;   wwind    = -1*wwind

;  OMEGA IS SIGNIFICANT SMALLER THAN V, SO WE WILL SCALE IT 
;  SO THAT SOME VERTICAL MOTION IS VISIBLE
    wavg     = avg(wwind)
    uavg     = avg(uwind)
    vavg     = avg(vwind)
    wvscale  = fabs(vavg/wavg)
    wuscale  = fabs(uavg/wavg)
    wwind    = wwind*uvwfactor

;  DEFINE A NEW ARRAY FOR VERTICAL VARAIBLE
    pm25h     = new((/intpres, nlatn, nlonn/),float, bv1)
    pm25hd    = new((/intpres, nlatn, nlonn/),float, bv1)
    uh        = new((/intpres, nlatn, nlonn/),float, bv1)
    vh        = new((/intpres, nlatn, nlonn/),float, bv1)
    wh        = new((/intpres, nlatn, nlonn/),float, bv1)
    slatn     = new((/nlatn/),float, bv1)
    slonn     = new((/nlatn/),float, bv1)
    ratio     = new((/intpres, nlatn/),float, bv1)
    spm25h    = new((/intpres, nlatn/),float, bv1)
    spm25hd   = new((/intpres, nlatn/),float, bv1)
    suh       = new((/intpres, nlatn/),float, bv1)
    svh       = new((/intpres, nlatn/),float, bv1)
    swh       = new((/intpres, nlatn/),float, bv1)
    dis       = new((/nlonn/),float, bv1)
    slonn(:)  = cross_lon

;  INTERPOLATE THE VARAIBLE TO THE VERTICAL PROFILE
    do ip = 0, intpres-1
     pm25h(ip,:,:) = wrf_user_intrp3d(pm25n, pb, "h", pressure(ip), 0., False)
     pm25hd(ip,:,:)= wrf_user_intrp3d(pm25nd, pb, "h", pressure(ip), 0., False)
     uh(ip,:,:)    = wrf_user_intrp3d(uwind(:, :, 0:nlonn-1),   pb, "h", pressure(ip), 0., False)
     vh(ip,:,:)    = wrf_user_intrp3d(vwind(:, 0:nlatn-1, :),   pb, "h", pressure(ip), 0., False)
     wh(ip,:,:)    = wrf_user_intrp3d(wwind(0:nleveln-1, :, :), pb, "h", pressure(ip), 0., False)
    end do

;  SELECT THE SAME LATITUDE GRID BOX FROM WRF-Chem
    l = 0
    do j = 0, nlatn-1
     do k = 0, nlonn-1
      dis(k) = gc_latlon(latn(j, k), lonn(j, k), latn(j, k), cross_lon, 2, 3)
     end do   
     dis_qsort  = dim_pqsort(dis, 1)
     slatn(l)     = latn(j, dis_qsort(0))
     spm25h(:, l) = pm25h(:, j, dis_qsort(0)) 
     spm25hd(:, l)= pm25hd(:, j, dis_qsort(0)) 
     suh(:, l)    = uh(:, j, dis_qsort(0))
     svh(:, l)    = vh(:, j, dis_qsort(0))
     swh(:, l)    = wh(:, j, dis_qsort(0))
     l = l + 1
    end do
    slatn_qsort = dim_pqsort(slatn, -1)
    slatn       = slatn(slatn_qsort)
    spm25h      = spm25h(:, slatn_qsort)
    spm25hd     = spm25hd(:, slatn_qsort)
    suh         = suh(:, slatn_qsort)
    svh         = svh(:, slatn_qsort)
    swh         = swh(:, slatn_qsort)
    spm25h!0    = "lev"
    spm25h&lev  = pressure
    spm25hd!0   = "lev"
    spm25hd&lev = pressure
    ratio!0     = "lev"
    ratio&lev   = pressure
    ratio_pm!0  = "lev"
    ratio_pm&lev= pressure
    suh!0       = "lev"
    suh&lev     = pressure
    svh!0       = "lev"
    svh&lev     = pressure
    swh!0       = "lev"
    swh&lev     = pressure
    spm25h_monthly = spm25h_monthly + spm25h
    spm25hd_monthly= spm25hd_monthly + spm25hd
    suh_monthly    = suh_monthly + suh
    svh_monthly    = svh_monthly + svh
    swh_monthly    = swh_monthly + swh
    icount         = icount + 1
    nselect        = num(.not.ismissing(slatn))
    ratio          = spm25hd;spm25h/(spm25h+spm25hd)

;  DEFINE 2-D ARRAY TO HOLD COORDINATES
    sslatn      = new((/nselect/), float, bv2)
    sslonn      = new((/nselect/), float, bv2)
    final_svh   = new((/intpres, nselect/), float, bv2)
    final_swh   = new((/intpres, nselect/), float, bv2)
    final_ratio = new((/intpres, nselect/), float, bv2)
    final_pm    = new((/intpres, nselect/), float, bv2)
    final_lat   = new((/intpres, nselect/), float, bv2)
    final_pres  = new((/intpres, nselect/), float, bv2)
    final_svh!0    = "lev"
    final_svh&lev  = pressure
    final_swh!0    = "lev"
    final_swh&lev  = pressure
    final_ratio!0  = "lev"
    final_ratio&lev= pressure
    final_pm!0     = "lev"
    final_pm&lev   = pressure
    final_lat!0    = "lev"
    final_lat&lev  = pressure
    final_pres!0   = "lev"
    final_pres&lev = pressure
    sslatn      = slatn(0:(nselect-1))
    sslonn      = slonn(0:(nselect-1))
    final_svh   = svh(:, 0:(nselect-1))
    final_swh   = swh(:, 0:(nselect-1))
    final_ratio = ratio(:, (nselect-1):0:1)
    final_pm    = spm25h(:, (nselect-1):0:1)
    do ilat = 0, nselect-2
     do ipre = 0, intpres-1
      final_lat(ipre, ilat)  = (/sslatn(ilat)/)
      final_pres(ipre, ilat) = (/pressure(ipre)/)
     end do
    end do

;  CALL SUBROUTINE plot_wrf_polymarker_vector_ph.ncl TO PLOT WRF CROSS SECTION
;   plot_wrf_polymarker_vector_ph \
;   (wks, nselect, npts, sslatn, sslonn, pressure, daten(i), timen(i), \
;    final_lat, final_pres, final_svh, final_swh,\
;    final_ratio, final_pm, plot)

    delete([/spm25h, spm25hd, suh, svh, swh, ratio/])
   end do

   spm25h_monthly = spm25h_monthly/icount
   spm25hd_monthly= spm25hd_monthly/icount
   suh_monthly    = suh_monthly/icount
   svh_monthly    = svh_monthly/icount
   swh_monthly    = swh_monthly/icount

;   RESET THE SMALL VALUE TO GET BETTER RATIO
;   nspm25h_monthly    = dimsizes(spm25h_monthly)
;   onedspm25h_monthly = ndtooned(spm25h_monthly)
;   onedspm25hd_monthly= ndtooned(spm25hd_monthly)
;   spm25hind_monthly  = ind_resolve(ind(onedspm25h_monthly .lt. 2.0), nspm25h_monthly)
;   spm25hdind_monthly = ind_resolve(ind(onedspm25hd_monthly .lt. 5.0), nspm25h_monthly)
;   nspm25hind_monthly = dimsizes(spm25hind_monthly)
;   spm25hpts_monthly  = nspm25hind_monthly(0)
;   ndimspm25h_monthly = nspm25hind_monthly(1)
;   do j = 0, spm25hpts_monthly-1
;    spm25h_monthly(spm25hind_monthly(j, 0), spm25hind_monthly(j, 1)) = 1000.0
;   end do

;   nspm25hdind_monthly= dimsizes(spm25hdind_monthly)
;   spm25hdpts_monthly = nspm25hdind_monthly(0)
;   ndimspm25hd_monthly= nspm25hdind_monthly(1)
;   do j = 0, spm25hdpts_monthly-1
;    spm25hd_monthly(spm25hdind_monthly(j, 0), spm25hdind_monthly(j, 1)) = 1.0
;   end do
;   delete([/spm25hind_monthly, spm25hdind_monthly/])

    tpm25h_monthly = spm25h_monthly + spm25hd_monthly
    ratio_monthly  = spm25hd_monthly;spm25h_monthly/tpm25h_monthly

    time = " "
;  OMEGA IS SIGNIFICANT SMALLER THAN V, SO WE WILL SCALE IT 
;  SO THAT SOME VERTICAL MOTION IS VISIBLE
    wavg_monthly     = avg(swh_monthly)
    uavg_monthly     = avg(suh_monthly)
    vavg_monthly     = avg(svh_monthly)
    wvscale_monthly  = fabs(vavg_monthly/wavg_monthly)
    wuscale_monthly  = fabs(uavg_monthly/wavg_monthly)
    wwind_monthly    = swh_monthly*uvwfactor
;  DEFINE 2-D ARRAY TO HOLD COORDINATES
    final_svh_monthly   = new((/intpres, nselect/), float, bv2)
    final_swh_monthly   = new((/intpres, nselect/), float, bv2)
    final_ratio_monthly = new((/intpres, nselect/), float, bv2)
    final_pm_monthly    = new((/intpres, nselect/), float, bv2)
    final_svh_monthly!0    = "lev"
    final_svh_monthly&lev  = pressure
    final_swh_monthly!0    = "lev"
    final_swh_monthly&lev  = pressure
    final_ratio_monthly!0  = "lev"
    final_ratio_monthly&lev= pressure
    final_pm_monthly!0     = "lev"
    final_pm_monthly&lev   = pressure
    final_svh_monthly   = svh_monthly(:, 0:(nselect-1))
    final_swh_monthly   = swh_monthly(:, 0:(nselect-1))
    final_ratio_monthly = (/ratio_monthly(:, (nselect-1):0:1)/)
    final_pm_monthly    = (/spm25h_monthly(:, (nselect-1):0:1)/)

;   npts = 6

;  CALL SUBROUTINE plot_wrf_polymarker_vector_ph.ncl TO PLOT WRF CROSS SECTION
   plot_wrf_polymarker_vector_ph \
   (wks, nselect, npts, \
    sslatn, sslonn, pressure, yyyymm, time, final_lat, final_pres, \
    final_svh_monthly, final_swh_monthly, final_ratio_monthly,     \
    final_pm_monthly, plot)
    delete([/spm25h_monthly, suh_monthly, svh_monthly, swh_monthly, \
             ratio_monthly/])

end
