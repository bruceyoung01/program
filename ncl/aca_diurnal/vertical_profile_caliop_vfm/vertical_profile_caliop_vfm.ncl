;  $ID: vertical_profile_caliop_vfm.ncl V01 11/20/2015 19:15 ZHIFENG YANG EXP$
;
;******************************************************************************
;  PROGRAM vertical_profile_caliop_vfm.ncl READS CALIPSO VERTICAL FEATURE MASK 
;  PRODUCT AND PLOTS THE VERTICAL PROFILE OF AEROSOL AND CLOUD OVER THE STUDY 
;  REGION.
;
;  FLOW CHART:
;  ============================================================================
;  (1 ) SETUP THE BASIC INFO, SUCH AS OUTPUT FILE NAME, DIRECTORY, DEFAULT 
;       MISSING VALUE, AND TIME;
;  (2 ) READ THE CALIPSO FILE NAMES INTO AN ARRAY;
;  (3 ) DO DAYTIME/NIGHTTIME, YEAR, MONTH, AND DAY LOOP;
;  (4 ) SELECT THE CORRESPONDING FILE NAMES BASED DAYTIME/NIGHTTIME, YEAR, 
;       MONTH, AND DAY;
;  (5 ) READ THE VARIABLE NAMES FOR THE STUDY REGION;
;  (6 ) CALCULATE THE REGIONAL AVERAGE AND PLOT VERTICAL PROFILE OF DAY;
;  (7 ) END OF DAY LOOP;
;  (8 ) CALCULATE THE REGIONAL AVERAGE AND PLOT VERTICAL PROFILE OF MONTH;
;  (9 ) END OF MONTH LOOP;
;  (10) CALCULATE THE REGIONAL AVERAGE AND PLOT VERTICAL PROFILE OF YEAR;
;  (11) END OF YEAR LOOP;
;  (12) CALCULATE THE REGIONAL AVERAGE AND PLOT VERTICAL PROFILE FOR ALL THE 
;       DATA.
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY ZHIFENG YANG. (11/20/2015)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/function/bintoint.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_calipso_filename_vfm.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/collect_calipso_region_dn_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/calculate_vertical_count_vfm.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_profile.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   plot_dir   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/vertical_profile_caliop_vfm/"
   wks        = gsn_open_wks(type, plot_dir + "1plot_vertical_profile_caliop_vfm_v01")
;  gsn_define_colormap(wks,"MPL_gist_yarg")

;  DATA DIRECTORY
   dir        = "/home/vy57456/zzbatmos_common/Data/CALIPSO/CAL_LID_L2_VFM-ValStage1-V3/"
   filelist   = "filelist_VFM"

;  DEFINE BAD VALUE
   bv1        = -9999
   bv2        = -9999.

;  SET UP LIMITED REGION
   minlat     =-20.0
   maxlat     =  0.0
   minlon     =-10.0
   maxlon     = 15.0

;  SET UP THE START TIME AND END TIME
   start_year   = 2007
   end_year     = 2007
   start_month  = 1
   end_month    = 1
   start_day    = 1

;  DAY OR NIGHT TIME FOR CALIPSO
   sday_or_night= "D"
;  LAND OR WATER FLAG
;  0 = shallow ocean
;  1 = land
;  2 = coastlines
;  3 = shallow inland water
;  4 = intermittent water
;  5 = deep inland water
;  6 = continental ocean
;  7 = deep ocean
   land_or_water= 7
;  THE TOTAL LAYERS WITH VERTICAL RESOLUTION OF 30m
   ninterval    = 290
;  SETUP VERTICAL AXIS INFO
   y_bottom     = -0.5
   y_top        =  8.2
   y            = fspan(y_bottom, y_top, ninterval)

;  DO YEAR LOOP
   iyear_loop = 0
   do iyear = start_year, end_year
      siyear = sprinti("%0.4i", iyear)

;  DO MONTH LOOP
      imonth_loop = 0
      do imonth = start_month, end_month
         simonth = sprinti("%0.2i", imonth)

;  CALCULATE # OF DAYS IN THIS MONTH
         nday_month = days_in_month(iyear, imonth)

;  DO DAY LOOP
;  DEFINE ARRAY FOR COUNT
         count_aerosol_day = new((/ninterval/), integer)
         count_aerosol_day = 0
         count_cloud_day   = new((/ninterval/), integer)
         count_cloud_day   = 0
         count_ac_day      = new((/ninterval/), integer)
         count_ac_day      = 0
         do iday = start_day, start_day;nday_month

;  FOR EVERY ITERATION, ASSUME THE FILE NAME EXISTES
            logic_filename = True
            siday   = sprinti("%0.2i", iday)
            sitime  = siyear + "-" + simonth + "-" + siday
            print("Now Processing : " + sitime)

;  LARGEST NUMBER OF TRACKS IN THIS REGION ON THIS DAY
            nfile_day = 20
            sfilename = new((/nfile_day/), string)

;  CALL SUBROUTINE select_calipso_filename_VFM.ncl TO SELECT 
;  THE CALIPSO FILE NAMES ON THIS DAY
;  CAL_LID_L2_VFM-ValStage1-V3-30.2014-12-31T01-56-29ZN.hdf
            select_calipso_filename_vfm    \
            (dir, filelist, iyear, imonth, \
            iday, sday_or_night,           \
            logic_filename, sfilename)

;  CHECK FILENAMES EXIST OR NOT. IF NOT, CONTINUE TO THE NEXT DO DAY LOOP
            if (logic_filename) then
;  DEFINE ARRAY TO HOLD LATITUDE AND LONGITUDE
               nctrack                 = 3
               scfilename_region       = new((/nctrack/), string)
               nctrack_real            = new((/1/), integer, bv1)
               logic_scfilename_region = False
;  CALL SUBROUTINE collect_calipso_region_dn_filename.ncl TO COLLECT ALL THE 
;  CALIPSO FILENAMES IN THE STUDY REGION FOR CAL_LID_L2_VFM-ValStage1-V3
               collect_calipso_region_dn_filename          \
               (dir, sfilename, siyear, sday_or_night,     \
               minlat, maxlat, minlon, maxlon,             \
               scfilename_region, logic_scfilename_region, \
               nctrack_real)
            else
               print("NO CALIPSO DATA ON " + sitime)
               continue
            end if

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  READ DATA FROM THE SELECTED CALIPSO TRACK
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            tpoint_aerosol = 0
            tpoint_cloud   = 0
;  DO THE NUMBER OF SELECTED TRACKS LOOP
            do itrack = 0, 0;nctrack_real-1
               a = addfile (dir + siyear + "/" + scfilename_region(itrack), "r")
               lat = a->Latitude(:, 0)
               lon = a->Longitude(:, 0)
               dnf = a->Day_Night_Flag(:, 0)
               lwm = a->Land_Water_Mask(:, 0)
               fcf = a->Feature_Classification_Flags
;  CALL SUBROUTINE calculate_vertical_count_vfm.ncl TO CALCULATE THE COUNT 
;  ALONG THE VERTICAL PROFILE
               calculate_vertical_count_vfm                 \
               (minlat, maxlat, minlon, maxlon, lat, lon,   \
               tpoint_aerosol, tpoint_cloud, dnf, lwm, fcf, \
               ninterval, sday_or_night, land_or_water,     \
               count_aerosol_day, count_cloud_day, count_ac_day)
            end do ;ITRACK

;count_aerosol_day = random_normal(50, 5, ninterval)
;  CALL SUBROUTINE plot_profile.ncl TO PLOT VERTICAL PROFILE
            plot_profile \
            (wks, y, count_aerosol_day)
         end do ;DAY
      end do ;MONTH
   end do ;YEAR




end
