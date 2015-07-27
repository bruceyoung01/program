;  $ID: contour_pixel_modis_mod04_caliop.ncl V01 07/27/2015 11:00 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_pixel_modis_mod04_caliop.ncl READS MODIS MOD04_L2/MYD04_L2 
;  VARIABLE, MODIS MOD04_L2/MYD04_L2 FILE NAMES ARE LIKE:
;  MYD04_L2.A2006218.1510.051.2009065160506.hdf
;  THEN READS CALIPSO AEROSOL PROFILE DATA AND GETS THE CALIPSO GROUND TRACK 
;  INFO. THE CALIPSO FILE NAMES ARE LIKE:
;  CAL_LID_L2_05kmAPro-Prov-V3-01.2007-07-01T21-28-14ZD.hdf
;  THEN PLOTS MODIS REGRIDDED DATA WITH CALIPSO GROUND TRACK.
;
;  FLOW CHART:
;  ============================================================================
;  (1 ) DO THE YEAR, MONTH, AND DAY LOOPS;
;  (2 ) BASED ON THE YEAR, MONTH, AND DAY, SELECT MODIS MOD04_L2/MYD04_L2 
;       FILENAMES ON THAT DAY IN THE STUDY REGION. FOR DAY, WE CAN GET DATE 
;       INFO FROM MODIS FILENAMES; FOR THE STUDY REGION, WE ALREADY SET UP THE 
;       REGION WHILE WE DOWNLOAD THE MODIS DATA;
;  (3 ) BASED ON THE YEAR, MONTH, AND DAY, SELECT CALIPSO CAL_LID_L2_05kmAPro
;       FILENAMES ON THAT DAY IN THE STUDY REGION. FOR DAY, WE CAN GET DATE 
;       INFO FROM MODIS FILENAMES; FOR THE STUDY REGION, WE COLLECT FILENAMES 
;       BASED ON THE LATITUDE AND LONGITUDE READ FROM CALIPSO DATA;
;  (4 ) THEN CHECK IF MODIS HAS DATA ON THAT DAY AND IN THE STUDY REGION. IF 
;       "NO", CONTINUE TO THE NEXT DAY; IF "YES", THEN CHECK WHETHER CALIPSO 
;       HAS DATA ON THAT DAY AND IN THE STUDY REGION. NO MATTER "YES" OR "NO", 
;       START TO PLOT MODIS DATA;
;  (5 ) PLOT MODIS DATA AS CONTOUR AND OVERLAY WITH CALIPSO GROUND TRACK;
;  (6 ) END THE YEAR, MONTH, AND DAY LOOPS.
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (07/27/2015)
;  (2 ) THIS PROGRAM IS SIMILAR TO contour_grid_modis_mod04.ncl. HOWEVER, 
;       contour_grid_modis_mod04.ncl IS BASED ON FILENAME LOOP, THIS PROGRAM IS 
;       BASED ON YEAR, MONTH, AND DAY LOOPS. (07/27/2015)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_polyline_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_modis_mod04_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/read_modis_mod04_2d_1day_yearmonthday.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_calipso_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/collect_calipso_region.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_contour_pixel_modis_mod04.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_contour_pixel_modis_mod04_pl.ncl"


begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   plot_dir   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/contour_pixel_modis_mod04_caliop/"
   wks        = gsn_open_wks(type, plot_dir + "1plot_contour_pixel_modis_mod04_caliop_v01")
   gsn_define_colormap(wks,"WhBlGrYeOrReVi202")

;  DATA DIRECTORY
   dir        = "/home/vy57456/zzbatmos_common/Data/MODIS/aca_diurnal/MYD04_L2/"
   filelist   = "filelist_MYD04_L2"

;  CALIPSO DATA INFO
   cdir       = "/home/vy57456/zzbatmos_common/Data/CALIPSO/CAL_LID_L2_05kmAPro/"
   cfilelist  = "filelist_CAL_LID_L2_05kmAPro-Prov-V3-01"

;  DEFINE BAD VALUE
   bv0        = "FillValue"
   bv1        = -9999
   bv2        = -9999.

;  SET UP LIMITED REGION
   minlat     =-15.0
   maxlat     =-2.0
   minlon     =-14.0
   maxlon     = 18.0
;  LATTITUDE AND LONGITUDE FOR STUDY REGION
   lat_pg     = (/minlat, minlat, maxlat, maxlat, minlat/)
   lon_pg     = (/minlon, maxlon, maxlon, minlon, minlon/)

;  SET UP THE START TIME AND END TIME
   start_year = 2008
   end_year   = 2008
   start_month= 7
   end_month  = 9
   start_day  = 1

   variable   = "Angstrom_Exponent_1_Ocean"
;  variable   = "Effective_Optical_Depth_Best_Ocean"

;  SPECIFY DAY AND NIGHT
;  day_or_night = 0:DAY TIME; 1:NIGHT TIME
   day_or_night = 0

;  WHICH PLOT IS TO BE PLOTTED
   logic_plot_daily = True

;  GET SATELLITE NAME IS Terra OR Aqua
   satename   = str_get_cols(filelist, -8, -6)

;  DO YEAR LOOP
   do iyear = start_year, end_year

;  DO MONTH LOOP
      do imonth = start_month, end_month
;  CALCULATE # OF DAYS IN THIS MONTH
         lon_year    = days_in_month(iyear, imonth)
;  DO DAY LOOP
         iday_loop = 0
         do iday = start_day, lon_year
;  FOR EVERY ITERATION, ASSUME THE FILE NAME EXISTS
            logic_filename = True
            siyear  = sprinti("%0.4i", iyear)
            simonth = sprinti("%0.2i", imonth)
            siday   = sprinti("%0.2i", iday)
            stime   = siyear + "-" + simonth + "-" + siday
            print("Date : " + stime)

            nsfilename      = 10
            nsfilename_real = new((/1/), integer, bv1)
            logic_sfilename = True
            sfilename       = new((/nsfilename/), string)
;  CALL SUBROUTINE select_modis_mod04_filename.ncl TO SELECT MODIS MOD04_L2/MYD04_L2 FILE NAME
            select_modis_mod04_filename          \
            (dir, filelist, iyear, imonth, iday, \
            sfilename, nsfilename_real, logic_sfilename)
            if (.not.logic_sfilename) then
               print("----------------------------------------------------------")
               print("MODIS MOD04_L2/MYD04_L2 File name does not exist on " + stime)
               continue
            end if
            print("Now Processing : " + sfilename(0:nsfilename_real-1))

;  DECLARE VARIABLES FOR SUBROUTINE read_modis_aod_1day.ncl
            mnp            = 203
            mnl            = 135
            mfactor        = 15
            tmnp           = mnp*mfactor
            mlat           = new((/tmnp, mnl/), float, bv2)
            mlon           = new((/tmnp, mnl/), float, bv2)
            mdata          = new((/tmnp, mnl/), float, bv2)
            mdata_qa_land  = new((/tmnp, mnl/), integer, bv1)
            mdata_qa_ocean = new((/tmnp, mnl/), integer, bv1)

;  CALL SUBROUTINE read_modis_mod04_2d_1day_yearmonthday.ncl TO READ ALL THE LATITUDE, LONGITUDE, 
;  MODIS DATA QUALITY FLAG, AND MODIS DATA FOR ONE DAY.
            read_modis_mod04_2d_1day_yearmonthday \
            (dir, bv0, iyear, sfilename, variable, mlat, mlon, \
            mdata_qa_land, mdata_qa_ocean, mdata)

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PROCESS CALIPSO DATA
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  DEFINE VARIABLES FOR SUBROUTINE select_calipso_filename.ncl
            nscfilename    = 20
            scfilename     = new((/nscfilename/), string)
;  CALL SUBROUTINE select_calipso_filename.ncl TO SELECT FILE NAMES BASED ON 
;  YEAR, MONTH, AND DAY
            select_calipso_filename \
            (cdir, cfilelist, iyear, imonth, iday, day_or_night, \
            logic_filename, scfilename)
;  CHECK FILENAMES EXIST OR NOT. IF NOT, CONTINUE TO THE NEXT DO LOOP
            if (logic_filename) then
;  DEFINE ARRAY TO HOLD LATITUDE AND LONGITUDE
               nclat   = 4500
               nctrack = 3
               tclat   = new((/nclat, nctrack/), float, bv2)
               tclon   = new((/nclat, nctrack/), float, bv2)
;  CALL SUBROUTINE collect_calipso_region.ncl TO COLLECT ALL THE GROUND TRACK 
;  IN THE STUDY REGION
               collect_calipso_region \
               (cdir, scfilename, siyear, minlat, maxlat, minlon, maxlon, \
               tclat, tclon)
            end if

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT DAILY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            if (logic_plot_daily) then
               if (satename .eq. "MYD") then
;  CALL SUBROUTINE plot_contour_pixel_modis_mod04_pl.ncl TO PLOT IMAGE.
                  plot_contour_pixel_modis_mod04_pl \
                  (wks, stime, minlat, maxlat, minlon, maxlon, \
                  tclat, tclon, mlat, mlon, mdata)

;  CALL SUBROUTINE polygon_polyline_map.ncl TO PLOT MAP WITH POLYGON AND 
;  POLYLINE ON IT
                  polygon_polyline_map \
                  (wks, minlat, maxlat, minlon, maxlon, \
                  tclat, tclon, lat_pg, lon_pg)
               else if (satename .eq. "MOD") then
;  CALL SUBROUTINE plot_contour_pixel_modis_mod04.ncl TO PLOT IMAGE.
                  plot_contour_pixel_modis_mod04 \
                  (wks, stime, minlat, maxlat, minlon, maxlon, \
                  mlat, mlon, mdata)

;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON AND POLYLINE ON IT
                  polygon_map \
                  (wks, minlat, maxlat, minlon, maxlon, \
                  lat_pg, lon_pg)
               end if
               end if
            end if
         end do ; iday
      end do ; imonth
   end do ; iyear

end
