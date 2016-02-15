;  $ID:joint_histogram_seviri_oper.ncl V01 02/10/2016 17:07 V01 ZHIFENG YANG EXP$
;******************************************************************************
;  PROGRAM joint_histogram_seviri_oper.ncl READS THE SEVIRI OPER_R DATA, 
;  
;  WHOSE DATA FILE NAME LIKE 
;  SEVIR_OPER_R___MSGCPP__L2__20130702T000000_20130703T000000_0001.nc
;  AND PLOTS THE COT AND CLOUD TOP PRESSURE JOINT HISTOGRAM.
;
;  FLOW CHART:
;  ============================================================================
;  (1 ) SETUP DATA INFO, INCLUDING DIRECTORY, FILENAME;
;  (2 ) READ PARAMETERS (cot AND cth);
;  (3 ) USE THE EXPONENTIAL RELATIONSHIP BETWEEN PRESSURE AND HEIGHT TO CONVERT 
;       HEIGHT(CTH) TO PRESSURE (CTP);
;  (4 ) DIVIDE THE COT AND CTP INTO SPECIFIC BINS AS MODIS SPECIFIED, WHICH IS 
;       AS FOLLOWING;
;       Histogram_Bin_Boundaries = 
;       0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 15.0, 20.0, 30.0, 40.0, 50.0, 100.0, 150.0
;       Joint_Parameter_Histogram_Bin_Boundaries = 
;       50.0, 250.0, 300.0, 350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 700.0, 
;       800.0, 900.0, 1000.0, 1100.0
;  (5 ) PLOT THE COT-CTP JOINT HISTOGRAM.
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY ZHIFENG YANG. (02/14/2016)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/divide_bin_fre_specific.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_region_seviri_oper.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_histogram_seviri_fre.ncl"

begin

;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   plot_dir   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/joint_histogram_seviri_oper/"
   wks        = gsn_open_wks(type, plot_dir + "1plot_joint_histogram_seviri_oper_v06")
   gsn_define_colormap(wks,"MPL_gist_yarg")

;  DATA DIRECTORY
   dir        = "/home/vy57456/zzbatmos_common/Data/SEVIRI/SEVIR_OPER_R/"

;==============================================================================
;  SETUP MISSING VALUES; STUDY REGION, AND PAPRAMETERS
;==============================================================================
;  DEFINE BAD VALUE
   bv1        = -9999
   bv2        = -1.
   zero1      = 0
   zero2      = 0.0

;  SET UP LIMITED REGION
   minlat     =-30.0
   maxlat     = 10.0
   minlon     =-20.0
   maxlon     = 20.0
;  LATTITUDE AND LONGITUDE FOR STUDY REGION
   lat_pg     = (/minlat, minlat, maxlat, maxlat, minlat/)
   lon_pg     = (/minlon, maxlon, maxlon, minlon, minlon/)
;  SWITCH FOR BACKGROUND MAP
   switch_pg  = True

;  SET UP THE START TIME AND END TIME
   start_year = 2013
   end_year   = 2014
   start_month= 7
   end_month  = 10
   start_day  = 1
   ntime      = 96

;  SEA SURFACE PRESSURE (hPa)
   P0         = 1100.00
;  SCALE HEIGHT (m)
   H          = 8000.0
;  # OF SELECTED PIXEL
   npixel     = 10000000

;  DEFINE THE BIN BOUNDARIES
   COT_boundary = (/0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 15.0, \
                   20.0, 30.0, 40.0, 50.0, 100.0, 150.0/)
   CTP_boundary = (/50.0, 250.0, 300.0, 350.0, 400.0,    \
                   450.0, 500.0, 550.0, 600.0, 700.0,    \
                   800.0, 900.0, 1000.0, 1100.0/)

   nCOT_boundary = dimsizes(COT_boundary)
   nCTP_boundary = dimsizes(CTP_boundary)

;  WHICH PLOT IS TO BE PLOTTED
   logic_plot_daily   = False
   logic_plot_monthly = True
   logic_plot_yearly  = True
   logic_plot_time    = True

;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  START TO PROCESS DATA
;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  DO TIME LOOP
   do itime = 0, ntime-1

      cot_ctp_time = new((/nCTP_boundary-1, nCOT_boundary-1/), float, bv2)
      cot_ctp_time = 0.0
      ncount_time  = 0
;  DO YEAR LOOP
      do iyear = start_year, end_year
         siyear = sprinti("%0.4i", iyear)

         cot_ctp_yearly = new((/nCTP_boundary-1, nCOT_boundary-1/), float, bv2)
         cot_ctp_yearly = 0.0
         ncount_yearly  = 0
;  DO MONTH LOOP
         do imonth = start_month, end_month
            simonth = sprinti("%0.2i", imonth)

            cot_ctp_monthly = new((/nCTP_boundary-1, nCOT_boundary-1/), float, bv2)
            cot_ctp_monthly = 0.0
            ncount_monthly  = 0
;  CALCULATE THE NUMBER OF DAYS IN THIS MONTH
            nday_month = days_in_month(iyear, imonth)

;  DO DAY LOOP
            do iday = start_day, nday_month
               siday = sprinti("%0.2i", iday)
;  BUILD FILE NAME BASED ON THE YEAR, MONTH, DAY
               start_yyyymmdd = siyear + simonth + siday
;  CONSIDER THE SITUATION THAT THE iday IS THE LAST DAY OF THAT MONTH, IF IT 
;  IS THE CASE, CONSIDER TO MOVE THE MONTH TO THE NEXT MONTH AND USING THE 
;  FIRST DAY OF THAT MONTH. FOR VERY SPECIFIC CASE, IF THIS DAY IS THE LAST DAY 
;  OF THE YEAR, IN THIS CASE, WE ALSO NEED TO MOVE ON THE YEAR TO THE NEXT YEAR
               if (iday .lt. nday_month) then
                  iyear2  = iyear
                  imonth2 = imonth
                  iday2   = iday + 1
               else if (iday .eq. nday_month .and. \
                        imonth .lt. 12) then
                  iyear2  = iyear
                  imonth2 = imonth + 1
                  iday2   = 1
               else if (iday .eq. nday_month .and. \
                        imonth .eq. 12) then
                  iyear2  = iyear + 1
                  imonth2 = imonth + 1
                  iday2   = 1
               end if
               end if
               end if
               siyear2  = sprinti("%0.4i", iyear2)
               simonth2 = sprinti("%0.2i", imonth2)
               siday2   = sprinti("%0.2i", iday2)
               end_yyyymmdd = siyear2 + simonth2 + siday2

               filename  = "SEVIR_OPER_R___MSGCPP__L2__" + \
                           start_yyyymmdd + "T000000_"   + \
                           end_yyyymmdd   + "T000000_"   + \
                           "0001.nc"
               if (.not.fileexists(dir + "/" + siyear + "/"  + \
                                   simonth + "/" + siday + "/" \
                                   + filename))
                  continue
               end if
               print("NOW PROCESSING : " + filename)

;  START TO READ THE VARIABLES FROM SEVIRI FILE NAME
               a     = addfile(dir + "/" + siyear + "/"    + \
                               simonth + "/" + siday + "/" + \
                               filename, "r")
               if (.not.isdefined("lat"))
                  lat   = (/a->lat/)
                  lon   = (/a->lon/)
               end if
               time  = a->time(itime)
;  CONVERT SHORT TO FLOAT WITH FUNCTION short2flt USING THE ATTRIBUTES 
;  "scale factor" AND "offset"
               cth   = short2flt(a->cth(itime, :, :))
               cot   = short2flt(a->cot(itime, :, :))
               cot@_FillValue = bv2

;  CONVERT time TO UTC TIME
               utc_time  = floattoint(cd_calendar(time, 0))
               stime     = sprinti("%0.4i", utc_time (:, 0)) + "-" + \
                           sprinti("%0.2i", utc_time (:, 1)) + "-" + \
                           sprinti("%0.2i", utc_time (:, 2)) + " " + \
                           sprinti("%0.2i", utc_time (:, 3)) + ":" + \
                           sprinti("%0.2i", utc_time (:, 4)) + ":00"
;  CONVERT THE HEIGHT TO PRESSURE
               ctp       = P0*exp(-cth/H)

               cot0 = new((/npixel/), float, bv2)
               ctp0 = new((/npixel/), float, bv2)
;  CALL SUBROUTINE select_region_seviri_oper.ncl TO SELECT THE DATA IN THE 
;  STUDY REGION
               select_region_seviri_oper   \
               (minlat, maxlat, minlon,    \
               maxlon, lat, lon, cot, ctp, \
               cot0, ctp0)

               cot_ctp   = new((/nCTP_boundary-1, nCOT_boundary-1/), float, bv2)
;  CALL SUBROUTINE divide_bin_fre_specific.ncl TO CALCULATE THE FREQUENCY
               divide_bin_fre_specific                  \
               (cot0, ctp0, COT_boundary, CTP_boundary, \
               cot_ctp)
               cot_ctp_time    = cot_ctp_time    + cot_ctp
               cot_ctp_yearly  = cot_ctp_yearly  + cot_ctp
               cot_ctp_monthly = cot_ctp_monthly + cot_ctp
               ncount_time     = ncount_time    + 1
               ncount_yearly   = ncount_yearly  + 1
               ncount_monthly  = ncount_monthly + 1

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT AND WRITE DAILY
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
               if (logic_plot_daily) then
               stime_daily   = sprinti("%4.4i", utc_time (:, 0)) + "_" + \
                               sprinti("%0.2i", utc_time (:, 1)) + "_" + \
                               sprinti("%0.2i", utc_time (:, 2)) + "_" + \
                               sprinti("%0.2i", utc_time (:, 3)) + ":" + \
                               sprinti("%0.2i", utc_time (:, 4)) + ":00"
               print("Year Month Daily: " + stime_daily)
;  CALL SUBROUTINE plot_histogram_seviri_fre.ncl TO PLOT JOINT HISTOGRAM OF 
;  COT AND CTP
                  plot_histogram_seviri_fre         \
                  (wks, COT_boundary, CTP_boundary, \
                  cot_ctp, stime_daily)
                  if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
                     polygon_map                           \
                     (wks, minlat, maxlat, minlon, maxlon, \
                     lat_pg, lon_pg)
                  end if
;  WRITE JOINT HISTOGRAM INTO A TEXT FILE
                  option        = True
                  option@row    = False
                  option@tspace = 0
                  option@fout   = plot_dir + "Daily_" + stime_daily + ".txt"
                  write_matrix(cot_ctp, "12f10.5", option)
               end if
            end do ;iday

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT AND WRITE MONTHLY
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            if (logic_plot_monthly) then
               cot_ctp_monthly = cot_ctp_monthly/ncount_monthly
               stime_monthly   = sprinti("%4.4i", utc_time (:, 0)) + "_" + \
                                 sprinti("%0.2i", utc_time (:, 1)) + "_" + \
                                 sprinti("%0.2i", utc_time (:, 3)) + ":" + \
                                 sprinti("%0.2i", utc_time (:, 4)) + ":00"
               print("Year Month : " + stime_monthly)
;  CALL SUBROUTINE plot_histogram_seviri_fre.ncl TO PLOT JOINT HISTOGRAM OF 
;  COT AND CTP
               plot_histogram_seviri_fre         \
               (wks, COT_boundary, CTP_boundary, \
               cot_ctp_monthly, stime_monthly)
               if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
                  polygon_map                           \
                  (wks, minlat, maxlat, minlon, maxlon, \
                  lat_pg, lon_pg)
               end if
;  WRITE JOINT HISTOGRAM INTO A TEXT FILE
               option        = True
               option@row    = False
               option@tspace = 0
               option@fout   = plot_dir + "Monthly_" + stime_monthly + ".txt"
               write_matrix(cot_ctp_monthly, "12f10.5", option)
            end if
         end do ;imonth

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT AND WRITE YEARLY
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
         if (logic_plot_yearly) then
            cot_ctp_yearly = cot_ctp_yearly/ncount_yearly
            stime_yearly   = sprinti("%4.4i", utc_time (:, 0)) + "_" + \
                             sprinti("%0.2i", utc_time (:, 3)) + ":" + \
                             sprinti("%0.2i", utc_time (:, 4)) + ":00"
            print("Year : " + stime_yearly)
;  CALL SUBROUTINE plot_histogram_seviri_fre.ncl TO PLOT JOINT HISTOGRAM OF 
;  COT AND CTP
            plot_histogram_seviri_fre         \
            (wks, COT_boundary, CTP_boundary, \
            cot_ctp_yearly, stime_yearly)
            if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
               polygon_map                           \
               (wks, minlat, maxlat, minlon, maxlon, \
               lat_pg, lon_pg)
            end if
;  WRITE JOINT HISTOGRAM INTO A TEXT FILE
            option        = True
            option@row    = False
            option@tspace = 0
            option@fout   = plot_dir + "Yearly_" + stime_yearly + ".txt"
            write_matrix(cot_ctp_yearly, "12f10.5", option)
         end if
      end do ;iyear

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT AND WRITE TIME
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
      if (logic_plot_time) then
         cot_ctp_time = cot_ctp_time/ncount_time
         stime_time   = sprinti("%0.2i", utc_time (:, 3)) + ":" + \
                        sprinti("%0.2i", utc_time (:, 4)) + ":00"
         print("Time : " + stime_time)
;  CALL SUBROUTINE plot_histogram_seviri_fre.ncl TO PLOT JOINT HISTOGRAM OF 
;  COT AND CTP
         plot_histogram_seviri_fre         \
         (wks, COT_boundary, CTP_boundary, \
         cot_ctp_time, stime_time)
         if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
            polygon_map                           \
            (wks, minlat, maxlat, minlon, maxlon, \
            lat_pg, lon_pg)
         end if
;  WRITE JOINT HISTOGRAM INTO A TEXT FILE
         option        = True
         option@row    = False
         option@tspace = 0
         option@fout   = plot_dir + "Time_" + stime_time + ".txt"
         write_matrix(cot_ctp_time, "12f10.5", option)
      end if
      delete([/lat, lon/])
   end do ;itime
end
