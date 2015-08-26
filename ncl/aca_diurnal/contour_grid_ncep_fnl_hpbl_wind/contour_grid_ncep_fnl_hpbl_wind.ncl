;  $ID: contour_grid_ncep_fnl_hpbl_wind_hour.ncl V01 08/12/2015 09:28 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_grid_ncep_fnl_hpbl_wind_hour.ncl READS PLANETARY BOUNDARY 
;  LAYER HEIGHT AND WINDS FROM NCEP FNL FILE, AND PLOTS THEM AS CONTOUR AND 
;  VECTOR, RESPECTIVELY.
;
;  FLOW CHART:
;  ============================================================================
;  (1 ) DO HOUR, YEAR, MONTH, AND DAY LOOPS;
;  (2 ) BUILD NCEP FNL FILE NAME AND READ VARIABLES;
;  (3 ) COLLECT ALL THE DATA INTO TOTAL ARRAY;
;  (4 ) END DAY LOOP;
;  (5 ) DO LAYER LOOP
;  (6 ) PLOT MONTHLY IMAGE;
;  (7 ) END LAYER, MONTH LOOP;
;  (8 ) DO LAYER LOOP;
;  (9 ) PLOT YEARLY IMAGE;
;  (10) END LAYER, YEAR LOOP;
;  (11) DO LAYER LOOP;
;  (12) PLOT TOTALLY IMAGE;
;  (13) END LAYER LOOP.
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/12/2015)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/build_ncep_fnl_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_contour_vector_hpbl.ncl"
begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   plot_dir   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/contour_grid_ncep_fnl_hpbl_wind/"
   wks        = gsn_open_wks(type, plot_dir + "1plot_contour_grid_ncep_fnl_hpbl_wind_v01_2007")
   gsn_define_colormap(wks,"BlGrYeOrReVi200")

;  NCEP FNL DATA DIRECTORY
   dir        = "/umbc/lustre/zzbatmos/common/Data/FNL/"

;  DEFINE BAD VALUE
   bv0        = "FillValue"
   bv1        = -9999
   bv2        = -9999.

;  SET UP LIMITED REGION
   minlat     =-40.
   maxlat     = 60.
   minlon     =-50.
   maxlon     = 70.
;  LATTITUDE AND LONGITUDE FOR STUDY REGION
   lat_pg     = (/minlat, minlat, maxlat, maxlat, minlat/)
   lon_pg     = (/minlon, maxlon, maxlon, minlon, minlon/)

;  SET UP THE START TIME AND END TIME
   start_year = 2007
   end_year   = 2007
   start_month= 7
   end_month  = 9
   start_day  = 1
   start_hour = 0
   end_hour   = 18
   hour_stride= 6

;  PARAMETERS FOR NCEP FNL VARIABLE DIMENSION SIZE
   nlat_0     = 181
   nlon_0     = 360
   nlv_ISBL0  = 26

;  SWITCH FOR PLOTTING
   plot_hourly  = True
   plot_monthly = True
   plot_yearly  = True
   plot_totally = True

;  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;  IN ORDER TO PLOT 359.0 DEGREE ~ 360.0 DEGREE CONTOUR, WE
;  INSERT ONE MORE LONGITUDE GRID
;  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
   lon = new((/nlon_0+1/), float, bv2)

   if (plot_totally) then
;  TOTAL VARIABLE DIMENSION
      nt_total   = 500
      dim2_total = (/nt_total, nlat_0, nlon_0+1/)
      dim3_total = (/nt_total, nlv_ISBL0, nlat_0, nlon_0+1/)
      u_total    = new(dim3_total, float, bv2)
      v_total    = new(dim3_total, float, bv2)
      hpbl_total = new(dim2_total, float, bv2)
   end if

   iloop_total = 0
;  DO HOUR LOOP
   do ihour = start_hour, end_hour, hour_stride
      sihour = sprinti("%0.2i", ihour)

      if (plot_hourly) then
;  HOUR VARIABLE DIMENSION
         nt_hour   = 500
         dim2_hour = (/nt_hour, nlat_0, nlon_0+1/)
         dim3_hour = (/nt_hour, nlv_ISBL0, nlat_0, nlon_0+1/)
         u_hour    = new(dim3_hour, float, bv2)
         v_hour    = new(dim3_hour, float, bv2)
         hpbl_hour = new(dim2_hour, float, bv2)
      end if

      iloop_hour = 0
;  DO YEAR LOOP
      do iyear = start_year, end_year
         siyear = sprinti("%0.2i", iyear)

         if (plot_yearly) then
;  YEAR VARIABLE DIMENSION
            nt_year   = 150
            dim2_year  = (/nt_year, nlat_0, nlon_0+1/)
            dim3_year  = (/nt_year, nlv_ISBL0, nlat_0, nlon_0+1/)
            u_year     = new(dim3_year, float, bv2)
            v_year     = new(dim3_year, float, bv2)
            hpbl_year  = new(dim2_year, float, bv2)
         end if

         iloop_year = 0
;  DO MONTH LOOP
         do imonth = start_month, end_month
            simonth = sprinti("%0.2i", imonth)
            if (plot_monthly) then
;  MONTH VARIABLE DIMENSION
               nt_month   = 31
               dim2_month = (/nt_month, nlat_0, nlon_0+1/)
               dim3_month = (/nt_month, nlv_ISBL0, nlat_0, nlon_0+1/)
               u_month    = new(dim3_month, float, bv2)
               v_month    = new(dim3_month, float, bv2)
               hpbl_month = new(dim2_month, float, bv2)
            end if

            iloop_month = 0
;  CALCULATE THE NUMBER OF DAYS IN THIS MONTH
            nday_month = days_in_month(iyear, imonth)
;  DO DAY LOOP
            do iday = start_day, nday_month
               siday = sprinti("%0.2i", iday)

;  DEFINE ARRAY FOR SUBROUTINE build_ncep_fnl_filename.ncl
               filename = new((/1/), string, bv0)
               extension= new((/1/), string, bv0)
;  CALL SUBROUTINE build_ncep_fnl_filename.ncl TO BUILD NCEP FNL FILE NAME
;  BASED ON THE YEAR, MONTH, DAY, HOUR, AND GRIB1 OR GRIB2
               build_ncep_fnl_filename \
               (iyear, imonth, iday, ihour, filename, extension)
               if (.not. fileexists(dir + siyear + "/" + filename)) then
                  print("NCEP FNL FILE NAME DOESN'T EXIST : " + filename)
                  continue
               end if
               print("NOW PROCESSING : " + filename)

;  READ VARIABLES FROM NCEP FNL FILE NAME
               a = addfile(dir + siyear + "/" + filename, "r")
               if (extension .eq. "grib1") then
;                 name = getfilevarnames(a)
;                 print(extension + " : " + name)
                  lat = (/a->lat_3/)
                  lon(0:nlon_0-1) = (/a->lon_3/)
                  lon(nlon_0)     = 360.
;  GRIB1 PRESSURE UNIT IS hPa
;  lv_ISBL3 IS 26 LEVELS, CONVERT P FROM INTEGER TO FLOAT
                  p   = (/a->lv_ISBL3/)*1.0
;  lv_ISBL7 IS 21 LEVELS
                  p21 = (/a->lv_ISBL7/)*1.0
                  hgt = (/a->HGT_3_ISBL/)
                  tmpk= (/a->TMP_3_ISBL/)
;  CONVERT TEMPERATURE UNIT FROM K TO C DEGREE
                  tmpc= tmpk - 273.15
;  R_H_3_ISBL HAS 21 LEVELS
                  rh21= (/a->R_H_3_ISBL/)
                  u   = (/a->U_GRD_3_ISBL/)
                  v   = (/a->V_GRD_3_ISBL/)
                  hpbl= (/a->HPBL_3_SFC/)
               else if (extension .eq. "grib2") then
;                name = getfilevarnames(a)
;                print(extension + " : " + name)
                  lat = (/a->lat_0/)
                  lon(0:nlon_0-1) = (/a->lon_0/)
                  lon(nlon_0)     = 360.
;  GRIB2 PRESSURE UNIT IS Pa
;  lv_ISBL0 IS 26 LEVELS, CONVERT Pa TO hPa
                  p   = (/a->lv_ISBL0/)*0.01
;  lv_ISBL4 IS 21 LEVELS
                  p21 = (/a->lv_ISBL4/)
;  CONVERT Pa TO hPa
                  p21 = p21*0.01
;  RH_P0_L100_GLL0 HAS 21 LEVELS
                  rh21= (/a->RH_P0_L100_GLL0/)
                  hgt = (/a->HGT_P0_L100_GLL0/)
                  tmpk= (/a->TMP_P0_L100_GLL0/)
;  CONVERT TEMPERATURE UNIT FROM K TO C DEGREE
                  tmpc= tmpk - 273.15
                  u   = (/a->UGRD_P0_L100_GLL0/)
                  v   = (/a->UGRD_P0_L100_GLL0/)
                  hpbl= (/a->HPBL_P0_L1_GLL0/)
               end if
               end if

;  INTERPOLATE 21-LEVEL rh21 TO 26-LEVEL rh
               rh = transpose(int2p(p21, transpose(rh21), p, 1))

;  CALCULATE DEW POINT TEMPERATURE WITH UNIT OF DEGREE C
               tdc = dewtemp_trh(tmpk, rh) - 273.15

;  CALCULATE WIND SPEED AND WIND DIRECTION
               wspd = sqrt(u^2 + v^2)
               wdir = wind_direction(u, v, 0)

;  ACCUMULATE ALL THE VARIABLE INTO DAY, MONTH, YEAR, AND TOTAL
               if (plot_hourly) then
                  u_hour   (iloop_hour, :, :, 0:nlon_0-1) = u(:, :, 0:nlon_0-1)
                  u_hour   (iloop_hour, :, :, nlon_0)     = u(:, :, 0)
                  v_hour   (iloop_hour, :, :, 0:nlon_0-1) = v(:, :, 0:nlon_0-1)
                  v_hour   (iloop_hour, :, :, nlon_0)     = v(:, :, 0)
                  hpbl_hour(iloop_hour, :, 0:nlon_0-1)    = hpbl(:, 0:nlon_0-1)
                  hpbl_hour(iloop_hour, :, nlon_0)        = hpbl(:, 0)
               end if
               if (plot_monthly) then
                  u_month   (iloop_month, :, :, 0:nlon_0-1) = u(:, :, 0:nlon_0-1)
                  u_month   (iloop_month, :, :, nlon_0)     = u(:, :, 0)
                  v_month   (iloop_month, :, :, 0:nlon_0-1) = v(:, :, 0:nlon_0-1)
                  v_month   (iloop_month, :, :, nlon_0)     = v(:, :, 0)
                  hpbl_month(iloop_month, :, 0:nlon_0-1)    = hpbl(:, 0:nlon_0-1)
                  hpbl_month(iloop_month, :, nlon_0)        = hpbl(:, 0)
               end if
               if (plot_yearly) then
                  u_year   (iloop_year, :, :, 0:nlon_0-1) = u(:, :, 0:nlon_0-1)
                  u_year   (iloop_year, :, :, nlon_0)     = u(:, :, 0)
                  v_year   (iloop_year, :, :, 0:nlon_0-1) = v(:, :, 0:nlon_0-1)
                  v_year   (iloop_year, :, :, nlon_0)     = v(:, :, 0)
                  hpbl_year(iloop_year, :, 0:nlon_0-1)    = hpbl(:, 0:nlon_0-1)
                  hpbl_year(iloop_year, :, nlon_0)        = hpbl(:, 0)
               end if
               if (plot_totally) then
                  u_total   (iloop_total, :, :, 0:nlon_0-1) = u(:, :, 0:nlon_0-1)
                  u_total   (iloop_total, :, :, nlon_0)     = u(:, :, 0)
                  v_total   (iloop_total, :, :, 0:nlon_0-1) = v(:, :, 0:nlon_0-1)
                  v_total   (iloop_total, :, :, nlon_0)     = v(:, :, 0)
                  hpbl_total(iloop_total, :, 0:nlon_0-1)    = hpbl(:, 0:nlon_0-1)
                  hpbl_total(iloop_total, :, nlon_0)        = hpbl(:, 0)
               end if
               iloop_hour  = iloop_hour  + 1
               iloop_month = iloop_month + 1
               iloop_year  = iloop_year  + 1
               iloop_total = iloop_total + 1
            end do ;iday

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT MONTHLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            if (plot_monthly) then
;  CALCULATE MONTHLY AVERAGE
               u_monthly    = dim_avg_n(u_month,    0)
               v_monthly    = dim_avg_n(v_month,    0)
               hpbl_monthly = dim_avg_n(hpbl_month, 0)
;  DO LAYER LOOP
               do ilayer = 0, nlv_ISBL0-1
                  stime = siyear + "-" + simonth + " " + \
                          sihour + ":00" + " " + "Level=" + p(ilayer) + "hPa"
;  CALL SUBROUTINE plot_contour_vector_hpbl.ncl TO PLOT CONTOUR WITH VECTOR
                  plot_contour_vector_hpbl \
                  (wks, minlat, maxlat, minlon, maxlon, stime, lat, lon, \
                  u_monthly(ilayer, :, :), v_monthly(ilayer, :, :), hpbl_monthly)
               end do
            end if
         end do ;imonth

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT YEARLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
         if (plot_yearly) then
;  CALCULATE YEARLY AVERAGE
            u_yearly    = dim_avg_n(u_year,    0)
            v_yearly    = dim_avg_n(v_year,    0)
            hpbl_yearly = dim_avg_n(hpbl_year, 0)
;  DO LAYER LOOP
            do ilayer = 0, nlv_ISBL0-1
               stime = siyear + " " + sihour + \
                       ":00" + " " + "Level=" + p(ilayer) + "hPa"
;  CALL SUBROUTINE plot_contour_vector_hpbl.ncl TO PLOT CONTOUR WITH VECTOR
               plot_contour_vector_hpbl \
               (wks, minlat, maxlat, minlon, maxlon, stime, lat, lon, \
               u_yearly(ilayer, :, :), v_yearly(ilayer, :, :), hpbl_yearly)
            end do
         end if
      end do ;iyear

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT HOURLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
      if (plot_hourly) then
;  CALCULATE HOURLY AVERAGE
         u_hourly    = dim_avg_n(u_hour,    0)
         v_hourly    = dim_avg_n(v_hour,    0)
         hpbl_hourly = dim_avg_n(hpbl_hour, 0)
;  DO LAYER LOOP
         do ilayer = 0, nlv_ISBL0-1
            stime = start_year + "-" + end_year + " " + \
                    sihour + ":00" + " " + "Level=" + p(ilayer) + "hPa"
;  CALL SUBROUTINE plot_contour_vector_hpbl.ncl TO PLOT CONTOUR WITH VECTOR
            plot_contour_vector_hpbl \
            (wks, minlat, maxlat, minlon, maxlon, stime, lat, lon, \
            u_hourly(ilayer, :, :), v_hourly(ilayer, :, :), hpbl_hourly)
         end do
      end if

   end do ;ihour

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT TOTALLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   if (plot_totally) then
;  CALCULATE TOTALLY AVERAGE
         u_totally    = dim_avg_n(u_total,    0) 
         v_totally    = dim_avg_n(v_total,    0) 
         hpbl_totally = dim_avg_n(hpbl_total, 0) 
;  DO LAYER LOOP
         do ilayer = 0, nlv_ISBL0-1
            stime = start_year + "-" + end_year + " " \
                    + "Level=" + p(ilayer) + "hPa"
;  CALL SUBROUTINE plot_contour_vector_hpbl.ncl TO PLOT CONTOUR WITH VECTOR
            plot_contour_vector_hpbl \
            (wks, minlat, maxlat, minlon, maxlon, stime, lat, lon, \
            u_totally(ilayer, :, :), v_totally(ilayer, :, :), hpbl_totally)
         end do

   end if
end
