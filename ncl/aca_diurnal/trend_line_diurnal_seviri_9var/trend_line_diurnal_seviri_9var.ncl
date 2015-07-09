;  $ID: trend_line_diurnal_seviri_9var.ncl V01 06/23/2015 14:45 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM trend_line_diurnal_seviri_9var READS THE OUTPUT FILE FROM PROGRAM 
;  contour_grid_seviri_cot_aca.ncl, AND PLOTS THE TREND LINE PLOT FOR CLOUD
;  OPTICAL THICKNESS, AND OTHER PARAMETERS.
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
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_seviri_filename_hour_min.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/read_ascii_seviri_caliop.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_trend_diurnal7_9var.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   plot_dir   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/trend_line_diurnal_seviri_9var/"
   wks        = gsn_open_wks(type, plot_dir + "1plot_trend_line_diurnal_seviri_9var_v03")
   gsn_define_colormap(wks,"WhBlGrYeOrReVi202")

;  DATA DIRECTORY
   dir        = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/contour_grid_seviri_cot_aca/"
   filelist   = "filelist_ESMF_v02"
   filename   = asciiread(dir + filelist, -1, "string")
   nfilename  = dimsizes(filename)

;  DEFINE BAD VALUE
   bv1        = -9999
   bv2        = -9999.

;  SET UP THE START TIME AND END TIME
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
   case          = (/"all", "untouch", "touch", "uncertain", "noaca"/)
   sday_or_night = (/"D", "N"/)
   nmethod       = dimsizes(method)
   ncase         = dimsizes(case)
   nday_or_night = dimsizes(sday_or_night)

   nobs          = 2000
   nctrack       = 3
   ncount_write  = 100
   ncount_write_day = nctrack*ncount_write

;  DEFINE NEW ARRAY TO READ DATA
   nvariable     = 13
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
      end do ;imethod
   end do ;icase

;  CONVERT THE ARRAY cot TO 3-D ARRAY
   ncasemethod         = 10
   seviri_data_3d      = new((/ncasemethod, nhour*nmin, nvariable/), float, bv2)
   seviri_data_3d_mean = new((/ncasemethod, nvariable/), float, bv2)
   scasemethod         = new((/ncasemethod/), string)
   iicasemethod        = 0
   do iicase = 0, ncase-1
      do iimethod = 0, nmethod-1
         do iivar = 0, nvariable-1
            iihourmin = 0
            do iihour = 0, nhour-1
               do iimin = 0, nmin-1
                  if (.not.all(ismissing(seviri_data(iicase, iimethod, iivar, iihour, iimin, :, :)))) then
                     seviri_data_3d(iicasemethod, iihourmin, iivar) = \
                     avg(seviri_data(iicase, iimethod, iivar, iihour, iimin, :, :))
                  end if
                  iihourmin = iihourmin + 1
               end do ;iimin
            end do ;iihour
            if (.not.all(ismissing(seviri_data_3d(iicasemethod, iivar, :)))) then
               seviri_data_3d_mean(iicasemethod, iivar) = avg(seviri_data_3d(iicasemethod, iivar, :))
            end if
         end do ;iivar
;        if (iicase .eq. 3 .and. iimethod .eq. 0) then
;           continue
;        end if
         scasemethod(iicasemethod) = case(iicase) + " " +     \
                                     method(iimethod)
         iicasemethod = iicasemethod + 1
      end do ;iimethod
   end do ;iicase

;  DO VARIABLE LOOP TO PLOT IMAGE ONE VARIABLE BY ONE VARIABLE
   do iiivar = 0, nvariable-1
;  CALL SUBROUTINE plot_trend_diurnal7_9var.ncl TO PLOT SEVIRI DIURNAL VARIATION
      plot_trend_diurnal7_9var \
      (wks, iiivar, scasemethod, seviri_data_3d(:, :, iiivar), \
      seviri_data_3d_mean(:, iiivar), nhour*nmin)
   end do

end
