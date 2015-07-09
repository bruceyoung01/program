; $ID: contour_grid_amsre_caliop.ncl V01 06/10/2015 08:19 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_grid_amsre_caliop READS AMSR-E DATA, PLOTS AS CONTOUR WITH 
;  RASTERFILL, AND OVERLAY WITH CALIPSO GROUND TRACK.
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
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_polyline_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/convert_amsre_element.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_calipso_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/collect_calipso_region.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_contour_grid_landmask_amsre_pl.ncl"


begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plot_contour_grid_amsre_calipso_lwp_v02_2007_07_08_night")
   gsn_define_colormap(wks,"WhBlGrYeOrReVi202")

;  AMSR-E DATA DIRECTORY
   wdir       = "/home/vy57456/zzbatmos_common/Data/AMSRE/bmaps_v07/"

;  CALIPSO DATA INFO
   cdir       = "/home/vy57456/zzbatmos_common/Data/CALIPSO/CAL_LID_L2_05kmAPro/"
   cfilelist  = "filelist_CAL_LID_L2_05kmAPro-Prov-V3-01"

;  DEFINE BAD VALUE
   bv2        =  254.
   bv3        = -9999.

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
   start_month= 7
   end_month  = 8
   start_day  = 1

;  SPECIFY DAY AND NIGHT, ALSO ELEMENTS
;  day_or_night = 1:DAY TIME; 2:NIGHT TIME
;  element = 1:TIME; 2: SST; 3: WINDLF; 4: WINDHF; 5: VAPOR; 6: CLOUD; 7: RAIN RATE
   day_or_night = 2
   element      = 6

;  SWITCH FOR BACKGROUND MAP
   switch_pg  = True

;  WHICH PLOT IS TO BE PLOTTED
   logic_plot_daily    = True

;  SATELLITE NAME
   satename   = "amsre"

;  DEFINE ARRAY FOR DATA
   nday_or_night = 2
   nelement      = 7
   nglobal_lat   = 720
   nglobal_lon   = 1440
   lat_stride    = 0.25
   lon_stride    = 0.25
   dim           = (/nday_or_night, nelement, nglobal_lat, nglobal_lon/)
   dim_element   = (/nglobal_lat, nglobal_lon/)
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

;  @@@DEFINE PARAMETERS, VARIABLES FOR CORRESPONDING SUBROUTINES@@@@@@@@@@@@@@@
;  DEFINE VARIABLES FOR SUBROUTINE select_calipso_filename.ncl
   logic_filename = new((/1/), logical)

;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  START TO PROCESS DATA:
;  READ THE FILE DEPENDING ON THE YEAR, MONTH, DAY, AND DAYTIME AND NIGHTTIME
;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;  DO YEAR LOOP
   do iyear = start_year, end_year

;  DO MONTH LOOP
      do imonth = start_month, end_month
;  CALCULATE # OF DAYS IN THIS MONTH
         lon_year    = days_in_month(iyear, imonth)
;  DO DAY LOOP
         do iday = start_day, lon_year
;  FOR EVERY ITERATION, ASSUME THE FILE NAME EXISTS
            logic_filename = True
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
;  CALL SUBROUTINE convert_amsre_element.ncl TO CONVERT CHARACTER TO REAL AMSR-E DATA
            convert_amsre_element \
            (bv2, nday_or_night, nelement, day_or_night, \
             element, camsre_data, xscale, xoffset, amsre_element)

;  @@@PROCESS CALIPSO DATA@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
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
               tclat   = new((/nclat, nctrack/), float, bv3)
               tclon   = new((/nclat, nctrack/), float, bv3)
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
;  CALL SUBROUTINE plot_contour_grid_landmask_amsre_pl.ncl TO PLOT MONTHLY IMAGE WITH BACKGROUND MAP ON IT
               plot_contour_grid_landmask_amsre_pl \
               (wks, minlat, maxlat, minlon, maxlon, tclat, tclon, \
               lat, lon, day_or_night, element, amsre_element, stime)
            if (switch_pg) then
;  CALL SUBROUTINE polygon_polyline_map.ncl TO PLOT MAP WITH POLYGON ON IT
               polygon_polyline_map \
               (wks, minlat, maxlat, minlon, maxlon, \
               tclat, tclon, lat_pg, lon_pg)
            end if
            end if
         end do ; iday
      end do ; imonth
   end do ; iyear
end
