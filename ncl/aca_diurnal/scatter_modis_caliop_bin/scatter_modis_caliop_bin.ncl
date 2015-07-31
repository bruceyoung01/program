;  $ID: scatter_modis_caliop_bin.ncl V01 07/23/2015 21:33 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM scatter_modis_caliop_bin.ncl READS THE OUTPUT FILE FROM PROGRAM 
;  write_modis_caliop_aca.ncl, AND PLOTS THE SCATTER PLOTS BETWEEN 
;  VARIOUS VARIABLES WITH STANDARD DEVIATION INCLUDED. THESE FIGURES ARE BASED 
;  ON COSTANTINO ET AL., 2013, JGR PAPER. THE REFERENCE IS
;  THE DISTINGUISHING METHOD USED HERE IS FROM THE FOLLOWING REFERENCES:
;  (1 ) Costantino, L. and Bréon, F.-M.: Aerosol indirect effect on warm clouds 
;       over South-East Atlantic, from co-located MODIS and CALIPSO observations, 
;       Atmos. Chem. Phys., 13, 69-88, doi:10.5194/acp-13-69-2013, 2013.
;  THE FIGURES CORRESPONDING TO COSTANTINO'S FIGURES. SUCH AS:
;  (1 ) AI  VS. CER (CLOUD EFFECTIVE RADIUS, FIG.5 IN COSTANTINO'S PAPER)
;  (2 ) AI  VS. CWP (CLOUD WATER PATH, FIG.6)
;  (3 ) AI  VS. COD (FIG.7)
;  (4 ) COD VS. CER (FIG.11)
;  (5 ) COD VS. CWP (FIG.12)
;  (6 ) AI  VS. CTP (FIG.14)
;
;  FLOW CHART:
;  ============================================================================
;  (1 ) READ VARIABLES FROM ASCII FILES;
;  (2 ) DIVIDE INTO SEVERAL BINS BASED ON MINIMUM AND MAXIMUM VALUE;
;  (3 ) CALCULATE STATISTICAL PARAMETERS;
;  (4 ) PLOT SCATTER IMAGE WITH STANDARD DEVIATION FOR EACH BIN.
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (07/23/2015)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/umbc/lustre/zzbatmos/users/vy57456/program/ncl/ncl_lib/function/attach_labelbar.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/read_ascii_modis_caliop.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/divide_bin_fre_count.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_scatter_modis_caliop_reg_option_bin_color.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   plot_dir   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/scatter_modis_caliop_bin/"
   wks        = gsn_open_wks(type, plot_dir + "1plt_scatter_modis_caliop_bin_v06")
   gsn_define_colormap(wks,"BlGrYeOrReVi200")

;  DATA DIRECTORY
   dir        = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/write_modis_caliop_aca_distance/"

;  DEFINE BAD VALUE
   bv1        = -9999
   bv2        = -9999.

;  SET UP THE START TIME AND END TIME
   start_year   = 2006
   end_year     = 2010
   start_month  = 7
   end_month    = 9
   start_day    = 1

;  SWITCH FOR DIFFERENT CASES
;  FOR Costantino_2013
;  "all"       : ALL THE CASES INCLUDING ACA AND CLOUD WITH UNTOUCH AND TOUCH
;  "untouch"   : UNTOUCH ACA AND CLOUD
;  "touch"     : TOUCH ACA AND CLOUD
;  "uncertain" : UNCERTAIN ABOUT WHETHER ACA AND CLOUD TOUCH OR UNTOUCH
;  "noaca"     : NO ACA
   case          = (/"all", "untouch", "touch", "noaca", "uncertain"/)
   ncase         = dimsizes(case)

   nobs          = 1500
   nctrack       = 3
   ncount_write  = 300
   ncount_write_day = nctrack*ncount_write

;  DEFINE NEW ARRAY TO READ DATA
   nvariable     = 28
   dim           = (/nvariable, nobs, ncount_write_day/)
   variable_name = new((/nvariable/), string)
;  DO case LOOP TO GET ALL THE CASES
   do icase = 0, ncase-1
      print("Now processing = " + case(icase))
      modis_data = new(dim, float, bv2)
      filename   = systemfunc("ls " + dir + case(icase) + "*")
      nfilename  = dimsizes(filename)

;  DO nsfilename_real LOOP TO READ IN ALL THE DATA
      iloop = 0
      do ifilename = 0, nfilename-1
;  CALL SUBROUTINE read_ascii_modis_caliop.ncl TO READ THE DATA
         read_ascii_modis_caliop                    \
         (filename(ifilename), nvariable, variable_name, \
         modis_data(:, iloop, :))
         iloop = iloop + 1
      end do ;ifilename

;  ADD COSTANTINO ET AL., 2013 ACP CRITERIA AND CALCULATE AEROSOL INDEX
      do iobs = 0, nobs-1
         do icount_write_day = 0, ncount_write_day-1
;  ADD COSTANTINO ET AL., 2013 ACP CRITERIA
;  (2 ) CLOUD TOP PRESSURE CTP>600hPa
            if (.not.ismissing(modis_data(22, iobs, icount_write_day))) then
               if (modis_data(22, iobs, icount_write_day) .lt. 600) then
                  modis_data (:, iobs, icount_write_day) = bv2
               end if
            end if
;  (3 ) 5<COT<35 (COT IS FROM MODIS)
            if (.not.ismissing(modis_data(2,  iobs, icount_write_day))) then
               if (modis_data(2,  iobs, icount_write_day) .lt. 5.0 .or. \
                   modis_data(2,  iobs, icount_write_day) .gt. 35) then
                  modis_data (:, iobs, icount_write_day) = bv2
               end if
            end if
;  (4 ) AEROSOL TOP LAYER ALTITUDE ATA<10km
            if (.not.ismissing(modis_data(12, iobs, icount_write_day))) then
               if (modis_data(12, iobs, icount_write_day) .gt. 10.) then
                  modis_data (:, iobs, icount_write_day) = bv2
               end if
            end if
;  (5 ) LIQUID WATER PATH LWP<300 g/m^2
            if (.not.ismissing(modis_data(3,  iobs, icount_write_day))) then
               if (modis_data(3,  iobs, icount_write_day) .gt. 300) then
                  modis_data (:, iobs, icount_write_day) = bv2
               end if
            end if

;  CALCULATE AEROSOL INDEX
            modis_data(6, iobs, icount_write_day) = \
            modis_data(5, iobs, icount_write_day) * \
            modis_data(6, iobs, icount_write_day)
         end do
      end do

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
      xvariable   = (/6, 6, 6, 2, 2, 6/) ;AI , AI , AI , COD, COD, AI 
      yvariable   = (/4, 3, 2, 4, 3, 7/) ;CER, CWP, COD, CER, CWP, CTP
      xmin        = (/0,  0,  0,  0,  0,  0 /)
      xmax        = (/1.0,  1.0,  1.0,  35, 35, 1.0/)
      ymin        = (/0,  0,  5,  5,  0,  700 /)
      ymax        = (/20, 200,15, 20, 300,1000/)
      xunit       = (/" ", " ", " ", " ", " ", " "/)
      yunit       = (/" (~F33~m~F21~m)", " (g/m~S~2~N~)", \
                      " ", " (~F33~m~F21~m)", \
                      " (g/m~S~2~N~)", " (hPa)"/)
      xtick_name  = variable_name(xvariable) + xunit
      ytick_name  = variable_name(yvariable) + yunit
      nplot       = 6
      npts        = 25
;  DO nplot LOOP TO PLOT IMAGES
      do iplot = 0, nplot-2

;  DEFINE ARRAY FOR SUBROUTINE divide_bin_fre.ncl
         xdata_bin   = new((/npts/), float, bv2)
         xdata_fre   = new((/npts/), float, bv2)
         ydata_bin   = new((/npts/), float, bv2)
         ydata_std   = new((/npts/), float, bv2)
         ydata_count = new((/npts/), integer, bv1)

;  CALL SUBROUTINE divide_bin_fre_count.ncl TO DIVIDE THE DATA INTO VARIOUS BINS
         divide_bin_fre_count \
         (xmin(iplot), xmax(iplot), ymin(iplot), ymax(iplot), npts, \
         modis_data(xvariable(iplot), :, :), \
         modis_data(yvariable(iplot), :, :), \
         xdata_bin, xdata_fre, ydata_bin, ydata_std, ydata_count)

         stitle = case(icase) + "   " + \
                  variable_name(xvariable(iplot)) + " VS. " + \
                  variable_name(yvariable(iplot))
         if (iplot .eq. 0 .or. \
             iplot .eq. 1 .or. \
             iplot .eq. 2 .or. \
             iplot .eq. 5) then
            xtick_name(iplot) = "Aerosol Index"
            stitle = case(icase) + "   " + \
                     xtick_name(iplot) + " VS. " + \
                     variable_name(yvariable(iplot))
         end if
         nydata_bin = num(.not.ismissing(ydata_bin))
         if (nydata_bin .le. 2) then
            continue
         end if
;  CALL SUBROUTINE plot_scatter_modis_caliop_reg_option_bin_color.ncl TO PLOT SCATTER IMAGES
         plot_scatter_modis_caliop_reg_option_bin_color      \
         (wks, stitle, xtick_name(iplot), ytick_name(iplot), \
         xmin(iplot), xmax(iplot), ymin(iplot), ymax(iplot), \
         xdata_bin, xdata_fre, ydata_bin, ydata_std)
      end do ;iplot
      delete([/filename, modis_data/])
   end do ;icase
end
