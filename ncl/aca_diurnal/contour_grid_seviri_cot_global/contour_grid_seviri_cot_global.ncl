;  $ID: contour_grid_seviri_cot_global.ncl V01 06/25/2015 16:46 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_pixel_seviri_cot_global.ncl READS SEVIRI DATA, WHICH HAVE 
;  ONE RECORD PER 15MIN, THEN PLOTS THEM AS CONTOUR OVER A MAP.
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
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/grid_lat_lon.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/pixel_to_grid_degree.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/pixel_to_grid_ESMF.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_contour_grid_landmask_seviri.ncl"

begin

   print("Program Starts at " + systemfunc("date"))
   start_time = get_cpu_time()
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
;  type       = "pdf"
   type       = "png"
   plot_dir   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/contour_grid_seviri_cot_global/"
   wks        = gsn_open_wks(type, "1plot_contour_grid_seviri_cot_global_v02")
   gsn_define_colormap(wks,"WhBlGrYeOrReVi202")

;  DATA DIRECTORY FOR SEVIRI
   dir        = "/home/vy57456/zzbatmos_common/Data/SEVIRI/SEV_06-CLD-L2.v1.03/"

;  DEFINE BAD VALUE
   bv1        = -9999
   bv2        = -9999.
   bv3        = -999.999

;  SET UP LIMITED REGION
   minlat     =-80.0
   maxlat     = 80.0
   minlon     =-80.0
   maxlon     = 80.0
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
   start_hour = 6
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
   switch_pg  = False
   minpixel   = 1

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
;  DO HOUR LOOP
            do ihour = start_hour, end_hour
;  DO MINUTE LOOP
               do imin = start_min, end_min, min_stride
                  siyear  = sprinti("%0.4i", iyear)
                  simonth = sprinti("%0.2i", imonth)
                  siday   = sprinti("%0.2i", iday)
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
                        lat   = (/a->MSG_Latitude/)
                        lon   = (/a->MSG_Longitude/)
;                       lat   = (/a->MSG_Latitude(start_ind_lat:end_ind_lat, \
;                                                 start_ind_lon:end_ind_lon)/)
;                       lon   = (/a->MSG_Longitude(start_ind_lat:end_ind_lat,\
;                                                  start_ind_lon:end_ind_lon)/)
                        lat@_FillValue = bv3
                        lon@_FillValue = bv3
                     end if
                     Cloud_Optical_Thickness_16 = a->Cloud_Optical_Thickness_16
;                    Cloud_Optical_Thickness_16 = a->Cloud_Optical_Thickness_16(start_ind_lat:end_ind_lat, \
;                                                                               start_ind_lon:end_ind_lon)
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
                  (bv2, lat, lon, minlat, maxlat, minlon, maxlon, \
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
;  CALL SUBROUTINE plot_contour_grid_landmask_seviri.ncl TO PLOT MONTHLY IMAGE WITH BACKGROUND MAP ON IT
                     plot_contour_grid_landmask_seviri     \
                     (wks, minlat, maxlat, minlon, maxlon, \
                     element, cot16_grid, sdaily)
                  if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
                     polygon_map \
                     (wks, minlat, maxlat, minlon, maxlon, \
                     lat_pg, lon_pg)
                  end if
                  end if

                  delete([/cot16/])
               end do ;imin
            end do ;ihour
         end do ;iday
      end do ;imonth
   end do ;iyear
   print("Program ends at " + systemfunc("date"))
   end_time = get_cpu_time()
   duration = end_time - start_time
   print("Program costs " + duration)
end
