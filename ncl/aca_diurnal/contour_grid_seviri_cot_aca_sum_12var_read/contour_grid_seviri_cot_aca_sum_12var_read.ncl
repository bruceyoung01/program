;  $ID: contour_grid_seviri_cot_aca_sum_12var_read.ncl V01 06/23/2015 14:45 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_grid_seviri_cot_aca_sum_12var_read.ncl READS THE OUTPUT FILE 
;  FROM PROGRAM contour_grid_seviri_cot_aca.ncl, AND PLOTS THE TREND LINE PLOT 
;  FOR CLOUD OPTICAL THICKNESS, AND OTHER PARAMETERS.
;
;  PROGRAM FLOW CHART:
;  ============================================================================
;  (1 ) READ SEVIRI OUTPUT FILE;
;  (2 ) COLLECT ALL THE DATA;
;  (3 ) PLOT WITH CONTOUR IMAGE.
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (6/23/2015)
;  (2 ) SINCE NCL CAN ONLY OPEN 15 WORK STATIONS AT ONE TIME, WE CAN'T DO THE 
;       CASES, METHODS LOOP, INSTEAD WE USE SLURM TO SUBMIT MULTIPLE PROCESSES 
;       ONE BY ONE. AFTER ONE PROCESS IS DONE WTIH ONE CASE AND ONE METHOD, THE 
;       SECOND PROCESS WILL BE SUBMITTED, AND SO FORTH. PLEASE SEE THE SLURM 
;       SCRIPT FOR DETAIL (submit_multi.slurm, BRUCE, 07/05/2015)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/gsn_csm_epa.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/grid_lat_lon.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/match_touch_untouch_noaca_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_seviri_filename_hour_min.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/read_ascii_seviri_caliop.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_contour_grid_seviri_9var.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
;  type       = "pdf"
   type       = "png"
   plot_dir   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/contour_grid_seviri_cot_aca_sum_9var_read/"
   plot_name  = "1plot_contour_grid_seviri_cot_aca_sum_9var_read_v02"

;  DATA DIRECTORY
   dir        = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/contour_grid_seviri_cot_aca/"
   filelist   = "filelist_ESMF_v03"

;  DEFINE BAD VALUE
   bv1        = -9999
   bv2        = -9999.

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
   start_year   = 2008
   end_year     = 2008
   start_month  = 6
   end_month    = 6
   start_day    = 1
   start_hour   = 0
   end_hour     = 23
   start_min    = 0
   end_min      = 45
   min_interval = 15
   nhour        = 24
   nmin         = 4

;  SWITCH FOR DIFFERENT CASES
;  TWO METHODS: C2010-Costantino_2010; C2013-Costantino_2013
;  FOR Costantino_2010
;  "all"     : ALL THE CASES INCLUDING ACA AND CLOUD WITH UNTOUCH AND TOUCH
;  "untouch" : UNTOUCH ACA AND CLOUD
;  "touch"   : TOUCH ACA AND CLOUD
;  FOR Costantino_2013, BESIDES FOR Costantino, ONE MORE CASE
;  "uncertain" : UNCERTAIN ABOUT WHETHER ACA AND CLOUD TOUCH OT UNTOUCH
   method        = (/"C2010", "C2013"/)
   case          = (/"all", "untouch", "touch", "noaca", "uncertain"/)
   sday_or_night = (/"D", "N"/)
   nmethod       = dimsizes(method)
   ncase         = dimsizes(case)
   nday_or_night = dimsizes(sday_or_night)

   nobs          = 1000
   nctrack       = 3
   ncount_write  = 100
   ncount_write_day = nctrack*ncount_write

;  CALL SUBROUTINE match_touch_untouch_noaca_filename.ncl TO MATCH FILE NAMES FOR 
;  CASES, METHODS, AND DAY_OR_NIGHT IN THE SAME YEAR, MONTH, DAY, HOUR, AND MINUTTE
   match_touch_untouch_noaca_filename \
   (dir, start_year, end_year, start_month, end_month, start_day,  \
   start_hour, end_hour, start_min, end_min, min_interval, method, \
   case, sday_or_night, filelist)
   filename   = asciiread(dir + filelist, -1, "string")
   nfilename  = dimsizes(filename)

;  DEFINE NEW ARRAY TO READ DATA
   nvariable     = 16
   dim           = (/ncase, nmethod, nvariable, nhour, nmin, nobs, ncount_write_day/)
   seviri_data   = new(dim, float, bv2)
   variable_name = new((/nvariable/), string)

;  DEFINE ARRAY FOR GRIDDED LATITUDE AND LONGITUDE ARRAY
   nlat          = floattoint((maxlat-minlat)/lat_grid_size) + 2
   nlon          = floattoint((maxlon-minlon)/lon_grid_size) + 2
   dim_2d        = (/nlat, nlon/)
   lat_grid_1d   = new((/nlat/), float, bv2)
   lon_grid_1d   = new((/nlon/), float, bv2)
   lat_grid_2d   = new(dim_2d, float, bv2)
   lon_grid_2d   = new(dim_2d, float, bv2)

;  CALL SUBROUTINE grid_lat_lon.ncl TO GENERATE GRIDDED LATITUDE AND LONGITUDE
   grid_lat_lon \
   (minlat, maxlat, minlon, maxlon, lat_grid_size, lon_grid_size, \
    lat_grid_1d, lon_grid_1d, lat_grid_2d, lon_grid_2d)

;  OPEN MULTIPLE WORKSTATION FOR DIFFERENT CASES, METHODS, VARIABLES
   wks          = new((/ncase, nmethod, nvariable/), graphic)
;  do icase = 0, ncase-1
;     do imethod = 0, nmethod-1
         do ivariable = 0, nvariable-1
            svariable = sprinti("%0.2i", ivariable)
            wks(icase, imethod, ivariable) = gsn_open_wks(type, plot_dir + plot_name + "_" + \
                                                          case(icase) + "_" + method(imethod) + "_" + svariable)
         end do ;ivariable
;     end do ;imethod
;  end do ;icase

;  DO method AND case LOOP TO GET ALL THE METHDS AND CASES
;  do icase = 0, ncase-1
;     do imethod = 0, nmethod-1
;  COMBINE THE CASE AND METHOD TOGETHER FOR PLOTTING
         if (icase .eq. 3 .and. imethod .eq. 0) then
            continue
         end if
         scasemethod = case(icase) + " " + \
                       method(imethod)
         iloop = 0
;  DO HOUR LOOP TO COLLECT ALL THE DATA
         do ihour = start_hour, end_hour
;  DO MINUTE LOOP
            imin_loop = 0
            do imin = start_min, end_min, min_interval
               sihour = sprinti("%0.2i", ihour)
               simin  = sprinti("%0.2i", imin)
               stime  = sihour + ":" + simin + ":00"
               print("Time = " + stime)
               nsfilename      = 100
               sfilename       = new((/nsfilename/), string)
               nsfilename_real = new(1, integer)
               logic_continue  = False
;  CALL SUBROUTINE select_seviri_filename_hour_min.ncl TO SELECT SEVIRI OUTPUT 
;  FILE NAME BASED ON THE CASE, METHOD, HOUR, AND MINUTE
               select_seviri_filename_hour_min \
               (filename, case(icase), method(imethod), ihour, imin, \
               sfilename, nsfilename_real, logic_continue)

               if (logic_continue) then
                  print("NO SEVIRI OUTPUT FILE ON " + stime)
                  continue
               end if

;  DO nsfilename_real LOOP TO READ IN ALL THE DATA
               do isfilename_real = 0, nsfilename_real-1
                  print("Now processing = " + sfilename(isfilename_real))
;  CALL SUBROUTINE read_ascii_seviri_caliop_9var.ncl TO READ THE DATA
                  read_ascii_seviri_caliop_9var                    \
                  (dir, sfilename(isfilename_real), nvariable, variable_name, \
                  seviri_data(icase, imethod, :, ihour, imin_loop, iloop, :))
                  iloop = iloop + 1
               end do ;isfilename_real

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
         seviri_lat = ndtooned(seviri_data(icase, imethod, 0, ihour, imin_loop, :, :))
         seviri_lon = ndtooned(seviri_data(icase, imethod, 1, ihour, imin_loop, :, :))
         seviri_var = new((/nvariable, nobs*ncount_write_day/), float, bv2)
         do iivariable = 0, nvariable-1
            seviri_var(iivariable, :) = ndtooned(seviri_data(icase, imethod, iivariable, ihour, imin_loop, :, :))
         end do
         data_3d    = new((/nvariable, nlat, nlon/), float, bv2)
;  CONVERT VARIABLE FROM 1-D TO 2-D WITH 1ST D IS LATITUDE, 2ND IS LONGITUDE
            do ilat = 0, nlat-1
               do ilon = 0, nlon-1
                  index_latlon = ind(seviri_lat .eq. lat_grid_1d(ilat) .and. \
                                     seviri_lon .eq. lon_grid_1d(ilon))
                  if (.not.all(ismissing(index_latlon)) .and. \
                      .not.all(ismissing(seviri_var(:, index_latlon)))) then        
                     nindex_lat_lon = dimsizes(index_latlon)
                     if (nindex_lat_lon .eq. 1) then
                        data_3d(:, ilat, ilon) = seviri_var(:, index_latlon)
                     else if (nindex_lat_lon .gt. 1)
                        data_3d(:, ilat, ilon) = dim_avg_n(seviri_var(:, index_latlon), 1)
                     end if
                     end if
                  end if
                  delete([/index_latlon/])
               end do
            end do

;  DO IVARIABLE LOOP TO PLOT CONTOUR FOR EACH VARIABLE
         do ivariable = 2, nvariable-3
            data      = (/data_3d(ivariable, :, :)/)
            data_oned = ndtooned(data)
            if (all(ismissing(data))) then
               continue
            end if
            index  = ind(.not.ismissing(data_oned))
            nindex = dimsizes(index)
            if (.not.all(ismissing(data)) .and. \
                max(data) .ne. min(data)  .and. \
                nindex .gt. 3) then
;  CALL SUBROUTINE plot_contour_grid_seviri_9var.ncl TO PLOT EVERY VARIABLE
               plot_contour_grid_seviri_9var \
               (wks(icase, imethod, ivariable), ivariable, scasemethod, \
               minlat, maxlat, minlon, maxlon, \
               lat_grid_1d, lon_grid_1d, data, stime)
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
               polygon_map \
               (wks(icase, imethod, ivariable), minlat, maxlat, minlon, maxlon, \
               lat_pg, lon_pg)
            end if
            delete([/index/])
         end do ;ivariable

               imin_loop = imin_loop + 1
            end do ;imin
         end do ;ihour
;     end do ;imethod
;  end do ;icase

end
