;  $ID: wrf_profile_h_pm25.ncl V01 10/24/2012 23:06 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_profile_h_pm25 READS WRF OUTPUT DATA AND SELECTS ONE GRID BOX 
;  , AND INTERPOLATE THE VERTICLE LEVEL, AND TO PLOT ITS VERTICLE PROFILE.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (10/24/2012)
;******************************************************************************
; LOAD LIBRARIES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ca_2003/wrf_contour_h/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/Oklahoma_Matthew/plot_wrf_profile_pm25.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_wrf_profile_h_pm25_oklahoma_v01")
   
;  OPEN WRF/CHEM OUTPUT FILES
;  LIST THE NC FILES AND READ NC FILES
   wdir       = "/home/bruce/sshfs/tw/parallel/data/wrf_output/wrfout_atlanta_36_12_4/wrfout/"
   wfilelist  = "2012_wrfout_d01_select"
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

;  SITE LOCATION
   sitelat    = (/36.63/)
   sitelon    = (/-97.48/)
   range      = 0.5
   striderange= 0.01
;  DECLARE THE INDEX ARRAY
   index      = new((/4/), integer)
   index      = (/1, 2, 3, 4/)

   minheight  =  0.1
   maxheight  = 19.8
   stridheight=  0.05
   n_new_layer= floattoint((maxheight-minheight)/stridheight) + 1
   nheight    = fspan(minheight, maxheight, n_new_layer)
;  DEFINE THE ARRARY WITH NEW LAYER
   nwpm25     = new((/n_new_layer, nlat, nlon/), float, bv2)
   pro_pm25   = new((/n_new_layer/), float, bv2)

;  DO DAY LOOP TO READ WRF-CHEM DATA
   do i = 0, nwname-1
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
;  FIND THE GRID BOX WHICH INCLUDES THE SELECTED SITE
;  DO THE LOOP TO FIND THE EXACT GRID BOX WHERE THE SITE IS LOCATED
    do while (index(0) .ne. index(1) .or. \
              index(2) .ne. index(3))
     index = region_ind(wlat, wlon, sitelat-range, sitelat+range, sitelon-range, sitelon+range)
     range = range - striderange
    end do
    print("Selected Grid Latitude  : " + wlat(index(0), index(2)))
    print("Selected Grid Longitude : " + wlon(index(0), index(2)))
    pro_pm25 = nwpm25(:, index(0), index(2))

;  CALL PROCEDURE plot_wrf_profile_pm25.ncl TO PLOT VERTICAL PROFILE
    plot_wrf_profile_pm25 \
    (wks, times, n_new_layer, nheight, pro_pm25)
   end do


end
