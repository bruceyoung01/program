;  $ID: scatter_seviri_caliop.ncl V01 07/15/2015 08:38 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM scatter_seviri_caliop.ncl READS THE OUTPUT FILE FROM PROGRAM 
;  contour_grid_seviri_cot_aca_38_var.ncl, AND PLOTS THE SCATTER PLOTS BETWEEN 
;  VARIOUS VARIABLES WITH STANDARD DEVIATION INCLUDED. THESE FIGURES ARE BASED 
;  ON COSTANTINO ET AL., 2013, JGR PAPER. THE REFERENCE IS
;  THE DISTINGUISHING METHOD USED HERE IS FROM THE FOLLOWING REFERENCES:
;  (1 ) Costantino, L. and Bréon, F.-M.: Aerosol indirect effect on warm clouds 
;       over South-East Atlantic, from co-located MODIS and CALIPSO observations, 
;       Atmos. Chem. Phys., 13, 69-88, doi:10.5194/acp-13-69-2013, 2013.
;  THE FIGURES CORRESPONDING TO COSTANTINO'S FIGURES. SUCH AS:
;  (1 ) AOD VS. CER (CLOUD EFFECTIVE RADIUS, FIG.5 IN COSTANTINO'S PAPER)
;  (2 ) AOD VS. CWP (CLOUD WATER PATH, FIG.6)
;  (3 ) AOD VS. COD (FIG.7)
;  (4 ) COD VS. CER (FIG.11)
;  (5 ) COD VS. CWP (FIG.12)
;  (6 ) AOD VS. CTP (FIG.14)
;
;  FLOW CHART:
;  ============================================================================
;  (1 ) READ VARIABLES FROM ASCII FILES;
;  (2 ) CALCULATE STATISTICAL PARAMETERS AND PLOT SCATTER PLOT.
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (07/15/2015)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/match_touch_untouch_noaca_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_seviri_filename_hour_min.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/read_ascii_seviri_caliop.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_scatter_seviri_caliop_reg_option.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
;  type       = "pdf"
   type       = "png"
   plot_dir   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/scatter_seviri_caliop/"
   wks        = gsn_open_wks(type, plot_dir + "1plt_scatter_seviri_caliop_v02")
   gsn_define_colormap(wks,"WhBlGrYeOrReVi202")

;  DATA DIRECTORY
   dir        = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/contour_grid_seviri_cot_aca_38_var/"
   filelist   = "filelist_v01"

;  DEFINE BAD VALUE
   bv1        = -9999
   bv2        = -9999.

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

   nobs          = 500
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
   nvariable     = 33
   dim           = (/ncase, nmethod, nvariable, nhour, nmin, nobs, ncount_write_day/)
   seviri_data   = new(dim, float, bv2)
   variable_name = new((/nvariable/), string)
;  DO method AND case LOOP TO GET ALL THE METHDS AND CASES
   do icase = 0, ncase-1
      do imethod = 0, nmethod-1
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
               nsfilename      = 50
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
;  CALL SUBROUTINE read_ascii_seviri_caliop.ncl TO READ THE DATA
                  read_ascii_seviri_caliop                    \
                  (dir, sfilename(isfilename_real), nvariable, variable_name, \
                  seviri_data(icase, imethod, :, ihour, imin_loop, iloop, :))
                  iloop = iloop + 1
               end do ;isfilename_real
               imin_loop = imin_loop + 1
            end do ;imin
         end do ;ihour

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

         xvariable = (/15, 15, 15, 14, 14, 15/) ;AOD, AOD, AOD, COD, COD, AOD
         yvariable = (/5,  7,  14, 5,  7,  27/) ;CER, CWP, COD, CER, CWP, CTP
         xmin      = (/0,  0,  0,  0,  0,  0 /)
         xmax      = (/1,  1,  1,  50, 50, 1 /)
         ymin      = (/0,  0,  0,  0,  0,  700 /)
         ymax      = (/50, 200,50, 50, 200,1000/)
         xunit     = (/" ", " ", " ", " ", " ", " "/)
         yunit     = (/" (~F33~m~F21~m)", " (g/m~S~2~N~)", \
                       " ", " (~F33~m~F21~m)", \
                       " (g/m~S~2~N~)", " (hPa)"/)
         xtick_name= variable_name(xvariable) + xunit
         ytick_name= variable_name(yvariable) + yunit
         nplot     = 6
;  DO nplot LOOP TO PLOT IMAGES
         do iplot = 0, nplot-1
            stitle = case(icase) + " " +  method(imethod) + " - " + \
                     variable_name(xvariable(iplot)) + " VS. "    + \
                     variable_name(yvariable(iplot))
;print(stitle)
;printMinMax(seviri_data(icase, imethod, yvariable(iplot), :, :, :, :), 0)
;  CALL SUBROUTINE plot_scatter_seviri_caliop_reg_option.ncl TO PLOT SCATTER IMAGES
            plot_scatter_seviri_caliop_reg_option               \
            (wks, stitle, xtick_name(iplot), ytick_name(iplot), \
            xmin(iplot), xmax(iplot), ymin(iplot), ymax(iplot), \
            seviri_data(icase, imethod, xvariable(iplot), :, :, :, :), \
            seviri_data(icase, imethod, yvariable(iplot), :, :, :, :))
         end do ;iplot
      end do ;imethod
   end do ;icase

end
