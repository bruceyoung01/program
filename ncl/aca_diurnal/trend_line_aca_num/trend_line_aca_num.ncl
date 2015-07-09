;  $ID: trend_line_aca_num.ncl V01 06/23/2015 14:45 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM trend_line_aca_num READS THE OUTPUT FILE FROM PROGRAM 
;  contour_grid_amsre_sum_aca.ncl, AND PLOTS THE TREND LINE PLOT FOR THE 
;  OCCURANCE NUMBER OF ALL, UNTOUCH, TOUCH, AND UNCERTAIN CASES
;  .
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (6/23/2015)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/read_ascii_amsre_caliop.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/calculate_aca_num.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_trend_line2_aca_num.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plot_trend_line_aca_num_v01")
   gsn_define_colormap(wks,"WhBlGrYeOrReVi202")

;  DATA DIRECTORY
   dir        = "/home/vy57456/zzbatmos_user/program/ncl/aca_diurnal/contour_grid_amsre_sum_aca/file/"

;  DEFINE BAD VALUE
   bv1        = -9999
   bv2        = -9999.

;  SET UP THE START TIME AND END TIME
   start_year = 2007
   end_year   = 2007
   start_month= 6
   end_month  = 8
   start_day  = 1

;  SWITCH FOR DIFFERENT CASES
;  TWO METHODS: C2010-Costantino_2010; C2013-Costantino_2013
;  FOR Costantino_2010
;  "all"     : ALL THE CASES INCLUDING ACA AND CLOUD WITH UNTOUCH AND TOUCH
;  "untouch" : UNTOUCH ACA AND CLOUD
;  "touch"   : TOUCH ACA AND CLOUD
;  FOR Costantino_2013, BESIDES FOR Costantino, ONE MORE CASE
;  "uncertain" : UNCERTAIN ABOUT WHETHER ACA AND CLOUD TOUCH OT UNTOUCH
   method        = (/"C2010", "C2013"/)
   case          = (/"all", "untouch", "touch", "uncertain"/)
   sday_or_night = (/"D", "N"/)
   nmethod       = dimsizes(method)
   ncase         = dimsizes(case)
   nday_or_night = dimsizes(sday_or_night)

   nctrack       = 3
   ncount_write  = 100
   ncount_write_day = nctrack*ncount_write
;  CALCULATE TOTAL DAYS FOR ALL THE YEARS DEPENDING ON
;  start_year AND end_year
;  start_month AND end_month
   tnday_year = 0
   do iiyear = start_year, end_year
      do iimonth = start_month, end_month
;  CALCULATE # OF DAYS IN THIS MONTH
         lon_year   = days_in_month(iiyear, iimonth)
         tnday_year = tnday_year + lon_year
      end do
   end do

;  DO method AND case LOOP TO GET ALL THE METHDS AND CASES
   do icase = 0, ncase-1
      do imethod = 0, nmethod-1

;  DO DAY AND NIGHT LOOP
         do iday_or_night = 0, nday_or_night-1

;  DEFINE NEW ARRAY TO READ DATA
            dim = (/tnday_year, ncount_write_day/)
            lat = new(dim, float, bv2)
            lon = new(dim, float, bv2)
            lwp = new(dim, float, bv2)
            rr  = new(dim, float, bv2)
            aba = new(dim, float, bv2)
            cta = new(dim, float, bv2)
;  DO IYEAR LOOP
            iyear_loop = 0
            do iyear = start_year, end_year
               imonth_loop = 0
               do imonth = start_month, end_month
                  lon_year= days_in_month(iyear, imonth)
                  iday_loop = 0
                  do iday = start_day, lon_year
;  CONVERT DATE TO STRING
                     siyear  = sprinti("%0.4i", iyear)
                     simonth = sprinti("%0.2i", imonth)
                     siday   = sprinti("%0.2i", iday)
                     stime   = siyear + "-" + simonth + "-" + siday
                     filename= case(icase) + "_" + method(imethod) + "_" + \
                               sday_or_night(iday_or_night) + "_" + stime + ".txt"
                     if (fileexists(dir + filename)) then
                        print("Now processing = " + filename)
;  CALL SUBROUTINE read_ascii_amsre_caliop.ncl TO READ THE DATA
                        read_ascii_amsre_caliop \
                        (dir, filename, lat(iyear_loop, :), lon(iyear_loop, :), \
                        lwp(iyear_loop, :), rr(iyear_loop, :), \
                        aba(iyear_loop, :), cta(iyear_loop, :))
                        iyear_loop = iyear_loop + 1

                     else
                        print("----------------------------------------------")
                        print("FILE MISSING = " + filename)
                        continue
                     end if
                  end do ;iday
               end do ;imonth
            end do ;iyear
            sstart_year = sprinti("%4.4i", start_year)
            send_year   = sprinti("%4.4i", end_year)
            stitle      = case(icase) + " " + method(imethod) + " " + \
                          sday_or_night(iday_or_night) + " " + \
                          sstart_year + "-" + send_year
            aba_num = new((/tnday_year/), integer, bv1)
            cta_num = new((/tnday_year/), integer, bv1)
;  CALL SUBROUTINE calculate_aca_num.ncl TO GET THE COUNT NUMBER FOR aba AND cta
            calculate_aca_num \
            (aba, cta, aba_num, cta_num)
;  CALL SUBROUTINE plot_trend_line2_aca_num.ncl TO PLOT THE PLOT
            plot_trend_line2_aca_num \
            (wks, stitle, start_year, end_year, start_month, end_month, aba_num, cta_num)
         end do ;iday_or_night
      end do ;imethod
   end do ;icase

end
