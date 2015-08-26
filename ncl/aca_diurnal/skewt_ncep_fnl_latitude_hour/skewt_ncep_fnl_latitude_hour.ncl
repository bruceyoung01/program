;  $ID: skewt_ncep_fnl_latitude_hour.ncl V01 08/07/2015 12:02 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM skewt_ncep_fnl_latitude_hour.ncl READS NCEP FNL DATA, CALCULATES 
;  LATITUDE ZONAL AVERAGE, AND PLOTS SKEW-T DIAGRAM FOR DIFFERENT HOURS.
;
;  FLOW CHART:
;  ============================================================================
;  (1 ) DO LATITUDE LOOP WITH 4 DEGREE AS INCREMENT;
;  (2 ) DO HOUR, YEAR, MONTH, AND DAY LOOP;
;  (3 ) READ THE FNL VARIABLES;
;       THE REQUIRED VARIABLE NAMES : PRESSURE, TEMPERATURE, DEW POINT 
;       TEMPERATURE(DERIVED), GEOPOTENTIAL HEIGHT, WIND SPEED, WIND DIRECTION;
;  (4 ) SELECT ALL THE FNL DATA LOCATED IN THE SPECIFIC LATITUDE & LONGITUDE;
;  (5 ) IF FNL DATA EXIST, AVERAGE THEM;
;  (6 ) END OF DAY, MONTH, YEAR, AND HOUR LOOP;
;  (7 ) END OF LATITUDE LOOP;
;  (8 ) PLOT ALL THE AVERAGED DATA USING SKEW-T DIAGRAM.
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/07/2015)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/skewt_func.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/build_ncep_fnl_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/calculate_grid_average_ncep_fnl_latitude.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_skewt_ncep_fnl.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   plot_dir   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/skewt_ncep_fnl_latitude_hour/"
   wks        = gsn_open_wks(type, plot_dir + "1plot_skewt_ncep_fnl_latitude_hour_v01_2007")
   gsn_define_colormap(wks,"WhBlGrYeOrReVi202")

;  NCEP FNL DATA DIRECTORY
   dir        = "/umbc/lustre/zzbatmos/common/Data/FNL/"

;  DEFINE BAD VALUE
   bv0        = "FillValue"
   bv1        = -9999
   bv2        = -9999.

;  SET UP LIMITED REGION
   minlat     =-30
   maxlat     = 10
   minlon     =-20
   maxlon     = 20

;  SET UP THE START TIME AND END TIME
   start_year = 2007
   end_year   = 2007
   start_month= 7
   end_month  = 7
   start_day  = 1
   start_hour = 0
   end_hour   = 18
   hour_stride= 6

;  SPLIT THE STUDY REGION INTO THE NEW LATITUDE INTERVAL, 
;  IN ORDER TO CALCULATE THE AVERAGE
   lat_stride = 4
   lat2       = ispan(minlat, maxlat, lat_stride)
   nlat2      = dimsizes(lat2)

;  PARAMETERS FOR NCEP FNL VARIABLE DIMENSION SIZE
   nlat_0     = 181
   nlon_0     = 360
   nlv_ISBL0  = 26

;  SWITCH FOR PLOTTING
   plot_hourly  = True
   plot_monthly = True
   plot_yearly  = True
   plot_totally = True

;  DO LATITUDE LOOP
   do ilat = 0, nlat2-2
      print("Latitude : " + lat2(ilat))
;  LATITUDE AND LONGITUDE FOR STUDY REGION
      lat_pg = (/lat2(ilat), lat2(ilat), lat2(ilat+1), lat2(ilat+1), lat2(ilat)/)
      lon_pg = (/minlon, maxlon, maxlon, minlon, minlon/)

      if (plot_totally) then
;  TOTAL VARIABLE DIMENSION
         nt_total   = 5000
         dim_total  = (/nt_total, nlv_ISBL0/)
         hgt_total  = new(dim_total, float, bv2)
         tmpc_total = new(dim_total, float, bv2)
         tdc_total  = new(dim_total, float, bv2)
         wspd_total = new(dim_total, float, bv2)
         wdir_total = new(dim_total, float, bv2)
      end if

      iloop_total = 0
;  DO HOUR LOOP
      do ihour = start_hour, end_hour, hour_stride
         sihour = sprinti("%0.2i", ihour)

         if (plot_hourly) then
;  HOUR VARIABLE DIMENSION
            nt_hourt   = 500
            dim_hourt  = (/nt_hourt, nlv_ISBL0/)
            hgt_hourt  = new(dim_hourt, float, bv2)
            tmpc_hourt = new(dim_hourt, float, bv2)
            tdc_hourt  = new(dim_hourt, float, bv2)
            wspd_hourt = new(dim_hourt, float, bv2)
            wdir_hourt = new(dim_hourt, float, bv2)
         end if

         iloop_hour = 0
;  DO YEAR LOOP
         do iyear = start_year, end_year
            siyear = sprinti("%0.2i", iyear)

            if (plot_yearly) then
;  YEAR VARIABLE DIMENSION
               nt_year   = 150
               dim_year  = (/nt_year, nlv_ISBL0/)
               hgt_year  = new(dim_year, float, bv2)
               tmpc_year = new(dim_year, float, bv2)
               tdc_year  = new(dim_year, float, bv2)
               wspd_year = new(dim_year, float, bv2)
               wdir_year = new(dim_year, float, bv2)
            end if

            iloop_year = 0
;  DO MONTH LOOP
            do imonth = start_month, end_month
               simonth = sprinti("%0.2i", imonth)

               if (plot_monthly) then
;  MONTH VARIABLE DIMENSION
                  nt_month   = 31
                  dim_month  = (/nt_month, nlv_ISBL0/)
                  hgt_month  = new(dim_month, float, bv2)
                  tmpc_month = new(dim_month, float, bv2)
                  tdc_month  = new(dim_month, float, bv2)
                  wspd_month = new(dim_month, float, bv2)
                  wdir_month = new(dim_month, float, bv2)
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
;                    name = getfilevarnames(a)
;                    print(extension + " : " + name)
                     lat = (/a->lat_3/)
                     lon = (/a->lon_3/)
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
                  else if (extension .eq. "grib2") then
;                   name = getfilevarnames(a)
;                   print(extension + " : " + name)
                     lat = (/a->lat_0/)
                     lon = (/a->lon_0/)
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
                  end if
                  end if

;  INTERPOLATE 21-LEVEL rh21 TO 26-LEVEL rh
                  rh = transpose(int2p(p21, transpose(rh21), p, 1))

;  CALCULATE DEW POINT TEMPERATURE WITH UNIT OF DEGREE C
                  tdc = dewtemp_trh(tmpk, rh) - 273.15

;  CALCULATE WIND SPEED AND WIND DIRECTION
                  wspd = sqrt(u^2 + v^2)
                  wdir = wind_direction(u, v, 0)

;  DEFINE ARRAY FOR SUBROUTINE calculate_grid_average_ncep_fnl_latitude.ncl
                  dim       = (/nlv_ISBL0/)
                  hgt_hour  = new(dim, float, bv2)
                  tmpc_hour = new(dim, float, bv2)
                  tdc_hour  = new(dim, float, bv2)
                  wspd_hour = new(dim, float, bv2)
                  wdir_hour = new(dim, float, bv2)

;  CALL SUBROUTINE calculate_grid_average_ncep_fnl_latitude.ncl TO CALCULATE 
;  GRID AVERAGE ALONG SPECIFIC LATITUDE FOR NCEP FNL
                  calculate_grid_average_ncep_fnl_latitude \
                  (lat2, ilat, minlon, maxlon, lat, lon,   \
                  hgt, tmpc, tdc, wspd, wdir,              \
                  hgt_hour, tmpc_hour, tdc_hour, wspd_hour, wdir_hour)
;  ACCUMULATE ALL THE VARIABLE INTO DAY, MONTH, YEAR, AND TOTAL
                  if (plot_hourly) then
                     hgt_hourt(iloop_hour, :)   = hgt_hour
                     tmpc_hourt(iloop_hour, :)  = tmpc_hour
                     tdc_hourt(iloop_hour, :)   = tdc_hour
                     wspd_hourt(iloop_hour, :)  = wspd_hour
                     wdir_hourt(iloop_hour, :)  = wdir_hour
                  end if
                  if (plot_monthly) then
                     hgt_month(iloop_month, :)  = hgt_hour
                     tmpc_month(iloop_month, :) = tmpc_hour
                     tdc_month(iloop_month, :)  = tdc_hour
                     wspd_month(iloop_month, :) = wspd_hour
                     wdir_month(iloop_month, :) = wdir_hour
                  end if
                  if (plot_yearly) then
                     hgt_year(iloop_year, :)    = hgt_hour
                     tmpc_year(iloop_year, :)   = tmpc_hour
                     tdc_year(iloop_year, :)    = tdc_hour
                     wspd_year(iloop_year, :)   = wspd_hour
                     wdir_year(iloop_year, :)   = wdir_hour
                  end if
                  if (plot_totally) then
                     hgt_total(iloop_total, :)  = hgt_hour
                     tmpc_total(iloop_total, :) = tmpc_hour
                     tdc_total(iloop_total, :)  = tdc_hour
                     wspd_total(iloop_total, :) = wspd_hour
                     wdir_total(iloop_total, :) = wdir_hour
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
                  stime = siyear + "-" + simonth + " " + sihour + ":00"
;  CALCULATE MONTHLY AVERAGE
                  hgt_monthly  = dim_avg_n(hgt_month,  0)
                  tmpc_monthly = dim_avg_n(tmpc_month, 0)
                  tdc_monthly  = dim_avg_n(tdc_month,  0)
                  wspd_monthly = dim_avg_n(wspd_month, 0)
                  wdir_monthly = dim_avg_n(wdir_month, 0)
;  CALL SUBROUTINE plot_skewt_ncep_fnl.ncl TO PLOT SKEW-T DIAGRAM
                  plot_skewt_ncep_fnl \
                  (wks, stime, p, tmpc_monthly, tdc_monthly, \
                  hgt_monthly, wspd_monthly, wdir_monthly)
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
                  polygon_map \
                  (wks, minlat, maxlat, minlon, maxlon, \
                  lat_pg, lon_pg)

               end if
            end do ;imonth

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT YEARLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            if (plot_yearly) then
                  stime = siyear + " " + sihour + ":00"
;  CALCULATE YEARLY AVERAGE
               hgt_yearly  = dim_avg_n(hgt_year,  0)
               tmpc_yearly = dim_avg_n(tmpc_year, 0)
               tdc_yearly  = dim_avg_n(tdc_year,  0)
               wspd_yearly = dim_avg_n(wspd_year, 0)
               wdir_yearly = dim_avg_n(wdir_year, 0)
;  CALL SUBROUTINE plot_skewt_ncep_fnl.ncl TO PLOT SKEW-T DIAGRAM
               plot_skewt_ncep_fnl \
               (wks, stime, p, tmpc_yearly, tdc_yearly, \
               hgt_yearly, wspd_yearly, wdir_yearly)
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
               polygon_map \
               (wks, minlat, maxlat, minlon, maxlon, \
               lat_pg, lon_pg)

            end if
         end do ;iyear

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT HOURLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
         if (plot_hourly) then
            stime = start_year + "-" + end_year + " " + sihour + ":00"
;  CALCULATE HOURLY AVERAGE
            hgt_hourly  = dim_avg_n(hgt_hourt,  0)
            tmpc_hourly = dim_avg_n(tmpc_hourt, 0)
            tdc_hourly  = dim_avg_n(tdc_hourt,  0)
            wspd_hourly = dim_avg_n(wspd_hourt, 0)
            wdir_hourly = dim_avg_n(wdir_hourt, 0)
;  CALL SUBROUTINE plot_skewt_ncep_fnl.ncl TO PLOT SKEW-T DIAGRAM
            plot_skewt_ncep_fnl \
            (wks, stime, p, tmpc_hourly, tdc_hourly, \
            hgt_hourly, wspd_hourly, wdir_hourly)
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
            polygon_map \
            (wks, minlat, maxlat, minlon, maxlon, \
            lat_pg, lon_pg)
         end if
      end do ;ihour

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT TOTALLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
      if (plot_totally) then
         stime = start_year + "-" + end_year
;  CALCULATE TOTALLY AVERAGE
         hgt_totally  = dim_avg_n(hgt_total,  0) 
         tmpc_totally = dim_avg_n(tmpc_total, 0) 
         tdc_totally  = dim_avg_n(tdc_total,  0) 
         wspd_totally = dim_avg_n(wspd_total, 0) 
         wdir_totally = dim_avg_n(wdir_total, 0) 
;  CALL SUBROUTINE plot_skewt_ncep_fnl.ncl TO PLOT SKEW-T DIAGRAM
         plot_skewt_ncep_fnl \
         (wks, stime, p, tmpc_totally, tdc_totally, \
         hgt_totally, wspd_totally, wdir_totally)
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
         polygon_map \ 
         (wks, minlat, maxlat, minlon, maxlon, \ 
         lat_pg, lon_pg)
      end if

   end do ;ilat

end
