;  $ID: contour_grid_seviri_cot_calipso.ncl V01 06/25/2015 16:46 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_pixel_seviri_cot_calipso.ncl READS SEVIRI DATA, WHICH HAVE 
;  ONE RECORD PER 15MIN. AND GRIDS THEM INTO GRIDDED DATA, THEN PLOTS THEM AS 
;  CONTOUR OVER A MAP.
;
;  PROGRAM FLOW CHART:
;  ============================================================================
;  (1 ) READ SEVIRI FILE NAME BASED ON YEAR, MONTH, DAY, HOUR, AND MIN.
;  (2 ) GRID THE PIXEL DATA TO GRIDDED DATA.
;  (3 ) PLOT THE IMAGE FOR EVERY 15 MIN.
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
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/gsn_csm_epa.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_polyline_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/grid_lat_lon.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/pixel_to_grid_ESMF.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_calipso_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/collect_calipso_region.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_contour_grid_landmask_seviri_pl.ncl"

begin

   print("Program Starts at " + systemfunc("date"))
   start_time = get_cpu_time()
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
;  type       = "pdf"
   type       = "png"
   plot_dir   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/contour_grid_seviri_cot_calipso/"
   wks        = gsn_open_wks(type,plot_dir + "1plot_contour_grid_seviri_cot_calipso_v01")
   gsn_define_colormap(wks,"WhBlGrYeOrReVi202")

;  DATA DIRECTORY FOR SEVIRI
   dir        = "/home/vy57456/zzbatmos_common/Data/SEVIRI/SEV_06-CLD-L2.v1.03/"

;  CALIPSO DATA INFO
   cdir       = "/home/vy57456/zzbatmos_common/Data/CALIPSO/CAL_LID_L2_05kmAPro/"
   cfilelist  = "filelist_CAL_LID_L2_05kmAPro-Prov-V3-01"

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
   start_month= 6
   end_month  = 6
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
   element    = "cot16"

;  WHICH PLOT IS TO BE PLOTTED
   logic_plot_daily    = True

;  SWITCH FOR BACKGROUND MAP
   switch_pg  = True
   minpixel   = 1

   sday_or_night = (/"D", "N"/)
   nday_or_night = dimsizes(sday_or_night)

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

;  @@@DEFINE PARAMETERS, VARIABLES FOR CORRESPONDING SUBROUTINES@@@@@@@@@@@@@@@
;  DEFINE VARIABLES FOR SUBROUTINE select_calipso_filename.ncl
   logic_filename = new((/1/), logical)

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
            siyear  = sprinti("%0.4i", iyear)
            simonth = sprinti("%0.2i", imonth)
            siday   = sprinti("%0.2i", iday)
            symd1   = siyear + "_" + simonth + "_" + siday
            symd2   = siyear + "-" + simonth + "-" + siday

;  DO DAY AND NIGHT LOOP
            do iday_or_night = 0, nday_or_night-1
;  @@@PROCESS CALIPSO DATA@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  DEFINE VARIABLES FOR SUBROUTINE select_calipso_filename.ncl
            nscfilename    = 20
            scfilename     = new((/nscfilename/), string)
;  CALL SUBROUTINE select_calipso_filename.ncl TO SELECT FILE NAMES BASED ON 
;  YEAR, MONTH, AND DAY
            select_calipso_filename \
            (cdir, cfilelist, iyear, imonth, iday, iday_or_night, \
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
                     else if (ihour .eq. 19 .and. imin .gt. 15) then
                        continue
                     else if (ihour .eq. 7  .and. imin .gt. 30) then
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
                     else if (ihour .eq. 7  .and. imin .lt. 15) then
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
print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
print("Start to interpolate pixel data to gridded data")
system("date")
;  CALL SUBROUTINE pixel_to_grid_degree.ncl TO GRID THE PIXEL LEVEL DATA INTO
;  GRIDDED LEVEL DATA
;                 pixel_to_grid_degree \
;                 (bv1, bv2, lat_grid_2d, lon_grid_2d, lat_grid_size, lon_grid_size, \
;                 lat, lon, minpixel, cot16, cot16_grid, cot16_grid_n, cot16_grid_std)
;  CALL SUBROUTINE pixel_to_grid_ESMF.ncl TO GRID THE PIXEL LEVEL DATA INTO
;  GRIDDED LEVEL DATA
                  pixel_to_grid_ESMF \
                  (lat, lon, minlat, maxlat, minlon, maxlon, \
                   lat_grid_size, lon_grid_size, cot16, cot16_grid)

system("date")
print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
                  cot16_grid!0     = "lat"
                  cot16_grid!1     = "lon"
                  cot16_grid@lat2d = lat_grid_2d
                  cot16_grid@lon2d = lon_grid_2d

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT DAILY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                  if (logic_plot_daily) then
                     stime  = sihour + ":" + simin + ":00"
                     sdaily = symd2 + " " + stime
;  CALL SUBROUTINE plot_contour_grid_landmask_seviri_pl.ncl TO PLOT MONTHLY IMAGE WITH BACKGROUND MAP ON IT
                     plot_contour_grid_landmask_seviri_pl  \
                     (wks, minlat, maxlat, minlon, maxlon, \
                     tclat, tclon, element, cot16_grid, sdaily)
                  if (switch_pg) then
;  CALL SUBROUTINE polygon_polyline_map.ncl TO PLOT MAP WITH POLYGON ON IT
                     polygon_polyline_map \
                     (wks, minlat, maxlat, minlon, maxlon, \
                     tclat, tclon, lat_pg, lon_pg)
                  end if
                  end if

                  delete([/cot16/])
               end do ;imin
            end do ;ihour
            end do ;iday_or_night
         end do ;iday
      end do ;imonth
   end do ;iyear
   print("Program ends at " + systemfunc("date"))
   end_time = get_cpu_time()
   duration = end_time - start_time
   print("Program costs " + duration)
end
