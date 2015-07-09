; $ID: contour_grid_amsre_diff_aca_case.ncl V01 06/10/2015 08:19 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_grid_amsre_diff_aca_case READS AMSR-E DATA, PLOTS AS CONTOUR 
;  WITH RASTERFILL, MAINLY ABOUT THE DIFFERENCE FOR A VARIABLE BETWEEN NIGHT 
;  AND DAY, CONSIDERING THE RELATIVE POSITION OF ACA AND CLOUD, UNTOUCH, 
;  OBTAINED FROM CALIOP DATA (CAL_LID_L2_05kmAPro-Prov-V3)
;  FOR DAILY AMSR-E DATA, THE 1ST DIMENSION IS DAY TIME; THE 2ND 
;  DIMENSION IS NIGHT TIME.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/10/2015)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/gsn_csm_epa.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/convert_amsre.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_calipso_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_contour_grid_landmask_amsre_diff.ncl"


begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plot_contour_grid_amsre_diff_aca_case_untouch_v01_200708")
   gsn_define_colormap(wks,"NCV_blue_red")

;  DATA DIRECTORY
   wdir       = "/home/vy57456/zzbatmos_common/Data/AMSRE/bmaps_v07/"

;  CALIOP DATA DIRECTORY FOR UNTOUCHED DAY TIME AND NIGHT TIME
   cdir       = "/umbc/lustre/zzbatmos/common/Data/CALIPSO/CAL_LID_L2_05kmAPro/"
   cfilelistd = "filelist_CAL_LID_L2_05kmAPro-Prov-V3-01D_200706_08_untouch"
   cfilelistn = "filelist_CAL_LID_L2_05kmAPro-Prov-V3-01N_200706_08_untouch"

;  DEFINE BAD VALUE
   bv2        =  254.

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
   start_month= 8
   end_month  = 8
   start_day  = 1

;  SET UP SEASONAL STRING: -DJF, -MMA, JJA, SON
   sstring    = "08"

;  STRING FOR THE DIFFERENCE BETWEEN NIGHT AND DAY TIME
   sdiff      = "Night-Day"

;  SPECIFY DAY AND NIGHT, ALSO ELEMENTS
;  day_or_night = 1:DAY TIME; 2:NIGHT TIME
;  element = 1:TIME; 2: SST; 3: WINDLF; 4: WINDHF; 5: VAPOR; 6: CLOUD; 7: RAIN RATE
   day        = 1
   night      = 2
   element    = 6

;  SWITCH FOR BACKGROUND MAP
   switch_pg  = True

;  WHICH PLOT IS TO BE PLOTTED
   logic_plot_daily    = False
   logic_plot_monthly  = False
   logic_plot_seasonal = False
   logic_plot_yearly   = True

;  SATELLITE NAME
   satename   = "amsre"

;  DEFINE ARRAY FOR DATA
   nday_or_night = 2
   nelement      = 7
   nglobal_lat   = 720
   nglobal_lon   = 1440
   lat_stride    = 0.25
   lon_stride    = 0.25
   tnuntouch     = 30
   dim           = (/nday_or_night, nelement, nglobal_lat, nglobal_lon/)
   dim_element   = (/nglobal_lat, nglobal_lon/)
   amsre_data    = new(dim, float, bv2)
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

   amsre_datad_year = new((/tnday_year, nelement, nglobal_lat, nglobal_lon/), float, bv2)
   amsre_datan_year = new((/tnday_year, nelement, nglobal_lat, nglobal_lon/), float, bv2)
;  DO YEAR LOOP
   iyear_loopd  = 0
   iyear_loopn  = 0
   tnday_season = 0
   do iyear = start_year, end_year
      do iiimonth = start_month, end_month
         tnday_season = tnday_season + lon_year
      end do
      amsre_datad_season = new((/tnday_season, nelement, nglobal_lat, nglobal_lon/), float, bv2)
      amsre_datan_season = new((/tnday_season, nelement, nglobal_lat, nglobal_lon/), float, bv2)

;  DO MONTH LOOP
      imonth_loopd = 0
      imonth_loopn = 0
      do imonth = start_month, end_month
;  CALCULATE # OF DAYS IN THIS MONTH
         lon_year    = days_in_month(iyear, imonth)
         tnday_month = lon_year
         amsre_datad_month = new((/tnday_month, nelement, nglobal_lat, nglobal_lon/), float, bv2)
         amsre_datan_month = new((/tnday_month, nelement, nglobal_lat, nglobal_lon/), float, bv2)

;  DO DAY LOOP
         iday_loopd = 0
         iday_loopn = 0
         do iday = start_day, lon_year
;  FOR EVERY ITERATION, ASSUME THE FILE NAME EXISTS
            logic_filenamed = True
            logic_filenamen = True
            siyear  = sprinti("%0.4i", iyear)
            simonth = sprinti("%0.2i", imonth)
            siday   = sprinti("%0.2i", iday)
            stime   = siyear + "-" + simonth + "-" + siday
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
                          camsre_data, xscale, xoffset, amsre_data)

;  @@@PROCESS CALIPSO DATA@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  DEFINE VARIABLES FOR SUBROUTINE select_calipso_filename.ncl
            nscfilename    = 20
            scfilenamed    = new((/nscfilename/), string)
            scfilenamen    = new((/nscfilename/), string)
            day_or_night   = 1
;  CALL SUBROUTINE select_calipso_filename.ncl TO SELECT FILE NAMES BASED ON 
;  YEAR, MONTH, AND DAY
            select_calipso_filename \
            (cdir, cfilelistd, iyear, imonth, iday, day_or_night, \
            logic_filenamed, scfilenamed)
;  CHECK FILENAMES EXIST OR NOT. IF NOT, CONTINUE TO THE NEXT DO LOOP
            if (logic_filenamed) then
;  ACCUMULATE ALL THE DATA FOR MONTHLY, SEASONAL, AND YEALRY CALCULATION
               amsre_datad_month(iday_loopd, :, :, :)    = amsre_data(day_or_night-1, :, :, :)
               amsre_datad_season(imonth_loopd, :, :, :) = amsre_data(day_or_night-1, :, :, :)
               amsre_datad_year(iyear_loopd, :, :, :)    = amsre_data(day_or_night-1, :, :, :)
               iday_loopd   = iday_loopd   + 1
               imonth_loopd = imonth_loopd + 1
               iyear_loopd  = iyear_loopd  + 1
            end if

            day_or_night   = 2
;  CALL SUBROUTINE select_calipso_filename.ncl TO SELECT FILE NAMES BASED ON 
;  YEAR, MONTH, AND DAY
            select_calipso_filename \
            (cdir, cfilelistn, iyear, imonth, iday, day_or_night, \
            logic_filenamen, scfilenamen)
;  CHECK FILENAMES EXIST OR NOT. IF NOT, CONTINUE TO THE NEXT DO LOOP
            if (logic_filenamen) then
;  ACCUMULATE ALL THE DATA FOR MONTHLY, SEASONAL, AND YEALRY CALCULATION
               amsre_datan_month(iday_loopn, :, :, :)    = amsre_data(day_or_night-1, :, :, :)
               amsre_datan_season(imonth_loopn, :, :, :) = amsre_data(day_or_night-1, :, :, :)
               amsre_datan_year(iyear_loopn, :, :, :)    = amsre_data(day_or_night-1, :, :, :)
               iday_loopn   = iday_loopn   + 1
               imonth_loopn = imonth_loopn + 1
               iyear_loopn  = iyear_loopn  + 1
            end if

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT DAILY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            if (logic_plot_daily) then
               stime = stime + " " + sdiff
               amsre_element_day   = (/amsre_data(day-1,   element-1, :, :)/)
               amsre_element_night = (/amsre_data(night-1, element-1, :, :)/)
               amsre_element       = amsre_element_night - amsre_element_day
               amsre_element_avg   = avg(amsre_element)
               stime               = stime + " " + \
                                     sprintf("%7.3f", amsre_element_avg)
;  CALL SUBROUTINE plot_contour_grid_landmask_amsre_diff.ncl TO PLOT MONTHLY IMAGE WITH BACKGROUND MAP ON IT
               plot_contour_grid_landmask_amsre_diff \
               (wks, minlat, maxlat, minlon, maxlon, \
               lat, lon, element, amsre_element, stime)
            if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
               polygon_map \
               (wks, minlat, maxlat, minlon, maxlon, \
               lat_pg, lon_pg)
            end if
            end if

         end do ; iday

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT MONTHLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
         if (logic_plot_monthly) then
            smonthly            = siyear + "-" + simonth  + " " + sdiff
            amsre_element_day   = (/dim_avg_n(amsre_datad_month(:, element-1, :, :), 0)/)
            amsre_element_night = (/dim_avg_n(amsre_datan_month(:, element-1, :, :), 0)/)
            amsre_element       = amsre_element_night - amsre_element_day
            amsre_element_avg   = avg(amsre_element)
            smonthly            = siyear + "-" + simonth  + " " + sdiff + " " + \
                                  sprintf("%7.3f", amsre_element_avg)
;  CALL SUBROUTINE plot_contour_grid_landmask_amsre_diff.ncl TO PLOT MONTHLY IMAGE WITH BACKGROUND MAP ON IT
            plot_contour_grid_landmask_amsre_diff \
            (wks, minlat, maxlat, minlon, maxlon, \
            lat, lon, element, amsre_element, smonthly)
         if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
            polygon_map \
            (wks, minlat, maxlat, minlon, maxlon, \
            lat_pg, lon_pg)
         end if
         end if
         delete([/amsre_datad_month, amsre_datan_month/])
      end do ; imonth

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT SEASONAL IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
      if (logic_plot_seasonal) then
         amsre_element_day   = (/dim_avg_n(amsre_datad_season(:, element-1, :, :), 0)/)
         amsre_element_night = (/dim_avg_n(amsre_datan_season(:, element-1, :, :), 0)/)
         amsre_element       = amsre_element_night - amsre_element_day
         amsre_element_avg   = avg(amsre_element)
         sseasonal           = siyear + " " + sstring  + " " + sdiff + " " + \
                               sprintf("%7.3f", amsre_element_avg)
;  CALL SUBROUTINE plot_contour_grid_landmask_amsre_diff.ncl TO PLOT MONTHLY IMAGE WITH BACKGROUND MAP ON IT
         plot_contour_grid_landmask_amsre_diff \
         (wks, minlat, maxlat, minlon, maxlon, \
         lat, lon, element, amsre_element, sseasonal)
      if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
         polygon_map \
         (wks, minlat, maxlat, minlon, maxlon, \
         lat_pg, lon_pg)
      end if
      end if
      delete([/amsre_datad_season, amsre_datad_season/])
   end do ; iyear

;  DO ELEMENT LOOP TO PLOT EACH ELEMENT
   do ielement = 0, nelement-1
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT YEARLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   if (logic_plot_yearly) then
      amsre_element_day   = (/dim_avg_n(amsre_datad_year(:, ielement, :, :), 0)/)
      amsre_element_night = (/dim_avg_n(amsre_datan_year(:, ielement, :, :), 0)/)
      amsre_element       = amsre_element_night - amsre_element_day
      amsre_element_avg   = avg(amsre_element)
      syearly             = sprinti("%0.4i", start_year) + "-" + \
                            sprinti("%0.4i", end_year)   + " " + \
                            sstring  + " " + sdiff + " " +       \
                            sprintf("%7.3f", amsre_element_avg)
;  CALL SUBROUTINE plot_contour_grid_landmask_amsre_diff.ncl TO PLOT MONTHLY IMAGE WITH BACKGROUND MAP ON IT
      plot_contour_grid_landmask_amsre_diff \
      (wks, minlat, maxlat, minlon, maxlon, \
      lat, lon, ielement+1, amsre_element, syearly)
   if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
      polygon_map \
      (wks, minlat, maxlat, minlon, maxlon, \
      lat_pg, lon_pg)
   end if
   end if
   end do
   delete([/amsre_datad_year, amsre_datan_year/])

end
