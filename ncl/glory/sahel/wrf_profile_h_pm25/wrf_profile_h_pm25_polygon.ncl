;  $ID: wrf_profile_h_pm25_polygon.ncl V01 10/17/2012 11:55 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_profile_h_pm25_polygon READS WRFCHEM OUTPUT, CALCULATES 
;  AREA-AVERAGED DATA AND PLOT IT AS VERTICAL PRODILE.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) 
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (10/17/2012)
;******************************************************************************

; LOAD LIBRARIES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ca_2003/wrf_contour_h/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_wrf_profile_pm25_polygon.ncl"

begin

;  OPEN A WORKSTATION AND CHOOSE COLORMAP
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_wrf_profile_h_pm25_sahel_v01")

;  OPEN WRF/CHEM OUTPUT FILES
;  LIST THE NC FILES AND READ NC FILES
   wdir       = "/home/bruce/sshfs/shw/model/wrfchem31_2/WRFV3/test/em_real/wrfout_sahel_650/"
   wfilelist  = "2008_wrfout_d01_select"
   wname      = asciiread(wdir+wfilelist, -1, "string")
   nwname     = dimsizes(wname)

;  DEFINE BAD VALUE
   bv2        = -9999.

;  GET THE DIMENSION OF WRF-CHEM DATA
   wf         = addfile(wdir + wname(0) + ".nc", "r")
   wpm25      = getvar(wf, "PM2_5_DRY", 0)
   ndim       = dimsizes(wpm25)
   nlevel     = ndim(0)
   nlat       = ndim(1)
   nlon       = ndim(2)

   minheight  =  0.1
   maxheight  = 19.8
   stridheight=  0.1
   n_new_layer= floattoint((maxheight-minheight)/stridheight) + 1
   nheight    = fspan(minheight, maxheight, n_new_layer)

;  DEFINE THE ARRARY WITH NEW LAYER
   nwpm25     = new((/n_new_layer, nlat, nlon/), float, bv2)

;  DEFINE HOURLY AND MONTHLY AREA-AVERAGED PROFILE ARRAY
   pro_pm25   = new((/n_new_layer/), float, bv2)
   pro_error  = new((/n_new_layer/), float, bv2)
   mpro_pm25  = new((/n_new_layer/), float, bv2)
   mpro_error = new((/n_new_layer/), float, bv2)

;  DO DAY LOOP TO READ WRF-CHEM DATA
   mpro_pm25  = 0.0
   mpro_error = 0.0
   icount     = 0
   do i = 0, 0;nwname-1
    print("START TIME : ")
    system("date")
    pro_pm25    = 0.0
    wf          = addfile(wdir + wname(i) + ".nc", "r")
    times       = wf->Times
    print("NOW WORKING ON : " + times)
    wpm25       = getvar(wf, "PM2_5_DRY", 0)
    waod        = getvar(wf, "TAUAER3", 0)
    wlat        = getvar(wf, "XLAT", 0)
    wlon        = getvar(wf, "XLONG", 0)
    wz          = getvar(wf, "z", 0)

;  INTERPOLATE THE OLD DATA TO NEW LAYER DATA
    do inh = 0, n_new_layer-1
     nwpm25(inh,:,:) = wrf_user_intrp3d(wpm25, wz, "h", nheight(inh)*1000, 0., False)
    end do

    taod        = dim_sum_n(waod, 0)
    onedtaod    = ndtooned(taod)
    do j = 0, n_new_layer-1
     onednwpm25  = ndtooned(nwpm25(j, :, :))
     index1      = ind(onedtaod .le. 0.3)
     if (.not. all(ismissing(index1)) .and. \
         .not. all(ismissing(onednwpm25(index1)))) then
      pro_pm25(j) = avg(onednwpm25(index1))
      pro_error(j)= stddev(onednwpm25(index1))
     end if
     delete(index1)
    end do

;  CALCULATE MONTH TOTAL DATA
   mpro_pm25  = mpro_pm25 + pro_pm25
   mpro_error = mpro_error + pro_error
   icount     = icount + 1
;  CALL PROCEDURE plot_wrf_profile_pm25_polygon.ncl TO PLOT VERTICAL PROFILE
   plot_wrf_profile_pm25_polygon \
   (wks, times, n_new_layer, nheight, pro_pm25, pro_error)
  end do

;  PLOT MONTHLY DATA
   mpro_pm25  = mpro_pm25/icount
   mpro_error = mpro_error/icount
;  CALL PROCEDURE plot_wrf_profile_pm25_polygon.ncl TO PLOT VERTICAL PROFILE
   plot_wrf_profile_pm25_polygon \
   (wks, times(0, 0:6), n_new_layer, nheight, mpro_pm25, mpro_error)

end
