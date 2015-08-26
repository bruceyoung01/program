;  $ID: contour_vertical_ncep_fnl_latitude.ncl V01 08/09/2015 19:32 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_vertical_ncep_fnl_latitude.ncl READS NCEP FNL VARIABLES AND
;  SELECTS LATITUDE ZONE THEN CALCULATES ZONAL AVERAGE, FINALLY PLOTS VERTICAL 
;  CONTOUR ALONG WITH THE LATITUDE LINE.
;
;  FLOW CHART:
;  ============================================================================
;  (1 ) DO LATITUDE LOOP WITH 4 DEGREE AS INCREMENT;
;  (2 ) DO YEAR, MONTH, DAY, AND HOUR LOOP;
;  (3 ) READ THE FNL VARIABLES;
;       THE REQUIRED VARIABLE NAMES : PRESSURE, TEMPERATURE, DEW POINT 
;       TEMPERATURE(DERIVED), GEOPOTENTIAL HEIGHT, WIND SPEED, WIND DIRECTION;
;  (4 ) SELECT ALL THE FNL DATA LOCATED IN THE SPECIFIC LATITUDE & LONGITUDE;
;  (5 ) IF FNL DATA EXIST, AVERAGE THEM ALONG THE LATITUDE ZONE
;  (6 ) END OF YEAR, MONTH, DAY, AND HOUR LOOP;
;  (7 ) END OF LATITUDE LOOP;
;  (8 ) PLOT ALL THE AVERAGED DATA AS VERTICAL CONTOUR/LINE.
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/09/2015)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/build_ncep_fnl_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/calculate_zonal_average_ncep_fnl_latitude.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/collect_ncep_fnl_tymd_latitude.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_contour_pres_hgt_vector.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   plot_dir   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/contour_vertical_ncep_fnl_latitude/"
   wks        = gsn_open_wks(type, plot_dir + "1plot_contour_vertical_ncep_fnl_latitude_tdc_v02")
   gsn_define_colormap(wks,"BlGrYeOrReVi200")

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
   end_month  = 9
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
   vvel_factor= 50.

;  SINCE LONGITUDE IS FROM 0~360. WE NEED THE INDEX OF 0~20 AND 339~358, WHICH 
;  ARE CORRESPONDING TO 0~20 AND -20~-1. WE NEED TO COMBINE THESE TWO PARTS 
;  TOGETHER WITH TOTAL ELEMENTS OF 41.
   start_lon_ind1    = 0
   end_lon_ind1      = 20
   start_lon_ind2    = 340
   end_lon_ind2      = 359
   start_nlon_0_com1 = 0
   end_nlon_0_com1   = 19
   start_nlon_0_com2 = 20
   end_nlon_0_com2   = 40
   nlon_0_com        = 41
;  PARAMETER FOR PLOT
   npts              = 5

;  SWITCH FOR PLOTTING
   plot_daily   = False
   plot_monthly = False
   plot_yearly  = True
   plot_totally = True

;  CREATE AN ARRAY TO HOLD LONGITUDE FOR PLOT
   lon_t        = new((/nlon_0_com/), float, bv2)

;  DO LATITUDE LOOP
   do ilat = 0, nlat2-2
;  LATITUDE AND LONGITUDE FOR STUDY REGION
      lat_pg = (/lat2(ilat), lat2(ilat), lat2(ilat+1), lat2(ilat+1), lat2(ilat)/)
      lon_pg = (/minlon, maxlon, maxlon, minlon, minlon/)

      if (plot_totally) then
;  TOTAL VARIABLE DIMENSION
         nt_total   = 5000
         dim_total  = (/nt_total, nlv_ISBL0, nlon_0_com/)
         hgt_total  = new(dim_total, float, bv2)
         tmpc_total = new(dim_total, float, bv2)
         tdc_total  = new(dim_total, float, bv2)
         u_total    = new(dim_total, float, bv2)
         v_total    = new(dim_total, float, bv2)
         vvel_total = new(dim_total, float, bv2)
         wspd_total = new(dim_total, float, bv2)
         wdir_total = new(dim_total, float, bv2)
      end if

      iloop_total = 0
;  DO YEAR LOOP
      do iyear = start_year, end_year
         siyear = sprinti("%0.4i", iyear)

         if (plot_yearly) then
;  YEAR VARIABLE DIMENSION
            nt_year   = 500
            dim_year  = (/nt_year, nlv_ISBL0, nlon_0_com/)
            hgt_year  = new(dim_year, float, bv2)
            tmpc_year = new(dim_year, float, bv2)
            tdc_year  = new(dim_year, float, bv2)
            u_year    = new(dim_year, float, bv2)
            v_year    = new(dim_year, float, bv2)
            vvel_year = new(dim_year, float, bv2)
            wspd_year = new(dim_year, float, bv2)
            wdir_year = new(dim_year, float, bv2)
         end if

         iloop_year = 0
;  DO MONTH LOOP
         do imonth = start_month, end_month
            simonth = sprinti("%0.2i", imonth)

            if (plot_monthly) then
;  MONTH VARIABLE DIMENSION
               nt_month   = 150
               dim_month  = (/nt_month, nlv_ISBL0, nlon_0_com/)
               hgt_month  = new(dim_month, float, bv2)
               tmpc_month = new(dim_month, float, bv2)
               tdc_month  = new(dim_month, float, bv2)
               u_month    = new(dim_month, float, bv2)
               v_month    = new(dim_month, float, bv2)
               vvel_month = new(dim_month, float, bv2)
               wspd_month = new(dim_month, float, bv2)
               wdir_month = new(dim_month, float, bv2)
            end if

            iloop_month = 0
;  CALCULATE THE NUMBER OF DAYS IN THIS MONTH
            nday_month = days_in_month(iyear, imonth)
;  DO DAY LOOP
            do iday = start_day, nday_month
               siday = sprinti("%0.2i", iday)

               if (plot_daily) then
;  DAY VARIABLE DIMENSION
                  nt_day   = 4
                  dim_day  = (/nt_day, nlv_ISBL0, nlon_0_com/)
                  hgt_day  = new(dim_day, float, bv2)
                  tmpc_day = new(dim_day, float, bv2)
                  tdc_day  = new(dim_day, float, bv2)
                  u_day    = new(dim_day, float, bv2)
                  v_day    = new(dim_day, float, bv2)
                  vvel_day = new(dim_day, float, bv2)
                  wspd_day = new(dim_day, float, bv2)
                  wdir_day = new(dim_day, float, bv2)
               end if

               iloop_day = 0
;  DO HOUR LOOP
               do ihour = start_hour, end_hour, hour_stride
                  sihour = sprinti("%0.2i", ihour)

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
                     lat    = (/a->lat_3/)
                     lon    = (/a->lon_3/)
;  GRIB1 PRESSURE UNIT IS hPa
;  lv_ISBL3 IS 26 LEVELS, CONVERT P FROM INTEGER TO FLOAT
                     p      = (/a->lv_ISBL3/)*1.0
;  lv_ISBL7 IS 21 LEVELS
                     p21    = (/a->lv_ISBL7/)*1.0
                     hgt    = (/a->HGT_3_ISBL/)
                     tmpk   = (/a->TMP_3_ISBL/)
;  CONVERT TEMPERATURE UNIT FROM K TO C DEGREE
                     tmpc   = tmpk - 273.15
;  R_H_3_ISBL HAS 21 LEVELS
                     rh21   = (/a->R_H_3_ISBL/)
                     u      = (/a->U_GRD_3_ISBL/)
                     v      = (/a->V_GRD_3_ISBL/)
                     vvel21 = (/a->V_VEL_3_ISBL/)
                  else if (extension .eq. "grib2") then
;                   name = getfilevarnames(a)
;                   print(extension + " : " + name)
                     lat    = (/a->lat_0/)
                     lon    = (/a->lon_0/)
;  GRIB2 PRESSURE UNIT IS Pa
;  lv_ISBL0 IS 26 LEVELS, CONVERT Pa TO hPa
                     p      = (/a->lv_ISBL0/)*0.01
;  lv_ISBL4 IS 21 LEVELS
                     p21    = (/a->lv_ISBL4/)
;  CONVERT Pa TO hPa
                     p21    = p21*0.01
;  RH_P0_L100_GLL0 HAS 21 LEVELS
                     rh21   = (/a->RH_P0_L100_GLL0/)
                     hgt    = (/a->HGT_P0_L100_GLL0/)
                     tmpk   = (/a->TMP_P0_L100_GLL0/)
;  CONVERT TEMPERATURE UNIT FROM K TO C DEGREE
                     tmpc   = tmpk - 273.15
                     u      = (/a->UGRD_P0_L100_GLL0/)
                     v      = (/a->UGRD_P0_L100_GLL0/)
                     vvel21 = (/a->VVEL_P0_L100_GLL0/)
                  end if
                  end if

;  INTERPOLATE 21-LEVEL rh21 TO 26-LEVEL rh
                  rh   = transpose(int2p(p21, transpose(rh21), p, 1))
;  INTERPOLATE 21-LEVEL vvel21 TO 26-LEVEL vvel
                  vvel = transpose(int2p(p21, transpose(vvel21), p, 1))

;  CALCULATE DEW POINT TEMPERATURE
                  tdc  = dewtemp_trh(tmpk, rh) - 273.15

;  CALCULATE WIND SPEED AND WIND DIRECTION
                  wspd = sqrt(u^2 + v^2)
                  wdir = wind_direction(u, v, 0)

;  DEFINE ARRAY FOR SUBROUTINE calculate_grid_average_ncep_fnl_latitude.ncl
                  dim       = (/nlv_ISBL0, nlon_0/)
                  hgt_hour  = new(dim, float, bv2)
                  tmpc_hour = new(dim, float, bv2)
                  tdc_hour  = new(dim, float, bv2)
                  u_hour    = new(dim, float, bv2)
                  v_hour    = new(dim, float, bv2)
                  vvel_hour = new(dim, float, bv2)
                  wspd_hour = new(dim, float, bv2)
                  wdir_hour = new(dim, float, bv2)

;  CALL SUBROUTINE calculate_zonal_average_ncep_fnl_latitude.ncl TO CALCULATE 
;  GRID AVERAGE ALONG SPECIFIC LATITUDE FOR NCEP FNL
                  calculate_zonal_average_ncep_fnl_latitude \
                  (lat2, ilat, minlon, maxlon, lat, lon,    \
                  hgt, tmpc, tdc, u, v, vvel, wspd, wdir,   \
                  hgt_hour, tmpc_hour, tdc_hour, u_hour,    \
                  v_hour, vvel_hour, wspd_hour, wdir_hour)

;  SINCE WE NEED TO PLOT HORIZONTAL WIND FIELD, IF THE VERTICAL VELOCITY IS MISSING, WE CAN'T PLOT 
;  THE HORIZONTAL WIND EVEN. SO ASSIGN vvel_hour MISSING VALUE TO 0.0
                  vvel_hour = where(ismissing(vvel_hour), 0.0, vvel_hour)
;  ACCUMULATE ALL THE VARIABLE INTO DAY, MONTH, YEAR, AND TOTAL
                  if (plot_daily) then
;  CALL SUBROUTINE collect_ncep_fnl_tymd_latitude.ncl TO COLLECT ALL THE HOURS DATA
                     collect_ncep_fnl_tymd_latitude \
                     (iloop_day, start_lon_ind1, end_lon_ind1, start_lon_ind2, end_lon_ind2, \
                     start_nlon_0_com1, end_nlon_0_com1, start_nlon_0_com2, end_nlon_0_com2, \
                     lon, hgt_hour, tmpc_hour, tdc_hour, u_hour, v_hour, vvel_hour, wspd_hour, wdir_hour, \
                     lon_t, hgt_day, tmpc_day, tdc_day, u_day, v_day, vvel_day, wspd_day, wdir_day)
                  end if
                  if (plot_monthly) then
;  CALL SUBROUTINE collect_ncep_fnl_tymd_latitude.ncl TO COLLECT ALL THE HOURS DATA
                     collect_ncep_fnl_tymd_latitude \
                     (iloop_month, start_lon_ind1, end_lon_ind1, start_lon_ind2, end_lon_ind2, \
                     start_nlon_0_com1, end_nlon_0_com1, start_nlon_0_com2, end_nlon_0_com2, \
                     lon, hgt_hour, tmpc_hour, tdc_hour, u_hour, v_hour, vvel_hour, wspd_hour, wdir_hour, \
                     lon_t, hgt_month, tmpc_month, tdc_month, u_month, v_month, vvel_month, wspd_month, wdir_month)
                  end if
                  if (plot_yearly) then
;  CALL SUBROUTINE collect_ncep_fnl_tymd_latitude.ncl TO COLLECT ALL THE HOURS DATA
                     collect_ncep_fnl_tymd_latitude \
                     (iloop_year, start_lon_ind1, end_lon_ind1, start_lon_ind2, end_lon_ind2, \
                     start_nlon_0_com1, end_nlon_0_com1, start_nlon_0_com2, end_nlon_0_com2, \
                     lon, hgt_hour, tmpc_hour, tdc_hour, u_hour, v_hour, vvel_hour, wspd_hour, wdir_hour, \
                     lon_t, hgt_year, tmpc_year, tdc_year, u_year, v_year, vvel_year, wspd_year, wdir_year)
                  end if
                  if (plot_totally) then
;  CALL SUBROUTINE collect_ncep_fnl_tymd_latitude.ncl TO COLLECT ALL THE HOURS DATA
                     collect_ncep_fnl_tymd_latitude \
                     (iloop_total, start_lon_ind1, end_lon_ind1, start_lon_ind2, end_lon_ind2, \
                     start_nlon_0_com1, end_nlon_0_com1, start_nlon_0_com2, end_nlon_0_com2, \
                     lon, hgt_hour, tmpc_hour, tdc_hour, u_hour, v_hour, vvel_hour, wspd_hour, wdir_hour, \
                     lon_t, hgt_total, tmpc_total, tdc_total, u_total, v_total, vvel_total, wspd_total, wdir_total)
                  end if
                  iloop_day   = iloop_day   + 1
                  iloop_month = iloop_month + 1
                  iloop_year  = iloop_year  + 1
                  iloop_total = iloop_total + 1
               end do ;ihour

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT DAILY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
               if (plot_daily) then
                  stime = siyear + "-" + simonth + "-" + siday

;  CALCULATE THE AVERAGE
                  hgt_daily  = dim_avg_n(hgt_day,  0)
                  tmpc_daily = dim_avg_n(tmpc_day, 0)
                  tdc_daily  = dim_avg_n(tdc_day,  0)
                  u_daily    = dim_avg_n(u_day,    0)
                  v_daily    = dim_avg_n(v_day,    0)
		  vvel_daily = dim_avg_n(vvel_day, 0)*vvel_factor
                  wspd_daily = dim_avg_n(wspd_day, 0)
                  wdir_daily = dim_avg_n(wdir_day, 0)

;  CALL SUBROUTINE plot_contour_pres_hgt_vector.ncl TO PLOT CONTOUR ALONG 
;  LATITUDE AND VERTICAL.
                  plot_contour_pres_hgt_vector \
                  (wks, stime, nlon_0_com, npts, p, lon_t, tdc_daily, u_daily, vvel_daily)
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
                  polygon_map \
                  (wks, minlat, maxlat, minlon, maxlon, \
                  lat_pg, lon_pg)
               end if

            end do ;iday

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT MONTHLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
               if (plot_monthly) then
                  stime = siyear + "-" + simonth

;  CALCULATE THE AVERAGE
                  hgt_monthly  = dim_avg_n(hgt_month,  0)
                  tmpc_monthly = dim_avg_n(tmpc_month, 0)
                  tdc_monthly  = dim_avg_n(tdc_month,  0)
                  u_monthly    = dim_avg_n(u_month,    0)
                  v_monthly    = dim_avg_n(v_month,    0)
                  vvel_monthly = dim_avg_n(vvel_month, 0)*vvel_factor
                  wspd_monthly = dim_avg_n(wspd_month, 0)
                  wdir_monthly = dim_avg_n(wdir_month, 0)

;  CALL SUBROUTINE plot_contour_pres_hgt_vector.ncl TO PLOT CONTOUR ALONG 
;  LATITUDE AND VERTICAL.
                  plot_contour_pres_hgt_vector \
                  (wks, stime, nlon_0_com, npts, p, lon_t, tdc_monthly, u_monthly, vvel_monthly)
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
                  stime = siyear

;  CALCULATE THE AVERAGE
                  hgt_yearly  = dim_avg_n(hgt_year,  0)
                  tmpc_yearly = dim_avg_n(tmpc_year, 0)
                  tdc_yearly  = dim_avg_n(tdc_year,  0)
                  u_yearly    = dim_avg_n(u_year,    0)
                  v_yearly    = dim_avg_n(v_year,    0)
                  vvel_yearly = dim_avg_n(vvel_year, 0)*vvel_factor
                  wspd_yearly = dim_avg_n(wspd_year, 0)
                  wdir_yearly = dim_avg_n(wdir_year, 0)

;  CALL SUBROUTINE plot_contour_pres_hgt_vector.ncl TO PLOT CONTOUR ALONG 
;  LATITUDE AND VERTICAL.
                  plot_contour_pres_hgt_vector \
                  (wks, stime, nlon_0_com, npts, p, lon_t, tdc_yearly, u_yearly, vvel_yearly)
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
                  polygon_map \
                  (wks, minlat, maxlat, minlon, maxlon, \
                  lat_pg, lon_pg)
               end if

      end do ;iyear

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT TOTALLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
               if (plot_totally) then
                  stime = start_year + "-" + end_year

;  CALCULATE THE AVERAGE
                  hgt_totally  = dim_avg_n(hgt_total,  0)
                  tmpc_totally = dim_avg_n(tmpc_total, 0)
                  tdc_totally  = dim_avg_n(tdc_total,  0)
                  u_totally    = dim_avg_n(u_total,    0)
                  v_totally    = dim_avg_n(v_total,    0)
                  vvel_totally = dim_avg_n(vvel_total, 0)*vvel_factor
                  wspd_totally = dim_avg_n(wspd_total, 0)
                  wdir_totally = dim_avg_n(wdir_total, 0)

;  CALL SUBROUTINE plot_contour_pres_hgt_vector.ncl TO PLOT CONTOUR ALONG 
;  LATITUDE AND VERTICAL.
                  plot_contour_pres_hgt_vector \
                  (wks, stime, nlon_0_com, npts, p, lon_t, tdc_totally, u_totally, vvel_totally)
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
                  polygon_map \
                  (wks, minlat, maxlat, minlon, maxlon, \
                  lat_pg, lon_pg)
               end if

   end do ;ilat

end
