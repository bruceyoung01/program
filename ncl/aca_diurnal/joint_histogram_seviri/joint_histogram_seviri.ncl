;  $ID: joint_histogram_seviri.ncl V01 07/13/2015 08:33 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM joint_histogram_seviri.ncl READS THE OUTPUT FILE FROM PROGRAM 
;  contour_grid_seviri_cot_aca_38_ESMF_12var.ncl, AND PLOTS JOINT HISTOGRAM 
;  OF FREQUENCY FOR COT(CLOUD OPTICAL THICKNESS) AND CTP(CLOUD TOP PRESSURE).
;
;  FLOW CHART:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (07/13/2015)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/match_touch_untouch_noaca_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_seviri_filename_hour_min.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/read_ascii_seviri_caliop.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/calculate_fre_cot_ctp.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_histogram_seviri_fre.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   plot_dir   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/joint_histogram_seviri/"
;  wks        = gsn_open_wks(type, plot_dir + "1plot_joint_histogram_seviri_v04")
;  gsn_define_colormap(wks,"MPL_gist_yarg")

;  DATA DIRECTORY
   dir        = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/contour_grid_seviri_cot_aca_38/"
   filelist   = "filelist_ESMF_v04"

;  DEFINE BAD VALUE
   bv1        = -9999
   bv2        = -9999.

;  SET UP THE START TIME AND END TIME
   start_year   = 2008
   end_year     = 2008
   start_month  = 6
   end_month    = 8
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

;  CITE COT BOUNDARY AND CTP BOUNDARY FROM DR. ZHIBO ZHANG'S ACA DATA
   cot_boundary  = (/0, 2, 4, 6, 8, 10, 15, 20, 30, 40, 50, 100/)
   ctp_boundary  = (/200, 250, 300, 350, 400, 450, 500, \
                     550, 600, 700, 800, 900, 1000, 1100/)
   ncot_boundary = dimsizes(cot_boundary)
   nctp_boundary = dimsizes(ctp_boundary)
   dim_boundary  = (/ncase, nmethod, nhour, nmin, nctp_boundary-1, ncot_boundary-1/)
   seviri_count  = new(dim_boundary, integer, bv1)
   seviri_fre    = new(dim_boundary, float,   bv2)
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

;  DO method AND case LOOP TO GET ALL THE METHDS AND CASES
   do icase = 0, ncase-1
      do imethod = 0, nmethod-1
         wks = gsn_open_wks(type, plot_dir + "1plot_joint_histogram_seviri_" + \
                            case(icase) + "_" + method(imethod) + "_v04")
         gsn_define_colormap(wks,"MPL_gist_yarg")
;  DO HOUR LOOP TO COLLECT ALL THE DATA
         do ihour = start_hour, end_hour
;  DO MINUTE LOOP
            imin_loop = 0
            do imin = start_min, end_min, min_interval
               sihour = sprinti("%0.2i", ihour)
               simin  = sprinti("%0.2i", imin)
               stime  = sihour + ":" + simin + ":00"
               print("Time = " + stime)
               nsfilename      = 200
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
               iloop = 0
               do isfilename_real = 0, nsfilename_real-1
                  print("Now processing = " + sfilename(isfilename_real))
;  CALL SUBROUTINE read_ascii_seviri_caliop.ncl TO READ THE DATA
                  read_ascii_seviri_caliop                    \
                  (dir, sfilename(isfilename_real), nvariable, variable_name, \
                  seviri_data(icase, imethod, :, ihour, imin_loop, iloop, :))
                  iloop = iloop + 1
               end do ;isfilename_real

;  CALL SUBROUTINE calculate_fre_cot_ctp.ncl TO CALCULATE THE COUNT AND FREQUENCY
               calculate_fre_cot_ctp \
               (cot_boundary, ctp_boundary, \
               seviri_data(icase, imethod, :, ihour, imin_loop, :, :), \
               seviri_count(icase, imethod, ihour, imin_loop, :, :), \
               seviri_fre(icase, imethod, ihour, imin_loop, :, :))
;print(seviri_fre(icase, imethod, ihour, imin_loop, :, :))

               if (.not.all(ismissing(seviri_fre(icase, imethod, ihour, imin_loop, :, :))) .and. \
                   min(seviri_fre(icase, imethod, ihour, imin_loop, :, :)) .ne. \
                   max(seviri_fre(icase, imethod, ihour, imin_loop, :, :))) then
                  title = stime + " " + case(icase) + " " + method(imethod)
;  CALL plot_histogram_seviri_fre.ncl TO PLOT ADJOINT HISTOGRAM
                  plot_histogram_seviri_fre \
                  (wks, cot_boundary, ctp_boundary, \
                  seviri_fre(icase, imethod, ihour, imin_loop, :, :), \
                  title)
               end if
               imin_loop = imin_loop + 1
            end do ;imin
         end do ;ihour

;  CALCULATE AVERAGE OF ALL THE DATA
         seviri_count_sum = dim_sum_n(seviri_count(icase, imethod, :, :, :, :), 0)
         seviri_fre_avg   = dim_sum_n(seviri_count_sum, 0)/int2flt(sum(seviri_count_sum))
         if (.not.all(ismissing(seviri_fre_avg)) .and. \
             min(seviri_fre_avg) .ne. max(seviri_fre_avg)) then
             title = case(icase) + " " + method(imethod)
;  CALL plot_histogram_seviri_fre.ncl TO PLOT JOINT HISTOGRAM
             plot_histogram_seviri_fre \
             (wks, cot_boundary, ctp_boundary, \
             seviri_fre_avg, title)
         end if
      end do ;imethod
   end do ;icase

end
