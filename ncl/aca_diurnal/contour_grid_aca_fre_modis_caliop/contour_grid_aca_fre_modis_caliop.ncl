;  $ID: contour_grid_aca_fre_modis_caliop.ncl V01 07/27/2015 16:10 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_grid_aca_fre_modis_caliop.ncl READS THE OUTPUT FILES FROM 
;  write_modis_caliop_aca/write_modis_caliop_aca.ncl, WHICH IS BASED ON THE 
;  METHODOLOGY FROM COSTANTINO ET AL., 2013 ACP. THE REFERENCE IN DETAIL IS :
;  (1 ) Costantino, L. and Bréon, F.-M.: Aerosol indirect effect on warm clouds 
;       over South-East Atlantic, from co-located MODIS and CALIPSO observations, 
;       Atmos. Chem. Phys., 13, 69-88, doi:10.5194/acp-13-69-2013, 2013.
;
;  BASED ON THE VARIOUS CASES, THE FILE NAMES ARE LIKE:
;  all_D_2007_07_16.txt
;  noaca_D_2006_07_20.txt
;  touch_D_2007_07_19.txt
;  uncertain_D_2006_07_14.txt
;  untouch_D_2007_08_28.txt
;
;  THE CONTENTS OF THE FILES ARE LIKE:
;   Latitude Longitude Cloud_Optical_Thickness Cloud_Water_Path 
;   Cloud_Effective_Radius Effective_Optical_Depth_Best_Ocean 
;   Angstrom_Exponent_1_Ocean Cloud_Top_Pressure Cloud_Fraction 
;   Column_Optical_Depth_Cloud_532 Column_Optical_Depth_Aerosols_532 
;   Column_Optical_Depth_Aerosols_1064 Aerosol_Layer_Top_Altitude 
;   Aerosol_Layer_Base_Altitude Aerosol_Layer_Top_Pressure 
;   Aerosol_Midlayer_Pressure Aerosol_Layer_Base_Pressure 
;   Aerosol_Layer_Top_Temperature Aerosol_Midlayer_Temperature 
;   Aerosol_Layer_Base_Temperature Cloud_Layer_Top_Altitude 
;   Cloud_Layer_Base_Altitude Cloud_Layer_Top_Pressure Cloud_Midlayer_Pressure 
;   Cloud_Layer_Base_Pressure Cloud_Layer_Top_Temperature 
;   Cloud_Midlayer_Temperature Cloud_Layer_Base_Temperature
;   -12.500    -0.500     6.596    39.080     9.072 -9999.000 -9999.000   
;   969.594     0.975     0.054     0.063     0.108     0.981     0.592   
;   907.904   927.117   950.248    18.276    17.091    13.817     0.562     
;   0.023   953.704   984.301  1015.718    14.077    16.966    19.697
;
;  FLOW CHART:
;  ============================================================================
;  (1 ) DO THE YEAR, MONTH, AND DAY LOOP;
;  (2 ) DO THE CASE AND DAY_OR_NIGHT LOOP;
;  (3 ) READ VARIABLES FROM THE OUTPUT FILE NAMES GENERATED FROM CASE, 
;       DAY_OR_NIGHT, YEAR, MONTH, AND DAY;
;  (4 ) COLLECT ALL THE POSITIONS BASED ON ALL THE CASES;
;  (5 ) PLOT THE DAILY ACA COUNT IMAGE WITH THE POSITIONS OF VARIOUS ACA CASES, 
;       SUCH AS TOUCH, UNTOUCH, UNCERTAIN, AND NOACA;
;  (6 ) END OF DAY LOOP;
;  (7 ) PLOT THE MONTHLY ACA FREQUENCY IMAGE;
;  (8 ) END OF MONTH LOOP;
;  (9 ) PLOT THE YEARLY ACA FREQUENCY IMAGE;
;  (10) END OF YEAR LOOP;
;  (11) PLOT THE TOTAL ACA FREQUENCY IMAGE.
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (07/27/2015)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_polyline_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/grid_lat_lon.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/read_ascii_modis_caliop.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_calipso_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/collect_calipso_region.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_contour_grid_aca_modis_caliop_pl.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_contour_grid_aca_fre_modis_caliop.ncl"


begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   plot_dir   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/contour_grid_aca_fre_modis_caliop/"
   wks        = gsn_open_wks(type, plot_dir + "1plot_contour_grid_aca_fre_modis_caliop_v01")
   gsn_define_colormap(wks,"WhBlGrYeOrReVi202")

;  DATA DIRECTORY
   dir        = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/write_modis_caliop_aca/"

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
;  GRID SIZE TO GRID PIXEL LEVEL DATA INTO GRIDDED LEVEL DATA
   lat_grid_size = 1.0
   lon_grid_size = 1.0

;  SET UP THE START TIME AND END TIME
   start_year   = 2006
   end_year     = 2010
   start_month  = 7
   end_month    = 9
   start_day    = 1

;  SPECIFY DAY AND NIGHT
;  day_or_night = 0:DAY TIME; 1:NIGHT TIME
   day_or_night = 0

;  WHICH PLOT IS TO BE PLOTTED
   logic_plot_daily   = False
   logic_plot_monthly = False
   logic_plot_yearly  = False
   logic_plot_total   = True

;  SWITCH FOR DIFFERENT CASES
;  FOR Costantino_2013
;  "all"       : ALL THE CASES INCLUDING ACA AND CLOUD WITH UNTOUCH AND TOUCH
;  "untouch"   : UNTOUCH ACA AND CLOUD
;  "touch"     : TOUCH ACA AND CLOUD
;  "uncertain" : UNCERTAIN ABOUT WHETHER ACA AND CLOUD TOUCH OR UNTOUCH
;  "noaca"     : NO ACA
   case          = (/"untouch", "touch", "uncertain", "noaca"/)
   ncase         = dimsizes(case)

;  DEFINE ARRAY FOR GRIDDED LATITUDE AND LONGITUDE ARRAY
   nlat       = floattoint((maxlat-minlat)/lat_grid_size) + 2
   nlon       = floattoint((maxlon-minlon)/lon_grid_size) + 2
   lat_grid_1d= new((/nlat/), float, bv2)
   lon_grid_1d= new((/nlon/), float, bv2)
   lat_grid_2d= new((/nlat, nlon/), float, bv2)
   lon_grid_2d= new((/nlat, nlon/), float, bv2)

;  CALL SUBROUTINE grid_lat_lon.ncl TO GENERATE GRIDDED LATITUDE AND LONGITUDE
   grid_lat_lon \
   (minlat, maxlat, minlon, maxlon, lat_grid_size, lon_grid_size, \
   lat_grid_1d, lon_grid_1d, lat_grid_2d, lon_grid_2d)

;  DEFINE NEW ARRAY TO READ DATA
   nvariable        = 28
   nctrack          = 3
   ncount_write     = 100
   ncount_write_day = nctrack*ncount_write
   variable_name    = new((/nvariable/), string)

   dim_total        = (/ncase, nlat, nlon/)
   modis_data_total = new((/dim_total/), float, bv2)
   modis_data_total = 0.0
   iloop_year = 0
;  DO YEAR LOOP
   do iyear = start_year, end_year
      dim_year         = (/ncase, nlat, nlon/)
      modis_data_year  = new((/dim_year/), float, bv2)
      modis_data_year  = 0.0
      iloop_month = 0
;  DO MONTH LOOP
      do imonth = start_month, end_month
;  CALCULATE # OF DAYS IN THIS MONTH
         days_month       = days_in_month(iyear, imonth)
         dim_month        = (/ncase, nlat, nlon/)
         modis_data_month = new((/dim_month/), float, bv2)
         modis_data_month = 0.0
         iloop_day = 0
;  DO DAY LOOP
         do iday = start_day, days_month
            siyear  = sprinti("%0.4i", iyear)
            simonth = sprinti("%0.2i", imonth)
            siday   = sprinti("%0.2i", iday)
            stime   = siyear + "_" + simonth + "_" + siday
            print("Date : " + stime)

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PROCESS CALIPSO DATA
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            if (logic_plot_daily) then
;  DEFINE VARIABLES FOR SUBROUTINE select_calipso_filename.ncl
               logic_filename = True
               nscfilename    = 20
               scfilename     = new((/nscfilename/), string)
;  CALL SUBROUTINE select_calipso_filename.ncl TO SELECT FILE NAMES BASED ON 
;  YEAR, MONTH, AND DAY
               select_calipso_filename \
               (cdir, cfilelist, iyear, imonth, iday, day_or_night, \
               logic_filename, scfilename)
;  CHECK FILENAMES EXIST OR NOT. IF NOT, CONTINUE TO THE NEXT DO LOOP
               if (.not. logic_filename) then
                  print("Missing CALIPSO FILE ON " + stime)
                  continue
               end if
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
            end if ;logic_plot_daily

            dim_day = (/ncase, nlat, nlon/)
            cmodis_data_day = new((/dim_day/), float, bv2)
            cmodis_data_grid= new((/nlat, nlon/), float, bv2)

;  DO CASE LOOP
            do icase = 0, ncase-1
;  BUILD THE FILE NAME TO READ
               filename = dir + case(icase) + "_D_" + stime + ".txt"
;  CHECK THE EXISTENCE OF FILENAME
               if (.not.fileexists(filename)) then
                  print("FILE DOESN'T EXISTS : " + str_get_cols(filename, 80, 110))
                  continue
               end if

;  DEFINE ARRAY FOR SUBROUTINE read_ascii_modis_caliop.ncl
               variable_name = new((/nvariable/), string, bv0)
               modis_data    = new((/nvariable, ncount_write_day/), float, bv2)
;  CALL SUBROUTINE read_ascii_modis_caliop.ncl TO READ THE DATA FROM TEXT FILE
               read_ascii_modis_caliop              \
               (filename, nvariable, variable_name, \
               modis_data(:, :))

               modis_lat       = modis_data(0, :)
               modis_lon       = modis_data(1, :)
               modis_data_grid = new((/nlat, nlon/), float, bv2)
               modis_data_grid = 0.0
;  CONVERT VARIABLE FROM 1-D TO 2-D WITH 1ST D IS LATITUDE, 2ND IS LONGITUDE
               do ilat = 0, nlat-1
                  do ilon = 0, nlon-1
                     index_latlon = ind(modis_lat .eq. lat_grid_1d(ilat) .and. \
                                        modis_lon .eq. lon_grid_1d(ilon))
                     if (.not.all(ismissing(index_latlon))) then
                        modis_data_grid(ilat, ilon)  = 1.0
                        cmodis_data_grid(ilat, ilon) = int2flt(icase)-1
                     end if
                     delete([/index_latlon/])
                  end do ;ilon
               end do ;ilat

;  ASSIGN GRIDDED DATA TO THE DAY DATA, MONTH DATA, YEAR DATA, AND TOTAL DATA
               modis_data_month(icase, :, :) = modis_data_month(icase, :, :) + modis_data_grid
               modis_data_year(icase, :, :)  = modis_data_year(icase, :, :)  + modis_data_grid
               modis_data_total(icase, :, :) = modis_data_total(icase, :, :) + modis_data_grid
            end do ;icase

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT DAILY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            if (logic_plot_daily) then
;  CALL SUBROUTINE plot_contour_grid_aca_modis_caliop_pl.ncl TO PLOT ACA CASES 
;  WITH CALIPSO GROUND TRACK ON IT
               plot_contour_grid_aca_modis_caliop_pl              \
               (wks, stime, case, minlat, maxlat, minlon, maxlon, \
               tclat, tclon, lat_grid_1d, lon_grid_1d, cmodis_data_grid)
;  CALL SUBROUTINE polygon_polyline_map.ncl TO PLOT MAP WITH POLYGON AND 
;  POLYLINE ON IT
               polygon_polyline_map                  \
               (wks, minlat, maxlat, minlon, maxlon, \
               tclat, tclon, lat_pg, lon_pg)
            end if
         end do ;iday

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT MONTHLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  CALCULATE MONTHLY FREQUENCY DATA
         modis_data_month = 100*modis_data_month/sum(modis_data_month)
         smonthly         = siyear + "_" + simonth
         if (logic_plot_monthly) then
            do icase = 0, ncase-1
;  CALL SUBROUTINE plot_contour_grid_aca_fre_modis_caliop.ncl TO PLOT ACA CASES 
;  WITH CALIPSO GROUND TRACK ON IT
               plot_contour_grid_aca_fre_modis_caliop                       \
               (wks, smonthly, case(icase), minlat, maxlat, minlon, maxlon, \
               lat_grid_1d, lon_grid_1d, modis_data_month(icase, :, :))
            end do ;icase
         end if

      end do ;imonth

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT YEARLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  CALCULATE YEARLY FREQUENCY DATA
         modis_data_year = 100*modis_data_year/sum(modis_data_year)
         syearly         = siyear
         if (logic_plot_yearly) then
            do icase = 0, ncase-1
;  CALL SUBROUTINE plot_contour_grid_aca_fre_modis_caliop.ncl TO PLOT ACA CASES 
;  WITH CALIPSO GROUND TRACK ON IT
               plot_contour_grid_aca_fre_modis_caliop                      \
               (wks, syearly, case(icase), minlat, maxlat, minlon, maxlon, \
               lat_grid_1d, lon_grid_1d, modis_data_year(icase, :, :))
            end do ;icase
         end if

   end do ;iyear

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT TOTAL IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  CALCULATE TOTAL FREQUENCY DATA
         modis_data_total = 100*modis_data_total/sum(modis_data_total)
         stotal           = start_year + "-" + end_year
         if (logic_plot_total) then
            do icase = 0, ncase-1
;  CALL SUBROUTINE plot_contour_grid_aca_fre_modis_caliop.ncl TO PLOT ACA CASES 
;  WITH CALIPSO GROUND TRACK ON IT
               plot_contour_grid_aca_fre_modis_caliop                     \
               (wks, stotal, case(icase), minlat, maxlat, minlon, maxlon, \
               lat_grid_1d, lon_grid_1d, modis_data_total(icase, :, :))
            end do ;icase
         end if

end
