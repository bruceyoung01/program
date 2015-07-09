; $ID: contour_grid_amsre_sum_aca.ncl V01 06/10/2015 08:19 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_grid_amsre_sum_aca READS AMSR-E DATA, PLOTS AS CONTOUR WITH 
;  RASTERFILL, WITH FILTERING OF ACA AND CLOUD RELATIVE VERTICAL POSITION, 
;  WHICH INCLUDES TOUCH AND UNTOUCH.
;  L : DISTANCE BETWEEN CLOUD TOP ALTITUDE AND AEROSOL BASE ALTITUDE.
;  (a ) touch : L<100m;
;  (b ) uncertain : 100m<L<750m;
;  (c ) untouch : L>750m.
;  THE DISTINGUISHING METHOD USED HERE IS FROM THE FOLLOWING REFERENCES:
;  (1 ) Costantino, L. and Bréon, F.-M.: Aerosol indirect effect on warm clouds 
;       over South-East Atlantic, from co-located MODIS and CALIPSO observations, 
;       Atmos. Chem. Phys., 13, 69-88, doi:10.5194/acp-13-69-2013, 2013.
;
;  HOWEVER, IN THE PAPER OF (Costantino, 2010, GRL), THE METHOD IS:
;  (a ) touch : L<250m;
;  (b ) untouch : L>250m.
;  REFERENCE:
;  (1 ) Costantino, L. and Br ́ on, F.-M.: Analysis of aerosol-cloud interaction 
;       from multi-sensor satellite observations, Geophys. Res. Lett., 37, 
;       L11801, doi:10.1029/2009GL041828, 2010.
;
;  HERE WE EMPLOY TWO METHODS, BUT NO COMPARISION. FOR THE COMPARISION OF 
;  DIFFERENCE BETWEEN THESE TWO METHODS, PLEASE REFER TO ANOTHER PROGRAM NAMED:
;  contour_grid_amsre_sum_aca_diff.ncl
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/10/2015)
;  (2 ) HERE WE ONLY CONSIDER THE CASES THAT HAVE ONLY TWO LAYERS, ONE IS 
;       AEROSOL AND THE OTHER IS CLOUD.
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/gsn_csm_epa.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_calipso_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/collect_calipso_region_dn_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_aca_aba_cloud_cta.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_amsre_calipso_aca_cloud_costantino2010_write.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_amsre_calipso_aca_cloud_costantino2013_write.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/convert_amsre.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_contour_grid_landmask_amsre.ncl"


begin

;  SWITCH FOR DIFFERENT CASES
;  TWO METHODS: C2010-Costantino_2010; C2013-Costantino_2013
;  FOR Costantino_2010
;  "all"     : ALL THE CASES INCLUDING ACA AND CLOUD WITH UNTOUCH AND TOUCH
;  "untouch" : UNTOUCH ACA AND CLOUD
;  "touch"   : TOUCH ACA AND CLOUD
;  FOR Costantino_2013, BESIDES FOR Costantino, ONE MORE CASE
;  "uncertain" : UNCERTAIN ABOUT WHETHER ACA AND CLOUD TOUCH OR UNTOUCH
   method        = (/"C2010", "C2013"/)
   case          = (/"all", "untouch", "touch", "uncertain"/)
   sday_or_night = (/"D", "N"/)
   nmethod       = dimsizes(method)
   ncase         = dimsizes(case)
   nday_or_night = dimsizes(sday_or_night)

;  DO method AND case LOOP TO GET ALL THE METHDS AND CASES
   do icase = 0, ncase-1
   do imethod = 0, nmethod-1

;  DO DAY AND NIGHT LOOP
   do iday_or_night = 0, nday_or_night-1

;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plot_contour_grid_amsre_sum_aca_" + \
                case(icase) + "_" + method(imethod) + "_" + sday_or_night(iday_or_night) + "_v02")
   gsn_define_colormap(wks,"WhBlGrYeOrReVi202")

;  DATA DIRECTORY FOR AMSR-E
   wdir       = "/home/vy57456/zzbatmos_common/Data/AMSRE/bmaps_v07/"
;  DATA DIRECTORY FOR CALIOP AEROSOL LAYER PRODUCTS, PRODUCT NAME IS:
;  CAL_LID_L2_05kmALay-Prov-V3
   acdir      = "/home/vy57456/zzbatmos_common/Data/CALIPSO/CAL_LID_L2_05kmALay/"
   acfilelist = "filelist_CAL_LID_L2_05kmALay-Prov-V3"
;  CAL_LID_L2_05kmCLay-Prov-V3
   ccdir      = "/home/vy57456/zzbatmos_common/Data/CALIPSO/CAL_LID_L2_05kmCLay/"
   ccfilelist = "filelist_CAL_LID_L2_05kmCLay-Prov-V3"

;  DEFINE BAD VALUE
   bv1        = -9999
   bv2        = -9999.
   ba2        =  254.

;  SET UP LIMITED REGION
   minlat     =-30.0
   maxlat     = 10.0
   minlon     =-20.0
   maxlon     = 20.0
;  LATTITUDE AND LONGITUDE FOR STUDY REGION
   lat_pg     = (/minlat, minlat, maxlat, maxlat, minlat/)
   lon_pg     = (/minlon, maxlon, maxlon, minlon, minlon/)

;  SET UP THE START TIME AND END TIME
   start_year = 2007
   end_year   = 2007
   start_month= 6
   end_month  = 8
   start_day  = 1

;  SET UP SEASONAL STRING: -DJF, -MMA, JJA, SON
   sstring    = "JJA"

;  SPECIFY ELEMENTS
;  element = 1:TIME; 2: SST; 3: WINDLF; 4: WINDHF; 5: VAPOR; 6: CLOUD; 7: RAIN RATE
   element      = 6

;  SWITCH FOR BACKGROUND MAP
   switch_pg  = True

;  WHICH PLOT IS TO BE PLOTTED
   logic_plot_daily    = True
   logic_plot_monthly  = False
   logic_plot_seasonal = False
   logic_plot_yearly   = False

;  SATELLITE NAME
   satename   = "amsre"

;  DEFINE ARRAY FOR DATA
   nelement      = 7
   nglobal_lat   = 720
   nglobal_lon   = 1440
   lat_stride    = 0.25
   lon_stride    = 0.25
   dim           = (/nday_or_night, nelement, nglobal_lat, nglobal_lon/)
   dim_element   = (/nglobal_lat, nglobal_lon/)
   amsre_data_day= new(dim, float, bv2)
   amsre_element = new(dim_element, float, bv2)

;  GENERATE GRID BOX OF LATITUDE AND LONGITUDE
   lat = new(nglobal_lat, float)
   lon = new(nglobal_lon, float)
   do iglobal_lat = 0, nglobal_lat-1
      lat(iglobal_lat) = lat_stride*(iglobal_lat+1)-90.125
   end do

   do iglobal_lon = 0, nglobal_lon-1
      lon(iglobal_lon) = lon_stride*(iglobal_lon+1)-0.125
   end do

;  SET UP XSCALE AND XOFFSET FOR AMSR-E DATA
   xscale  = (/0.1, 0.15, 0.2, 0.2, 0.3, 0.01, 0.1/)
   xoffset = (/0., -3., 0., 0., 0., -0.05, 0./)

;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  START TO PROCESS DATA:
;  READ THE FILE DEPENDING ON THE YEAR, MONTH, DAY, AND DAYTIME AND NIGHTTIME
;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  CALCULATE TOTAL DAYS FOR ALL THE YEARS DEPENDING ON
;  start_year AND end_year
;  start_month AND end_month
   tnday_year = 0
   do iiyear = start_year, end_year
      do iimonth = start_month, end_month
;  CALCULATE # OF DAYS IN THIS MONTH
         lon_year   = days_in_month(iiyear, iimonth)
         tnday_year = tnday_year + lon_year
      end do
   end do
   if (logic_plot_yearly) then
      dim_year                  = (/tnday_year, nday_or_night, nelement, nglobal_lat, nglobal_lon/)
      amsre_data_year           = new(dim_year, float, bv2)
   end if
;  DO YEAR LOOP
   iyear_loop   = 0
   tnday_season = 0
   do iyear = start_year, end_year
      if (iyear  .gt. start_year) then
          delete([/amsre_data_season/])
      end if
      do iiimonth = start_month, end_month
         tnday_season = tnday_season + lon_year
      end do
      if (logic_plot_seasonal) then
         dim_season                  = (/tnday_season, nday_or_night, nelement, nglobal_lat, nglobal_lon/)
         amsre_data_season           = new(dim_season, float, bv2)
      end if

;  DO MONTH LOOP
      imonth_loop = 0
      do imonth = start_month, end_month
         if (imonth .gt. start_month .and. \
             iyear  .gt. start_year) then
            delete([/amsre_data_month/])
         end if
;  CALCULATE # OF DAYS IN THIS MONTH
         lon_year    = days_in_month(iyear, imonth)
         tnday_month = lon_year
         if (logic_plot_monthly) then
            dim_month                  = (/tnday_month, nday_or_night, nelement, nglobal_lat, nglobal_lon/)
            amsre_data_month           = new(dim_month, float, bv2)
         end if
;  DO DAY LOOP
         iday_loop = 0
         do iday = start_day, lon_year
;  FOR EVERY ITERATION, ASSUME THE FILE NAME EXISTS
            logic_sacfilename = True
            logic_sccfilename = True
            siyear  = sprinti("%0.4i", iyear)
            simonth = sprinti("%0.2i", imonth)
            siday   = sprinti("%0.2i", iday)
            stime   = siyear + "-" + simonth + "-" + siday

;  @@@PROCESS CALIPSO DATA@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  DEFINE VARIABLES FOR SUBROUTINE select_calipso_filename.ncl
            nscfilename = 20
            sacfilename = new((/nscfilename/), string)
            sccfilename = new((/nscfilename/), string)
;  CALL SUBROUTINE select_calipso_filename.ncl TO SELECT FILE NAMES BASED ON 
;  YEAR, MONTH, AND DAY FOR CAL_LID_L2_05kmALay-Prov-V3
            select_calipso_filename \
            (acdir, acfilelist, iyear, imonth, iday, iday_or_night, \
            logic_sacfilename, sacfilename)
;  CALL SUBROUTINE select_calipso_filename.ncl TO SELECT FILE NAMES BASED ON 
;  YEAR, MONTH, AND DAY FOR CAL_LID_L2_05kmCLay-Prov-V3
            select_calipso_filename \
            (ccdir, ccfilelist, iyear, imonth, iday, iday_or_night, \
            logic_sccfilename, sccfilename)
;  CHECK FILENAMES EXIST OR NOT. IF NOT, CONTINUE TO THE NEXT DO LOOP
            if (logic_sacfilename .and. logic_sccfilename) then
;  DEFINE ARRAY TO HOLD LATITUDE AND LONGITUDE
               nctrack                  = 3
               sacfilename_region       = new((/nctrack/), string)
               sccfilename_region       = new((/nctrack/), string)
               nactrack_real            = new((/1/), integer, bv1)
               ncctrack_real            = new((/1/), integer, bv1)
               logic_sacfilename_region = False
               logic_sccfilename_region = False
;  CALL SUBROUTINE collect_calipso_region_dn_filename.ncl TO COLLECT ALL THE 
;  CALIPSO FILENAMES IN THE STUDY REGION FOR CAL_LID_L2_05kmALay-Prov-V3
               collect_calipso_region_dn_filename \
               (acdir, sacfilename, siyear, sday_or_night(iday_or_night), \
               minlat, maxlat, minlon, maxlon,                            \
               sacfilename_region, logic_sacfilename_region, nactrack_real)
;  CALL SUBROUTINE collect_calipso_region_dn_filename.ncl TO COLLECT ALL THE 
;  CALIPSO FILENAMES IN THE STUDY REGION FOR CAL_LID_L2_05kmCLay-Prov-V3
               collect_calipso_region_dn_filename \
               (ccdir, sccfilename, siyear, sday_or_night(iday_or_night), \
               minlat, maxlat, minlon, maxlon,                            \
               sccfilename_region, logic_sccfilename_region, ncctrack_real)
            else
               print("NO CALIPSO DATA ON " + stime)
               continue
            end if

;  @@@PROCESS AMSR-E DATA@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  BIULD UP DAILY FILE NAME BASED ON YEAR, MONTH, AND DAY
            sfilename = satename + "_" + siyear + simonth + siday +"v7"
            swdir     = wdir + "/y" + siyear + "/m" + simonth + "/"
;  CHECK THE EXISTANCE OF THE FILE NAME IN THE SPECIFIC DIRECTORY
;  READ VARIABLES FROM THE BINARY FILE
;           setfileoption("bin", "ReadByteOrder", "Native")
            if (fileexists(swdir + sfilename)) then
            else if (fileexists(swdir + sfilename + ".gz")) then
               system("gzip -d " + swdir + sfilename + ".gz")
            else
               continue
            end if
            end if

            print("Now Processing : " + sfilename)
            camsre_data = fbindirread(swdir + sfilename, 0, dim, "character")
;  CALL SUBROUTINE convert_amsre.ncl TO CONVERT CHARACTER TO REAL AMSR-E DATA
            convert_amsre(bv2, nday_or_night, nelement, \
                          camsre_data, xscale, xoffset, amsre_data_day)

;  CHANGE AMSR-E DATA MISSING VALUE TO bv2
            amsre_data_day@_FillValue = ba2
            amsre_data_day@_FillValue = bv2
            nelement_write            = 6
            ncount_write              = 100
            ncount_write_day          = ncount_write*nctrack
            dim_write                 = (/ncount_write, nelement_write/)
            dim_write_day             = (/ncount_write_day, nelement_write/)
            wamsre_data_all_day       = new(dim_write_day, float, bv2)
            wamsre_data_untouch_day   = new(dim_write_day, float, bv2)
            wamsre_data_touch_day     = new(dim_write_day, float, bv2)
            wamsre_data_uncertain_day = new(dim_write_day, float, bv2)
;  READ VARIABLES FROM CAL_LID_L2_05kmALay-Prov-V3 AND CAL_LID_L2_05kmCLay-Prov-V3
            if (logic_sacfilename_region .and. logic_sccfilename_region) then
               if (nactrack_real .eq. ncctrack_real) then
;  DEFINCE ARRAY TO COLLECT ALL THE AMSR-E DATA FOR ONE DAY
                  dim_day                  = (/nactrack_real, nday_or_night, nelement, nglobal_lat, nglobal_lon/)
                  amsre_data_all_day       = new(dim_day, float, bv2)
                  amsre_data_untouch_day   = new(dim_day, float, bv2)
                  amsre_data_touch_day     = new(dim_day, float, bv2)
                  amsre_data_uncertain_day = new(dim_day, float, bv2)
                  do ictrack_real = 0, nactrack_real-1
                     amsre_data_all        = new(dimsizes(amsre_data_day), float, bv2)
                     amsre_data_untouch    = new(dimsizes(amsre_data_day), float, bv2)
                     amsre_data_touch      = new(dimsizes(amsre_data_day), float, bv2)
                     amsre_data_uncertain  = new(dimsizes(amsre_data_day), float, bv2)
                     wamsre_data_all       = new(dim_write, float, bv2)
                     wamsre_data_untouch   = new(dim_write, float, bv2)
                     wamsre_data_touch     = new(dim_write, float, bv2)
                     wamsre_data_uncertain = new(dim_write, float, bv2)
                     a = addfile(acdir + siyear + "/" + sacfilename_region(ictrack_real), "r")
                     b = addfile(ccdir + siyear + "/" + sccfilename_region(ictrack_real), "r")
                     clat                  = a->Latitude
                     clon                  = a->Longitude
                     aLayer_Top_Altitude   = a->Layer_Top_Altitude
                     aLayer_Base_Altitude  = a->Layer_Base_Altitude
                     aNumber_Layers_Found  = a->Number_Layers_Found
                     cLayer_Top_Altitude   = b->Layer_Top_Altitude
                     cLayer_Top_Pressure   = b->Layer_Top_Pressure
                     cNumber_Layers_Found  = b->Number_Layers_Found
                     dim_aba               = dimsizes(aLayer_Base_Altitude)
                     npts                  = dim_aba(0)
                     acLayer_Base_Altitude = new((/npts/), float, bv2)
                     ccLayer_Top_Altitude  = new((/npts/), float, bv2)
;  CALL SUBROUTINE select_aca_aba_cloud_cta.ncl TO GET REAL ONE LAYER acLayer_Base_Altitude 
;  AND ccLayer_Top_Altitude
                     select_aca_aba_cloud_cta \
                     (aLayer_Top_Altitude, aLayer_Base_Altitude, aNumber_Layers_Found, \
                      cLayer_Top_Altitude, cLayer_Top_Pressure,  cNumber_Layers_Found, \
                      acLayer_Base_Altitude, ccLayer_Top_Altitude)

;  CHANGE MISSING VALUE TO bv2
                     clat@_FillValue                  = bv2
                     clon@_FillValue                  = bv2
                     if (method(imethod) .eq. "C2010") then
;  CALL SUBROUTINE select_amsre_calipso_aca_cloud_costantino2010_write.ncl TO DISTINGUISH 
;  ACA AND CLOUD AS TOUCH AND UNTOUCH
                        select_amsre_calipso_aca_cloud_costantino2010_write \
                        (clat, clon, lat, lon, minlat, maxlat, minlon, maxlon, iday_or_night,\
                        acLayer_Base_Altitude, ccLayer_Top_Altitude, amsre_data_day,         \
                        amsre_data_all, amsre_data_untouch, amsre_data_touch,                \
                        wamsre_data_all, wamsre_data_untouch, wamsre_data_touch)
                        amsre_data_all_day(ictrack_real, :, :, :, :)     = amsre_data_all
                        amsre_data_untouch_day(ictrack_real, :, :, :, :) = amsre_data_untouch
                        amsre_data_touch_day(ictrack_real, :, :, :, :)   = amsre_data_touch
                        wamsre_data_all_day((ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :)     = wamsre_data_all
                        wamsre_data_untouch_day((ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = wamsre_data_untouch
                        wamsre_data_touch_day((ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :)   = wamsre_data_touch
                     else if (method(imethod) .eq. "C2013") then
;  CALL SUBROUTINE select_amsre_calipso_aca_cloud_costantino2013_write.ncl TO DISTINGUISH 
;  ACA AND CLOUD AS TOUCH AND UNTOUCH
                        select_amsre_calipso_aca_cloud_costantino2013_write \
                        (clat, clon, lat, lon, minlat, maxlat, minlon, maxlon, iday_or_night,       \
                        acLayer_Base_Altitude, ccLayer_Top_Altitude, amsre_data_day,                \
                        amsre_data_all, amsre_data_untouch, amsre_data_touch, amsre_data_uncertain, \
                        wamsre_data_all, wamsre_data_untouch, wamsre_data_touch, wamsre_data_uncertain)
                        amsre_data_all_day(ictrack_real, :, :, :, :)       = amsre_data_all
                        amsre_data_untouch_day(ictrack_real, :, :, :, :)   = amsre_data_untouch
                        amsre_data_touch_day(ictrack_real, :, :, :, :)     = amsre_data_touch
                        amsre_data_uncertain_day(ictrack_real, :, :, :, :) = amsre_data_uncertain
                        wamsre_data_all_day((ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :)       = wamsre_data_all
                        wamsre_data_untouch_day((ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :)   = wamsre_data_untouch
                        wamsre_data_touch_day((ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :)     = wamsre_data_touch
                        wamsre_data_uncertain_day((ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = wamsre_data_uncertain
                     end if
                     end if
                     delete([/clat, clon, \
                              aLayer_Top_Altitude, aLayer_Base_Altitude, aNumber_Layers_Found, \
                              cLayer_Top_Altitude, cLayer_Top_Pressure,  cNumber_Layers_Found, \
                              acLayer_Base_Altitude, ccLayer_Top_Altitude,         \
                              amsre_data_all, amsre_data_untouch,                  \
                              amsre_data_touch, amsre_data_uncertain/])
                  end do

                  amsre_data_all_daily       = dim_sum_n(amsre_data_all_day, 0)
                  amsre_data_untouch_daily   = dim_sum_n(amsre_data_untouch_day, 0)
                  amsre_data_touch_daily     = dim_sum_n(amsre_data_touch_day, 0)
                  amsre_data_uncertain_daily = dim_sum_n(amsre_data_uncertain_day, 0)
                  delete([/amsre_data_all_day,       \
                           amsre_data_untouch_day,   \
                           amsre_data_touch_day,     \
                           amsre_data_uncertain_day/])
               else
                  print("ERROR: CAL_LID_L2_05kmALay-Prov-V3 and CAL_LID_L2_05kmCLay-Prov-V3 don't match")
               end if
            else
               print("NO CALIPSO FILE IN THE STUDY REGION ON " + stime)
            end if

;  !!!THIS PART JUST FOR WRITING FILE QUICKLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            if (icase .eq. 0) then
;  @@@WRITE VARIABLES INTO A FILE@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
               fmt      = nelement_write + "f10.3"
               opt      = True
               do iicase = 0, ncase-1
;  SWITCH FOR CALCULATING ALL CASES, UNTOUCH CASES, OR TOUCH CASES
                  if (iicase .eq. 0) then
                     opt@fout    = case(iicase) + "_" + method(imethod) + "_" + \
                                   sday_or_night(iday_or_night) + "_" + stime + ".txt"
                     write_matrix(wamsre_data_all_day, fmt, opt)
                  else if (iicase .eq. 1) then
                     opt@fout    = case(iicase) + "_" + method(imethod) + "_" + \
                                   sday_or_night(iday_or_night) + "_" + stime + ".txt"
                     write_matrix(wamsre_data_untouch_day, fmt, opt)
                  else if (iicase .eq. 2) then
                     opt@fout    = case(iicase) + "_" + method(imethod) + "_" + \
                                   sday_or_night(iday_or_night) + "_" + stime + ".txt"
                     write_matrix(wamsre_data_touch_day, fmt, opt)
                  else if (iicase .eq. 3) then
                     opt@fout    = case(iicase) + "_" + method(imethod) + "_" + \
                                   sday_or_night(iday_or_night) + "_" + stime + ".txt"
                     write_matrix(wamsre_data_uncertain_day, fmt, opt)
                  end if
                  end if
                  end if
                  end if
               end do ;iicase
            end if
;  !!!THIS PART JUST FOR WRITING FILE QUICKLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

;  SWITCH FOR CALCULATING ALL CASES, UNTOUCH CASES, OR TOUCH CASES
            if (icase .eq. 0) then
               amsre_data  = amsre_data_all_daily
            else if (icase .eq. 1) then
               amsre_data  = amsre_data_untouch_daily
            else if (icase .eq. 2) then
               amsre_data  = amsre_data_touch_daily
            else if (icase .eq. 3) then
               amsre_data  = amsre_data_uncertain_daily
            end if
            end if
            end if
            end if

;  ACCUMULATE ALL THE DATA FOR MONTHLY, SEASONAL, AND YEALRY CALCULATION
            if (logic_plot_monthly) then
               amsre_data_month(iday_loop, :, :, :, :)    = amsre_data
            end if
            if (logic_plot_seasonal) then
               amsre_data_season(imonth_loop, :, :, :, :) = amsre_data
            end if
            if (logic_plot_yearly) then
               amsre_data_year(iyear_loop, :, :, :, :)    = amsre_data
            end if

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT DAILY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            if (logic_plot_daily) then
               stime         = stime + " " + case(icase) + " " + method(imethod)
               amsre_element = (/amsre_data(iday_or_night, element-1, :, :)/)
;  CALL SUBROUTINE plot_contour_grid_landmask_amsre.ncl TO PLOT MONTHLY IMAGE WITH BACKGROUND MAP ON IT
               plot_contour_grid_landmask_amsre \
               (wks, minlat, maxlat, minlon, maxlon, \
               lat, lon, iday_or_night+1, element, amsre_element, stime)
            if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
               polygon_map \
               (wks, minlat, maxlat, minlon, maxlon, \
               lat_pg, lon_pg)
            end if
            end if
            iday_loop   = iday_loop   + 1
            imonth_loop = imonth_loop + 1
            iyear_loop  = iyear_loop  + 1
            delete([/amsre_data,              \
                     wamsre_data_all_day,     \
                     wamsre_data_untouch_day, \
                     wamsre_data_touch_day,   \
                     wamsre_data_uncertain_day/])
         end do ; iday

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT MONTHLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
         if (logic_plot_monthly) then
            smonthly      = siyear + "-" + simonth + " " + case(icase) + " " + method(imethod)
            amsre_element = (/dim_avg_n(amsre_data_month(:, iday_or_night, element-1, :, :), 0)/)
;  CALL SUBROUTINE plot_contour_grid_landmask_amsre.ncl TO PLOT MONTHLY IMAGE WITH BACKGROUND MAP ON IT
            plot_contour_grid_landmask_amsre \
            (wks, minlat, maxlat, minlon, maxlon, \
            lat, lon, iday_or_night+1, element, amsre_element, smonthly)
         if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
            polygon_map \
            (wks, minlat, maxlat, minlon, maxlon, \
            lat_pg, lon_pg)
         end if
         delete([/amsre_data_month/])
         end if
      end do ; imonth

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT SEASONAL IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
      if (logic_plot_seasonal) then
         sseasonal     = siyear + " " + sstring + " " + case(icase) + " " + method(imethod)
         amsre_element = (/dim_avg_n(amsre_data_season(:, iday_or_night, element-1, :, :), 0)/)
;  CALL SUBROUTINE plot_contour_grid_landmask_amsre.ncl TO PLOT MONTHLY IMAGE WITH BACKGROUND MAP ON IT
         plot_contour_grid_landmask_amsre \
         (wks, minlat, maxlat, minlon, maxlon, \
         lat, lon, iday_or_night+1, element, amsre_element, sseasonal)
      if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
         polygon_map \
         (wks, minlat, maxlat, minlon, maxlon, \
         lat_pg, lon_pg)
      end if
      delete([/amsre_data_season/])
      end if
   end do ; iyear

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT YEARLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   if (logic_plot_yearly) then
;  DO ELEMENT LOOP TO PLOT EACH ELEMENT
;  do ielement = 0, nelement-1
      syearly       = sprinti("%0.4i", start_year) + "-" + \
                      sprinti("%0.4i", end_year)   + " " + \
                      sstring + " " + case(icase) + " " + method(imethod)
      amsre_element = (/dim_avg_n(amsre_data_year(:, iday_or_night, element-1, :, :), 0)/)
;  CALL SUBROUTINE plot_contour_grid_landmask_amsre.ncl TO PLOT MONTHLY IMAGE WITH BACKGROUND MAP ON IT
      plot_contour_grid_landmask_amsre \
      (wks, minlat, maxlat, minlon, maxlon, \
      lat, lon, iday_or_night+1, element, amsre_element, syearly)
   if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
      polygon_map \
      (wks, minlat, maxlat, minlon, maxlon, \
      lat_pg, lon_pg)
   end if
   delete([/amsre_data_year/])
;  end do ;ielement
   end if
   end do ;iday_or_night
   end do ;imethod
   end do ;icase

end
