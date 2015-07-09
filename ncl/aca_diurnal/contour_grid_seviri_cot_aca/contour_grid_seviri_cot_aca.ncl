;  $ID: contour_grid_seviri_cot_aca.ncl V01 06/25/2015 16:46 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_pixel_seviri_cot_aca.ncl READS SEVIRI DATA, WHICH HAVE ONE 
;  RECORD PER 15MIN. AND GRIDS THEM INTO GRIDDED DATA, AND THEN USING CALIPSO 
;  TO SELECT SEVIRI GRIDS WITH ACA AND CLOUD TOUCHING, UNTOUCHING, AND 
;  UNCERTAIN, THEN PLOTS THEM AS CONTOUR OVER A MAP.
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
;  contour_grid_seviri_sum_aca_diff.ncl
;
;  FLOW CHART:
;  ============================================================================
;  (1 ) READ SEVIRI FILE NAME BASED ON YEAR, MONTH, DAY, HOUR, AND MIN;
;  (2 ) GRID THE PIXEL DATA TO GRIDDED DATA;
;  (3 ) READ CALIPSO LAYER PRODUCT;
;  (4 ) SELECT SEVIRI DATA WITH TOUCHING, UNTOUCHING, AND UNCERTAIN CASES;
;  (5 ) PLOT THE IMAGE FOR EVERY 15 MIN FOR VARIOUS CASES.
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/25/2015)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/gsn_csm_epa.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/grid_lat_lon.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_polyline_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_calipso_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/collect_calipso_region_dn_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/pixel_to_grid_degree.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_aca_aba_cloud_cta.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_seviri_calipso_aca_cloud_costantino2010_write.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_seviri_calipso_aca_cloud_costantino2013_write.ncl"

load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_contour_grid_landmask_seviri_aca.ncl"

begin

   print("Program Starts at " + systemfunc("date"))
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
;  type       = "pdf"
   type       = "png"
   plot_dir   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/contour_grid_seviri_cot_aca/"
   wks        = gsn_open_wks(type, plot_dir + "1plot_contour_grid_seviri_cot_aca_v01")
   gsn_define_colormap(wks,"WhBlGrYeOrReVi202")

;  DATA DIRECTORY FOR SEVIRI
   dir        = "/home/vy57456/zzbatmos_common/Data/SEVIRI/SEV_06-CLD-L2.v1.03/"
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
   bv3        = -999.999

;  SET UP LIMITED REGION
   minlat     =-30.0
   maxlat     = 10.0
   minlon     =-20.0
   maxlon     = 20.0
;  LATTITUDE AND LONGITUDE FOR STUDY REGION
   lat_pg     = (/minlat, minlat, maxlat, maxlat, minlat/)
   lon_pg     = (/minlon, maxlon, maxlon, minlon, minlon/)
;  GRID SIZE TO GRID PIXEL LEVEL DATA INTO GRIDDED LEVEL DATA
   lat_grid_size = 0.25
   lon_grid_size = 0.25

;  SET UP THE START TIME AND END TIME
   start_year = 2008
   end_year   = 2008
   start_month= 7
   end_month  = 7
   start_day  = 15
   start_hour = 0
   end_hour   = 23
   start_min  = 0
   end_min    = 45
   min_stride = 15
   start_ind_lat = 1400
   end_ind_lat   = 3000
   start_ind_lon = 1100
   end_ind_lon   = 2600

;  SELECT WHICH PARAMETER TO PLOT
   element    = "cot16"

;  WHICH PLOT IS TO BE PLOTTED
   logic_plot_daily    = True

;  SWITCH FOR BACKGROUND MAP
   switch_pg  = True
   minpixel   = 1

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

;  DEFINE ARRAY FOR GRIDDED LATITUDE AND LONGITUDE ARRAY
   nlat       = floattoint((maxlat-minlat)/lat_grid_size) + 1
   nlon       = floattoint((maxlon-minlon)/lon_grid_size) + 1
   lat_grid_1d= new((/nlat/), float, bv2)
   lon_grid_1d= new((/nlon/), float, bv2)
   lat_grid_2d= new((/nlat, nlon/), float, bv2)
   lon_grid_2d= new((/nlat, nlon/), float, bv2)

;  CALL SUBROUTINE grid_lat_lon.ncl TO GENERATE GRIDDED LATITUDE AND LONGITUDE
   grid_lat_lon \
   (minlat, maxlat, minlon, maxlon, lat_grid_size, lon_grid_size, \
    lat_grid_1d, lon_grid_1d, lat_grid_2d, lon_grid_2d)

;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  START TO PROCESS DATA
;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  DO DAY AND NIGHT LOOP
   do iday_or_night = 0, nday_or_night-1

;  DO YEAR LOOP
   do iyear = start_year, end_year

;  DO MONTH LOOP
      do imonth = start_month, end_month

;  CALCULATE THE NUMBER OF DAYS IN THIS MONTH
         nday_month = days_in_month(iyear, imonth)
;  DO DAY LOOP
         do iday = start_day, nday_month
;  FOR EVERY ITERATION, ASSUME THE FILE NAME EXISTS
            logic_sacfilename = True
            logic_sccfilename = True
            siyear  = sprinti("%0.4i", iyear)
            simonth = sprinti("%0.2i", imonth)
            siday   = sprinti("%0.2i", iday)

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

;  DO HOUR LOOP
            do ihour = start_hour, end_hour
;  DO MINUTE LOOP
               do imin = start_min, end_min, min_stride
;  SELECT HOURS DEPENDING ON DAY OR NIGHT. CONSIDERING CALIPSO PASSING TIME IS 13:30 AND 01:30,
;  IF IDAY_OR_NIGHT = 0, IT'S DAYTIME. WHILE SELECING SEVIRI DATA, WE ONLY CONSIDER 7:30~19:15;
;  IF IDAY_OR_NIGHT = 1, IT'S NIGHTTIME. WHILE SELECTING SEVIRI DATA, WE ONLY CONSIDER 19:30~7:15.
                  if (iday_or_night .eq. 0) then
                     if (ihour .gt. 19 .or. ihour .lt. 7) then
                        continue
                     else if (ihour .eq. 19 .and. imin .gt. 30) then
                        continue
                     else if (ihour .eq. 7  .and. imin .lt. 15) then
                        continue
                     end if
                     end if
                     end if
                  end if
                  if (iday_or_night .eq. 1) then
                     if (ihour .lt. 19 .or. ihour .gt. 7) then
                        continue
                     else if (ihour .eq. 19 .and. imin .lt. 30) then
                        continue
                     else if (ihour .eq. 7  .and. imin .gt. 15) then
                        continue
                     end if
                     end if
                     end if
                  end if

                  sihour  = sprinti("%0.2i", ihour)
                  simin   = sprinti("%0.2i", imin)
                  symd1   = siyear + "_" + simonth + "_" + siday
                  symd2   = siyear + "-" + simonth + "-" + siday
                  stime   = sihour + "-" + simin + "-00"
;  BUILD FILE NAME BASED ON YEAR, MONTH, DAY, HOUR, MINUTE
                  filename= "SEV_06-CLD-L2_" + symd2 + "T" + stime + "_V1-03.hdf"
;  CHECK WHETHER THE FILENAME EXISTS OR NOT
                  if (fileexists(dir + siyear + "/" + symd1 + "/" + filename)) then
                     print("Now Processing = " + filename)
;  READ VARIABLES FROM HDF FILE
                     a     = addfile(dir + siyear + "/" + symd1 + "/" + filename, "r")
                     if (.not.isdefined("lat")) then
                        lat   = (/a->MSG_Latitude(start_ind_lat:end_ind_lat, \
                                                  start_ind_lon:end_ind_lon)/)
                        lon   = (/a->MSG_Longitude(start_ind_lat:end_ind_lat,\
                                                   start_ind_lon:end_ind_lon)/)
                        lat@_FillValue = bv3
                        lon@_FillValue = bv3
                     end if
                     Cloud_Optical_Thickness_16 = a->Cloud_Optical_Thickness_16(start_ind_lat:end_ind_lat, \
                                                                                start_ind_lon:end_ind_lon)
                     cot16 = doubletofloat(Cloud_Optical_Thickness_16*Cloud_Optical_Thickness_16@scale_factor)
                     cot16@_FillValue = bv2
                     delete([/Cloud_Optical_Thickness_16/])
                     if (all(ismissing(cot16))) then
                        print("----------------------------------------------")
                        print("VARIABLES ARE ALL MISSING VALUES!!!!!!!!!")
                        continue
                     end if
                  else
                     print("-------------------------------------------------")
                     print("SEVIRI FILE DOESN'T EXIST = " + filename)
                     continue
                  end if

;  DEFINE ARRAY FOR SUBROUTINE pixel_to_grid_degree.ncl
                  cot16_grid     = new((/nlat, nlon/), float,   bv2)
                  cot16_grid_n   = new((/nlat, nlon/), integer, bv1)
                  cot16_grid_std = new((/nlat, nlon/), float,   bv2)
print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
print("Start to interpolate pixel data to gridded data")
system("date")
;  CALL SUBROUTINE pixel_to_grid_degree.ncl TO GRID THE PIXEL LEVEL DATA INTO
;  GRIDDED LEVEL DATA
                  pixel_to_grid_degree \
                  (bv1, bv2, lat_grid_2d, lon_grid_2d, lat_grid_size, lon_grid_size, \
                  lat, lon, minpixel, cot16, cot16_grid, cot16_grid_n, cot16_grid_std)
system("date")
print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")

            nelement_write            = 5
            ncount_write              = 100
            ncount_write_day          = ncount_write*nctrack
            dim_write                 = (/ncount_write, nelement_write/)
            dim_write_day             = (/nmethod, ncase, ncount_write_day, nelement_write/)
            wseviri_data_all_day      = new(dim_write_day, float, bv2)

;  READ VARIABLES FROM CAL_LID_L2_05kmALay-Prov-V3 AND CAL_LID_L2_05kmCLay-Prov-V3
            if (logic_sacfilename_region .and. logic_sccfilename_region) then
               if (nactrack_real .eq. ncctrack_real) then
;  GET CALIPSO INFO
                  a = addfile(acdir + siyear + "/" + sacfilename_region(0), "r")
                  clat                    = a->Latitude
                  ndim_clat               = dimsizes(clat)
                  npixel                  = ndim_clat(0)
;  DEFINE ARRAY TO COLLECT ALL THE LATITUDE AND LONGITUDE
                  clat_day                = new((/npixel, nactrack_real/), float, bv2)
                  clon_day                = new((/npixel, nactrack_real/), float, bv2)
;  DEFINE ARRAY TO COLLECT ALL THE SEVIRI DATA FOR ONE DAY
                  dim_day                  = (/nmethod, ncase, nactrack_real, nlat, nlon/)
                  seviri_data_all_day      = new(dim_day, float, bv2)
                  do ictrack_real = 0, nactrack_real-1
                     seviri_data_all       = new((/nlat, nlon/), float, bv2)
                     seviri_data_untouch   = new((/nlat, nlon/), float, bv2)
                     seviri_data_touch     = new((/nlat, nlon/), float, bv2)
                     seviri_data_uncertain = new((/nlat, nlon/), float, bv2)
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
                     clat_day(:, ictrack_real) = clat(:, 1)
                     clon_day(:, ictrack_real) = clon(:, 1)
                     acLayer_Base_Altitude = new((/npts/), float, bv2)
                     ccLayer_Top_Altitude  = new((/npts/), float, bv2)
;  CALL SUBROUTINE select_aca_aba_cloud_cta.ncl TO GET REAL ONE LAYER acLayer_Base_Altitude 
;  AND ccLayer_Top_Altitude
                     select_aca_aba_cloud_cta \
                     (aLayer_Top_Altitude, aLayer_Base_Altitude, aNumber_Layers_Found, \
                      cLayer_Top_Altitude, cLayer_Top_Pressure,  cNumber_Layers_Found, \
                      acLayer_Base_Altitude, ccLayer_Top_Altitude)

;  CHANGE MISSING VALUE TO bv2
                     clat@_FillValue       = bv2
                     clon@_FillValue       = bv2
                     wseviri_data_all      = new(dim_write, float, bv2)
                     wseviri_data_untouch  = new(dim_write, float, bv2)
                     wseviri_data_touch    = new(dim_write, float, bv2)
;  CALL SUBROUTINE select_seviri_calipso_aca_cloud_costantino2010_write.ncl TO DISTINGUISH 
;  ACA AND CLOUD AS TOUCH AND UNTOUCH
                     select_seviri_calipso_aca_cloud_costantino2010_write \
                     (clat, clon, lat_grid_1d, lon_grid_1d, lat_grid_size, lon_grid_size, \
                     minlat, maxlat, minlon, maxlon, iday_or_night, \
                     acLayer_Base_Altitude, ccLayer_Top_Altitude, cot16_grid, \
                     seviri_data_all, seviri_data_untouch, seviri_data_touch, \
                     wseviri_data_all, wseviri_data_untouch, wseviri_data_touch)
                     seviri_data_all_day(0, 0, ictrack_real, :, :) = seviri_data_all
                     seviri_data_all_day(0, 1, ictrack_real, :, :) = seviri_data_untouch
                     seviri_data_all_day(0, 2, ictrack_real, :, :) = seviri_data_touch
                     wseviri_data_all_day(0, 0, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = wseviri_data_all
                     wseviri_data_all_day(0, 1, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = wseviri_data_untouch
                     wseviri_data_all_day(0, 2, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = wseviri_data_touch
                     wseviri_data_all       = new(dim_write, float, bv2)
                     wseviri_data_untouch   = new(dim_write, float, bv2)
                     wseviri_data_touch     = new(dim_write, float, bv2)
                     wseviri_data_uncertain = new(dim_write, float, bv2)
;  CALL SUBROUTINE select_seviri_calipso_aca_cloud_costantino2013_write.ncl TO DISTINGUISH 
;  ACA AND CLOUD AS TOUCH AND UNTOUCH
                     select_seviri_calipso_aca_cloud_costantino2013_write \
                     (clat, clon, lat_grid_1d, lon_grid_1d, lat_grid_size, lon_grid_size, \
                     minlat, maxlat, minlon, maxlon, iday_or_night, \
                     acLayer_Base_Altitude, ccLayer_Top_Altitude, cot16_grid, \
                     seviri_data_all, seviri_data_untouch, seviri_data_touch, seviri_data_uncertain, \
                     wseviri_data_all, wseviri_data_untouch, wseviri_data_touch, wseviri_data_uncertain)
                     seviri_data_all_day(1, 0, ictrack_real, :, :) = seviri_data_all
                     seviri_data_all_day(1, 1, ictrack_real, :, :) = seviri_data_untouch
                     seviri_data_all_day(1, 2, ictrack_real, :, :) = seviri_data_touch
                     seviri_data_all_day(1, 3, ictrack_real, :, :) = seviri_data_uncertain
                     wseviri_data_all_day(1, 0, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = wseviri_data_all
                     wseviri_data_all_day(1, 1, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = wseviri_data_untouch
                     wseviri_data_all_day(1, 2, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = wseviri_data_touch
                     wseviri_data_all_day(1, 3, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = wseviri_data_uncertain
                     delete([/clat, clon, \
                              aLayer_Top_Altitude, aLayer_Base_Altitude, aNumber_Layers_Found, \
                              cLayer_Top_Altitude, cLayer_Top_Pressure,  cNumber_Layers_Found, \
                              acLayer_Base_Altitude, ccLayer_Top_Altitude, \
                              seviri_data_all, seviri_data_untouch,        \
                              seviri_data_touch, seviri_data_uncertain,    \
                              wseviri_data_all, wseviri_data_untouch,      \
                              wseviri_data_touch, wseviri_data_uncertain/])
                  end do ;ictrack_real
                  seviri_data_all_daily       = dim_sum_n(seviri_data_all_day, 2)
               else
                  print("ERROR: CAL_LID_L2_05kmALay-Prov-V3 and CAL_LID_L2_05kmCLay-Prov-V3 don't match")
               end if
            else
               print("NO CALIPSO FILE IN THE STUDY REGION ON " + stime)
            end if

;  !!!THIS PART JUST FOR WRITING FILE QUICKLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;  @@@WRITE VARIABLES INTO A FILE@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            fmt      = nelement_write + "f10.3"
            opt      = True
            do imethod = 0, nmethod-1
               do icase = 0, ncase-1
;  SWITCH FOR CALCULATING ALL CASES, UNTOUCH CASES, OR TOUCH CASES
                  opt@fout = plot_dir + case(icase) + "_" + method(imethod) + "_" + \
                             sday_or_night(iday_or_night) + "_" + symd1 + "_" + stime + ".txt"
                  write_matrix(wseviri_data_all_day(imethod, icase, :, :), fmt, opt)

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT DAILY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                  if (logic_plot_daily) then
                     stime_format         = sihour + ":" + simin + ":00"
                     sdaily               = symd2 + " " + stime_format + " " + case(icase) + " " + method(imethod)
                     seviri_element       = (/seviri_data_all_daily(imethod, icase, :, :)/)
                     seviri_element!0     = "lat"
                     seviri_element!1     = "lon"
                     seviri_element@lat2d = lat_grid_2d
                     seviri_element@lon2d = lon_grid_2d
                     if (.not.all(ismissing(seviri_element))) then
;  CALL SUBROUTINE plot_contour_grid_landmask_seviri_aca.ncl TO PLOT MONTHLY IMAGE WITH BACKGROUND MAP ON IT
                        plot_contour_grid_landmask_seviri_aca \
                        (wks, minlat, maxlat, minlon, maxlon, \
                        iday_or_night+1, element, seviri_element, sdaily)
                        if (switch_pg) then
;  CALL SUBROUTINE polygon_polyline_map.ncl TO PLOT MAP WITH POLYGON ON IT
                           polygon_polyline_map \
                           (wks, minlat, maxlat, minlon, maxlon, \
                           clat_day, clon_day, lat_pg, lon_pg)
                        end if
                     else
                        print("NO ACA IN THE STUDY REGION FOR " + sdaily)
                        continue
                     end if
                  end if
               end do ;icase
            end do ;imethod
;  !!!THIS PART JUST FOR WRITING FILE QUICKLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

                  delete([/cot16, clat_day, clon_day/])
               end do ;imin
            end do ;ihour
         end do ;iday
      end do ;imonth
   end do ;iyear
   end do ;iday_or_night
   print("Program ends at " + systemfunc("date"))
end
