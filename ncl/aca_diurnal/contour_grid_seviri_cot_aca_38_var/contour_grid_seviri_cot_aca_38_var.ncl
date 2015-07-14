;  $ID: contour_grid_seviri_cot_aca_38_var.ncl V01 06/25/2015 16:46 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_pixel_seviri_cot_aca_38_var.ncl READS SEVIRI DATA, WHICH HAVE 
;  ONE RECORD PER 15MIN. AND GRIDS THEM INTO GRIDDED DATA, AND THEN USING 
;  CALIPSO TO SELECT SEVIRI GRIDS WITH ACA AND CLOUD TOUCHING, UNTOUCHING, AND 
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
;  (2 ) GRID THE PIXEL DATA TO GRIDDED DATA USING ESMF_REGRIDDING METHOD;
;  (3 ) READ CALIPSO LAYER PRODUCT;
;  (4 ) SELECT SEVIRI DATA WITH TOUCHING, UNTOUCHING, AND UNCERTAIN CASES;
;  (5 ) PLOT THE IMAGE FOR EVERY 15 MIN FOR VARIOUS CASES.
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/25/2015)
;  (2 ) IMPROVE THE GRIDDING METHOD USING ESMF_REGRIDDING. (BRUCE, 06/30/2015)
;  (3 ) MODIFIED TO WRITE MORE VARIABLES OUT TO A FILE. (BRUCE, 07/14/2015)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/gsn_csm_epa.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/grid_lat_lon.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_polyline_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_calipso_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/collect_calipso_region_dn_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/pixel_to_grid_ESMF.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_aca_aba_cloud_cta_var.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_seviri_calipso_aca_cloud_costantino2010_write_all_var.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_seviri_calipso_aca_cloud_costantino2013_write_all_var.ncl"

load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_contour_grid_landmask_seviri_aca.ncl"

begin

   print("Program Starts at " + systemfunc("date"))
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
;  type       = "pdf"
   type       = "png"
   plot_dir   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/contour_grid_seviri_cot_aca_38_var/"
   wks        = gsn_open_wks(type, plot_dir + "1plot_contour_grid_seviri_cot_aca_38_var_v01")
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
   bv2a       = -9.9
   bv2b       = -999.
   bv2c       = -249.99
   bv2d       =  127.
   bv3        = -999.999

;  SET UP LIMITED REGION
   minlat     =-20.0
   maxlat     = 00.0
   minlon     =-10.0
   maxlon     = 10.0
;  LATTITUDE AND LONGITUDE FOR STUDY REGION
   lat_pg     = (/minlat, minlat, maxlat, maxlat, minlat/)
   lon_pg     = (/minlon, maxlon, maxlon, minlon, minlon/)
;  GRID SIZE TO GRID PIXEL LEVEL DATA INTO GRIDDED LEVEL DATA
   lat_grid_size = 0.25
   lon_grid_size = 0.25

;  SET UP THE START TIME AND END TIME
   start_year = 2008
   end_year   = 2008
   start_month= 6
   end_month  = 9
   start_day  = 1
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
   element    = "cot38"

;  WHICH PLOT IS TO BE PLOTTED
   logic_plot_daily    = False

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
   case          = (/"all", "untouch", "touch", "uncertain", "noaca"/)
   sday_or_night = (/"D", "N"/)
   nmethod       = dimsizes(method)
   ncase         = dimsizes(case)
   nday_or_night = dimsizes(sday_or_night)

;  DEFINE ARRAY FOR GRIDDED LATITUDE AND LONGITUDE ARRAY
   nlat       = floattoint((maxlat-minlat)/lat_grid_size) + 2
   nlon       = floattoint((maxlon-minlon)/lon_grid_size) + 2
   dim_2d     = (/nlat, nlon/)
   lat_grid_1d= new((/nlat/), float, bv2)
   lon_grid_1d= new((/nlon/), float, bv2)
   lat_grid_2d= new(dim_2d, float, bv2)
   lon_grid_2d= new(dim_2d, float, bv2)

;  CALL SUBROUTINE grid_lat_lon.ncl TO GENERATE GRIDDED LATITUDE AND LONGITUDE
   grid_lat_lon \
   (minlat, maxlat, minlon, maxlon, lat_grid_size, lon_grid_size, \
    lat_grid_1d, lon_grid_1d, lat_grid_2d, lon_grid_2d)

;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  START TO PROCESS DATA
;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
            symd1   = siyear + "_" + simonth + "_" + siday
            symd2   = siyear + "-" + simonth + "-" + siday
;  DO DAY AND NIGHT LOOP
            do iday_or_night = 0, nday_or_night-1
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
               print("NO CALIPSO DATA ON " + symd2)
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
                     if (ihour .lt. 19 .and. ihour .gt. 7) then
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
                     Above_Cloud_Water_Vapor        = a->Above_Cloud_Water_Vapor     \
                                                         (start_ind_lat:end_ind_lat, \
                                                          start_ind_lon:end_ind_lon)
                     Cloud_Optical_Thickness_38     = a->Cloud_Optical_Thickness_38  \
                                                         (start_ind_lat:end_ind_lat, \
                                                          start_ind_lon:end_ind_lon)
                     Cloud_Optical_Thickness_38_PCL = a->Cloud_Optical_Thickness_38_PCL \
                                                         (start_ind_lat:end_ind_lat, \
                                                          start_ind_lon:end_ind_lon)
                     Cloud_Effective_Radius_38      = a->Cloud_Effective_Radius_38   \
                                                         (start_ind_lat:end_ind_lat, \
                                                          start_ind_lon:end_ind_lon)
                     Cloud_Effective_Radius_38_PCL  = a->Cloud_Effective_Radius_38_PCL \
                                                         (start_ind_lat:end_ind_lat, \
                                                          start_ind_lon:end_ind_lon)
                     Cloud_Water_Path_38            = a->Cloud_Water_Path_38         \
                                                         (start_ind_lat:end_ind_lat, \
                                                          start_ind_lon:end_ind_lon)
                     Cloud_Water_Path_38_PCL        = a->Cloud_Water_Path_38_PCL     \
                                                         (start_ind_lat:end_ind_lat, \
                                                          start_ind_lon:end_ind_lon)
                     Cloud_Phase_Optical_Properties = a->Cloud_Phase_Optical_Properties \
                                                         (start_ind_lat:end_ind_lat, \
                                                          start_ind_lon:end_ind_lon)
                     Cloud_Top_Temperature          = a->Cloud_Top_Temperature       \
                                                         (start_ind_lat:end_ind_lat, \
                                                          start_ind_lon:end_ind_lon)
                     Cloud_Top_Height               = a->Cloud_Top_Height            \
                                                         (start_ind_lat:end_ind_lat, \
                                                          start_ind_lon:end_ind_lon)
                     Cloud_Top_Pressure             = a->Cloud_Top_Pressure          \
                                                         (start_ind_lat:end_ind_lat, \
                                                          start_ind_lon:end_ind_lon)
                     Cloud_Phase_Infrared           = a->Cloud_Phase_Infrared        \
                                                         (start_ind_lat:end_ind_lat, \
                                                          start_ind_lon:end_ind_lon)
                     acwv  = doubletofloat(Above_Cloud_Water_Vapor@scale_factor*\
                             (Above_Cloud_Water_Vapor + Above_Cloud_Water_Vapor@add_offset))
                     cot38 = doubletofloat(Cloud_Optical_Thickness_38@scale_factor*\
                             (Cloud_Optical_Thickness_38 + Cloud_Optical_Thickness_38@add_offset))
                     cot38_pcl = doubletofloat(Cloud_Optical_Thickness_38_PCL@scale_factor*\
                             (Cloud_Optical_Thickness_38_PCL + Cloud_Optical_Thickness_38_PCL@add_offset))
                     cer38 = doubletofloat(Cloud_Effective_Radius_38@scale_factor*\
                             (Cloud_Effective_Radius_38 + Cloud_Effective_Radius_38@add_offset))
                     cer38_pcl = doubletofloat(Cloud_Effective_Radius_38_PCL@scale_factor*\
                             (Cloud_Effective_Radius_38_PCL + Cloud_Effective_Radius_38_PCL@add_offset))
                     cwp38 = doubletofloat(Cloud_Water_Path_38@scale_factor*\
                             (Cloud_Water_Path_38 + Cloud_Water_Path_38@add_offset))
                     cwp38_pcl = doubletofloat(Cloud_Water_Path_38_PCL@scale_factor*\
                             (Cloud_Water_Path_38_PCL + Cloud_Water_Path_38_PCL@add_offset))
                     cpop = doubletofloat(Cloud_Phase_Optical_Properties@scale_factor*\
                              (Cloud_Phase_Optical_Properties + Cloud_Phase_Optical_Properties@add_offset))
                     ctt = doubletofloat(Cloud_Top_Temperature@scale_factor*\
                             (Cloud_Top_Temperature + Cloud_Top_Temperature@add_offset))
                     cth = doubletofloat(Cloud_Top_Height@scale_factor*\
                             (Cloud_Top_Height + Cloud_Top_Height@add_offset))
                     ctp = doubletofloat(Cloud_Top_Pressure@scale_factor*\
                             (Cloud_Top_Pressure + Cloud_Top_Pressure@add_offset))
                     cpi = doubletofloat(Cloud_Phase_Infrared@scale_factor*\
                             (Cloud_Phase_Infrared + Cloud_Phase_Infrared@add_offset))

;print(cpop(0:10, 0:5))
;print(ctt(0:10, 0:5))
;print(cth(0:10, 0:5))
;print(ctp(0:10, 0:5))
;print(cpi(0:10, 0:5))
                     acwv@_FillValue      = bv2a
                     cot38@_FillValue     = bv2
                     cot38_pcl@_FillValue = bv2
                     cer38@_FillValue     = bv2
                     cer38_pcl@_FillValue = bv2
                     cwp38@_FillValue     = bv2
                     cwp38_pcl@_FillValue = bv2
                     cpop@_FillValue      = bv2a
                     ctt@_FillValue       = bv2b
                     cth@_FillValue       = bv2b
                     ctp@_FillValue       = bv2c
                     cpi@_FillValue       = bv2d
;  CHANGE FILL VALUE FOR 
;  acwv FROM bv2a TO bv2
;  ctt FROM bv2b TO bv2
;  st16 FROM bv2b TO bv2
;cpop_oned = ndtooned(cpi)
;index = ind(ismissing(cpop_oned))
;if (.not.all(ismissing(index))) then
;print("a1")
;   print(cpop_oned(index))
;end if
;print("a2")
                     acwv = where(acwv .eq. bv2a,  bv2, acwv)
                     cpop = where(ismissing(cpop), bv2, cpop)
                     ctt  = where(ctt  .eq. bv2c,  bv2,  ctt)
                     cth  = where(ismissing(cth),  bv2,  cth)
                     ctp  = where(ismissing(ctp),  bv2,  ctp)
                     cpi  = where(ismissing(cpi),  bv2,  cpi)
                     acwv@_FillValue      = bv2
                     cpop@_FillValue      = bv2
                     ctt@_FillValue       = bv2
                     cth@_FillValue       = bv2
                     ctp@_FillValue       = bv2
                     cpi@_FillValue       = bv2
                     if (all(ismissing(acwv))      .and. \
                         all(ismissing(cot38))     .and. \
                         all(ismissing(cot38_pcl)) .and. \
                         all(ismissing(cer38))     .and. \
                         all(ismissing(cer38_pcl)) .and. \
                         all(ismissing(cwp38))     .and. \
                         all(ismissing(cwp38_pcl)) .and. \
                         all(ismissing(cpop))      .and. \
                         all(ismissing(ctt))       .and. \
                         all(ismissing(cth))       .and. \
                         all(ismissing(ctp))       .and. \
                         all(ismissing(cpi))) then
                        print("----------------------------------------------")
                        print("ALL THE VARIABLES ARE MISSING VALUES!!!!!!!!!")
                        continue
                     end if
                  else
                     print("-------------------------------------------------")
                     print("SEVIRI FILE DOESN'T EXIST = " + filename)
                     continue
                  end if

;  DEFINE ARRAY FOR SUBROUTINE pixel_to_grid_ESMF.ncl
;  PUT ALL SEVIRI DATA INTO ONE ARRAY
                  nvariable           = 12
                  ndim                = dimsizes(acwv)
                  dim_seviri_all      = (/nvariable, ndim(0), ndim(1)/)
                  seviri_all          = new(dim_seviri_all, float, bv2)
                  dim_seviri_grid_all = (/nvariable, nlat, nlon/)
                  seviri_grid_all     = new(dim_seviri_grid_all, float, bv2)
                  seviri_all(0, :, :) = acwv
                  seviri_all(1, :, :) = cot38
                  seviri_all(2, :, :) = cot38_pcl
                  seviri_all(3, :, :) = cer38
                  seviri_all(4, :, :) = cer38_pcl
                  seviri_all(5, :, :) = cwp38
                  seviri_all(6, :, :) = cwp38_pcl
                  seviri_all(7, :, :) = cpop
                  seviri_all(8, :, :) = ctt
;  CONVERT cth UNIT FROM m TO km
                  cth                 = cth/1000.
                  seviri_all(9, :, :) = cth
                  seviri_all(10,:, :) = ctp
                  seviri_all(11,:, :) = cpi
;  IF ALL THE SEVIRI DATA ARE MISSING, THEN CONTINUE TO NEXT LOOP
                  if (all(ismissing(seviri_all))) then
                     continue
                  end if
print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
print("Start to interpolate pixel data to gridded data")
system("date")
;  CALL SUBROUTINE pixel_to_grid_ESMF.ncl TO GRID THE PIXEL LEVEL DATA INTO
;  GRIDDED LEVEL DATA
                  pixel_to_grid_ESMF \
                  (bv2, lat, lon, minlat, maxlat, minlon, maxlon, \
                   lat_grid_size, lon_grid_size, seviri_all, seviri_grid_all)
system("date")
print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
            nelement_write            = 33
            ncount_write              = 100
            ncount_write_day          = ncount_write*nctrack
            dim_write_day             = (/nmethod, ncase, ncount_write_day, nelement_write/)
            wseviri_data_all_day      = new(dim_write_day, float, bv2)

;  READ VARIABLES FROM CAL_LID_L2_05kmALay-Prov-V3 AND CAL_LID_L2_05kmCLay-Prov-V3
            if (logic_sacfilename_region .and. logic_sccfilename_region) then
               if (nactrack_real .eq. ncctrack_real) then
;  DEFINE ARRAY TO COLLECT ALL THE LATITUDE AND LONGITUDE
                  if (isdefined("clat_day") .and. isdefined("clon_day")) then
                     delete([/clat_day, clon_day/])
                  end if
                  npixel                   = 4001
                  clat_day                 = new((/npixel, nactrack_real/), float, bv2)
                  clon_day                 = new((/npixel, nactrack_real/), float, bv2)
;  DEFINE ARRAY TO COLLECT ALL THE SEVIRI DATA FOR ONE DAY
                  if (isdefined("seviri_data_all_day")) then
                     delete([/seviri_data_all_day/])
                  end if
                  dim_day                  = (/nmethod, ncase, nactrack_real, nvariable, nlat, nlon/)
                  seviri_data_all_day      = new(dim_day, float, bv2)
                  do ictrack_real = 0, nactrack_real-1
                     a = addfile(acdir + siyear + "/" + sacfilename_region(ictrack_real), "r")
                     b = addfile(ccdir + siyear + "/" + sccfilename_region(ictrack_real), "r")
                     clat                  = a->Latitude
                     clon                  = a->Longitude
                     cColumn_Optical_Depth_Cloud_532     = a->Column_Optical_Depth_Cloud_532(:, 0)
                     aColumn_Optical_Depth_Aerosols_532  = a->Column_Optical_Depth_Aerosols_532(:, 0)
                     aColumn_Optical_Depth_Aerosols_1064 = a->Column_Optical_Depth_Aerosols_1064(:, 0)
                     aLayer_Top_Altitude   = a->Layer_Top_Altitude
                     aLayer_Base_Altitude  = a->Layer_Base_Altitude
                     aLayer_Top_Pressure   = a->Layer_Top_Pressure
                     aMidlayer_Pressure    = a->Midlayer_Pressure
                     aLayer_Base_Pressure  = a->Layer_Base_Pressure
                     aLayer_Top_Temperature= a->Layer_Top_Temperature
                     aMidlayer_Temperature = a->Midlayer_Temperature
                     aLayer_Base_Temperature=a->Layer_Base_Temperature
                     aNumber_Layers_Found  = a->Number_Layers_Found
                     cLayer_Top_Altitude   = b->Layer_Top_Altitude
                     cLayer_Base_Altitude  = b->Layer_Base_Altitude
                     cLayer_Top_Pressure   = b->Layer_Top_Pressure
                     cMidlayer_Pressure    = b->Midlayer_Pressure
                     cLayer_Base_Pressure  = b->Layer_Base_Pressure
                     cLayer_Top_Temperature= b->Layer_Top_Temperature
                     cMidlayer_Temperature = b->Midlayer_Temperature
                     cLayer_Base_Temperature=b->Layer_Base_Temperature
                     cNumber_Layers_Found  = b->Number_Layers_Found
                     dim_aba               = dimsizes(aLayer_Base_Altitude)
                     npts                  = dim_aba(0)
                     clat@_FillValue       = bv2
                     clon@_FillValue       = bv2
                     clat_day(0:npts-1, ictrack_real) = clat(0:npts-1, 1)
                     clon_day(0:npts-1, ictrack_real) = clon(0:npts-1, 1)
                     acLayer_Top_Altitude   = new((/npts/), float, bv2)
                     acLayer_Base_Altitude  = new((/npts/), float, bv2)
                     acLayer_Top_Pressure   = new((/npts/), float, bv2)
                     acMidlayer_Pressure    = new((/npts/), float, bv2)
                     acLayer_Base_Pressure  = new((/npts/), float, bv2)
                     acLayer_Top_Temperature= new((/npts/), float, bv2)
                     acMidlayer_Temperature = new((/npts/), float, bv2)
                     acLayer_Base_Temperature=new((/npts/), float, bv2)
                     ccLayer_Top_Altitude   = new((/npts/), float, bv2)
                     ccLayer_Base_Altitude  = new((/npts/), float, bv2)
                     ccLayer_Top_Pressure   = new((/npts/), float, bv2)
                     ccMidlayer_Pressure    = new((/npts/), float, bv2)
                     ccLayer_Base_Pressure  = new((/npts/), float, bv2)
                     ccLayer_Top_Temperature= new((/npts/), float, bv2)
                     ccMidlayer_Temperature = new((/npts/), float, bv2)
                     ccLayer_Base_Temperature=new((/npts/), float, bv2)
;  CALL SUBROUTINE select_aca_aba_cloud_cta_var.ncl TO GET REAL ONE LAYER acLayer_Base_Altitude 
;  AND ccLayer_Top_Altitude
                     select_aca_aba_cloud_cta_var \
                     (aLayer_Top_Altitude, aLayer_Base_Altitude, aLayer_Top_Pressure,       \
                      aMidlayer_Pressure, aLayer_Base_Pressure, aLayer_Top_Temperature,     \
                      aMidlayer_Temperature, aLayer_Base_Temperature, aNumber_Layers_Found, \
                      cLayer_Top_Altitude, cLayer_Base_Altitude, cLayer_Top_Pressure,       \
                      cMidlayer_Pressure, cLayer_Base_Pressure, cLayer_Top_Temperature,     \
                      cMidlayer_Temperature, cLayer_Base_Temperature, cNumber_Layers_Found, \
                      acLayer_Top_Altitude, acLayer_Base_Altitude, acLayer_Top_Pressure,    \
                      acMidlayer_Pressure, acLayer_Base_Pressure, acLayer_Top_Temperature,  \
                      acMidlayer_Temperature, acLayer_Base_Temperature,                     \
                      ccLayer_Top_Altitude, ccLayer_Base_Altitude, ccLayer_Top_Pressure,    \
                      ccMidlayer_Pressure, ccLayer_Base_Pressure, ccLayer_Top_Temperature,  \
                      ccMidlayer_Temperature, ccLayer_Base_Temperature)

;  CALL SUBROUTINE select_seviri_calipso_aca_cloud_costantino2010_write_all_var.ncl TO DISTINGUISH 
;  ACA AND CLOUD AS TOUCH AND UNTOUCH
                     select_seviri_calipso_aca_cloud_costantino2010_write_all_var             \
                     (bv2, nvariable, nelement_write, ictrack_real, ncount_write,             \
                     clat, clon, lat_grid_1d, lon_grid_1d, lat_grid_size, lon_grid_size,      \
                     nlat, nlon, minlat, maxlat, minlon, maxlon, iday_or_night,               \
                     cColumn_Optical_Depth_Cloud_532, aColumn_Optical_Depth_Aerosols_532,     \
                     aColumn_Optical_Depth_Aerosols_1064, acLayer_Top_Altitude,               \
                     acLayer_Base_Altitude, acLayer_Top_Pressure, acMidlayer_Pressure,        \
                     acLayer_Base_Pressure, acLayer_Top_Temperature,                          \
                     acMidlayer_Temperature, acLayer_Base_Temperature, ccLayer_Top_Altitude,  \
                     ccLayer_Base_Altitude, ccLayer_Top_Pressure, ccMidlayer_Pressure,        \
                     ccLayer_Base_Pressure, ccLayer_Top_Temperature, ccMidlayer_Temperature,  \
                     ccLayer_Base_Temperature, seviri_grid_all,                               \
                     seviri_data_all_day, wseviri_data_all_day)
;  CALL SUBROUTINE select_seviri_calipso_aca_cloud_costantino2013_write_all_var.ncl TO DISTINGUISH 
;  ACA AND CLOUD AS TOUCH AND UNTOUCH
                     select_seviri_calipso_aca_cloud_costantino2013_write_all_var             \
                     (bv2, nvariable, nelement_write, ictrack_real, ncount_write,             \
                     clat, clon, lat_grid_1d, lon_grid_1d, lat_grid_size, lon_grid_size,      \
                     nlat, nlon, minlat, maxlat, minlon, maxlon, iday_or_night,               \
                     cColumn_Optical_Depth_Cloud_532, aColumn_Optical_Depth_Aerosols_532,     \
                     aColumn_Optical_Depth_Aerosols_1064, acLayer_Top_Altitude,               \
                     acLayer_Base_Altitude, acLayer_Top_Pressure, acMidlayer_Pressure,        \
                     acLayer_Base_Pressure, acLayer_Top_Temperature,                          \
                     acMidlayer_Temperature, acLayer_Base_Temperature, ccLayer_Top_Altitude,  \
                     ccLayer_Base_Altitude, ccLayer_Top_Pressure, ccMidlayer_Pressure,        \
                     ccLayer_Base_Pressure, ccLayer_Top_Temperature, ccMidlayer_Temperature,  \
                     ccLayer_Base_Temperature, seviri_grid_all,                               \
                     seviri_data_all_day, wseviri_data_all_day)
                     delete([/clat, clon, \
                              cColumn_Optical_Depth_Cloud_532, aColumn_Optical_Depth_Aerosols_532,  \
                              aColumn_Optical_Depth_Aerosols_1064,                                  \
                              aLayer_Top_Altitude, aLayer_Base_Altitude, aLayer_Top_Pressure,       \
                              aMidlayer_Pressure, aLayer_Base_Pressure, aLayer_Top_Temperature,     \
                              aMidlayer_Temperature, aLayer_Base_Temperature, aNumber_Layers_Found, \
                              cLayer_Top_Altitude, cLayer_Base_Altitude, cLayer_Top_Pressure,       \
                              cMidlayer_Pressure, cLayer_Base_Pressure, cLayer_Top_Temperature,     \
                              cMidlayer_Temperature, cLayer_Base_Temperature, cNumber_Layers_Found, \
                              acLayer_Top_Altitude, acLayer_Base_Altitude, acLayer_Top_Pressure,    \
                              acMidlayer_Pressure, acLayer_Base_Pressure, acLayer_Top_Temperature,  \
                              acMidlayer_Temperature, acLayer_Base_Temperature,                     \
                              ccLayer_Top_Altitude, ccLayer_Base_Altitude, ccLayer_Top_Pressure,    \
                              ccMidlayer_Pressure, ccLayer_Base_Pressure, ccLayer_Top_Temperature,  \
                              ccMidlayer_Temperature, ccLayer_Base_Temperature/])

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
            fmt        = nelement_write + "f10.3"
            datatitle  = "Latitude "                           + \
                         "Longitude "                          + \
                         "Above_Cloud_Water_Vapor "            + \
                         "Cloud_Optical_Thickness_38 "         + \
                         "Cloud_Optical_Thickness_38_PCL "     + \
                         "Cloud_Effective_Radius_38 "          + \
                         "Cloud_Effective_Radius_38_PCL "      + \
                         "Cloud_Water_Path_38 "                + \
                         "Cloud_Water_Path_38_PCL "            + \
                         "Cloud_Phase_Optical_Properties "     + \
                         "Cloud_Top_Temperature "              + \
                         "Cloud_Top_Height "                   + \
                         "Cloud_Top_Pressure "                 + \
                         "Cloud_Phase_Infrared "               + \
                         "Column_Optical_Depth_Cloud_532 "     + \
                         "Column_Optical_Depth_Aerosols_532 "  + \
                         "Column_Optical_Depth_Aerosols_1064 " + \
                         "Aerosol_Layer_Top_Altitude "         + \
                         "Aerosol_Layer_Base_Altitude "        + \
                         "Aerosol_Layer_Top_Pressure "         + \
                         "Aerosol_Midlayer_Pressure "          + \
                         "Aerosol_Layer_Base_Pressure "        + \
                         "Aerosol_Layer_Top_Temperature "      + \
                         "Aerosol_Midlayer_Temperature "       + \
                         "Aerosol_Layer_Base_Temperature "     + \
                         "Cloud_Layer_Top_Altitude "           + \
                         "Cloud_Layer_Base_Altitude "          + \
                         "Cloud_Layer_Top_Pressure "           + \
                         "Cloud_Midlayer_Pressure "            + \
                         "Cloud_Layer_Base_Pressure "          + \
                         "Cloud_Layer_Top_Temperature "        + \
                         "Cloud_Midlayer_Temperature "         + \
                         "Cloud_Layer_Base_Temperature "
            opt        = True
            opt@title  = datatitle
            do imethod = 0, nmethod-1
               do icase = 0, ncase-1
                  if (.not.all(ismissing(wseviri_data_all_day(imethod, icase, :, :)))) then
                     opt@fout = plot_dir + case(icase) + "_" + method(imethod) + "_" + \
                                sday_or_night(iday_or_night) + "_" + symd1 + "_" + stime + "_ESMF.txt"
                     write_matrix(wseviri_data_all_day(imethod, icase, :, :), fmt, opt)
                  else
                     continue
                  end if
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT DAILY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                  if (logic_plot_daily) then
                     stime_format         = sihour + ":" + simin + ":00"
                     sdaily               = symd2 + " " + stime_format + " " + case(icase) + " " + method(imethod)
                     seviri_element       = (/seviri_data_all_daily(imethod, icase, 1, :, :)/)
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

               end do ;imin
            end do ;ihour
            end do ;iday_or_night
         end do ;iday
      end do ;imonth
   end do ;iyear
   print("Program ends at " + systemfunc("date"))
end
