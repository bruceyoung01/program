; $ID: doe_arm_trend_line_1v.ncl V01 04/05/2012 14:47 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM doe_arm_trend_line_1v CALCULATES THE MONTHLY AVERAGE OF DOE ARM 
;  OBSERVATIONS FOR ONE VARIABLE, WHICH INCLUDE THE FOLLOWING:
;  (1 ) AEROSOL ABSORPTION OPTICAL DEPTH
;  (2 ) AOS NUMBER CONCENTRATION OF CCN
;  (3 ) PARTICLE CONCENTRATION
;
;  VARIABLES:
;  ============================================================================
;  (1 ) data_daily   (float): DAILY AVERAGE OF DOE ARM DATA, INCLUDING 
;                             YEAR, MONTH, DAY                         [---]
;  (2 ) data_monthly (float): MONTHLY AVERAGE OF DOE ARM DATA, INCLUDING
;                             YEAR, MONTH                              [---]
;  (3 ) ydata_monthly(float): MONTHLY AVERAGE OF DOE ARM DATA FOR MULTIYEAR, 
;                             INCLUDING MONTH                          [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/05/2012)
;******************************************************************************

;  LOAD LIBRARIES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/pro_fun.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/doe_arm/read_doe_arm_daily_average_1v.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/doe_arm/doe_arm_monthly_average_1v.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/doe_arm/doe_arm_monthly_average_1v_multiyear.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/marker_map.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/doe_arm/plot_trend_monthly_doe_arm_1v.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/doe_arm/plot_trend_monthly_doe_arm_1v_multiyear.ncl"


begin

;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_arm_trend_line_nccn_v01")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  DEFINE MISSING VALUE
   bv1        = -9999
   bv2        = -9999.
;  FOR PARTICLE CONCENTRATION
;  nmonth     = 24
;  FOR ALL LONG-TERM
   nmonth     = 240
   ynmonth    = 12

;  SET UP SITE INFO OF SGP
   longitude  = -97.5
   latitude   = 36.6

;  SET DIRECTORY AND FILE NAME LIST
   dir        = "/home/bruce/sshfs/pfw/doe_arm/sgp/"
   filelist   = "list_sgpaosccnC1.a1"
   fname      = asciiread(dir + filelist, -1, "string")
   nfname     = dimsizes(fname)

;  DEFINE VARIABLE ARRAYS
   data_daily   = new((/4, nfname/), float, bv2)
   data_monthly = new((/4, nmonth/), float, bv2)
   ydata_monthly= new((/3, ynmonth/), float, bv2)
   mpplot       = new(1, graphic)
   plot         = new(1, graphic)
   tplot        = new(1, graphic)
   mtplot       = new(1, graphic)

;  CALL SUBROUTINE read_doe_arm_daily_average_1v.ncl 
;  TO READ VARIABLES FROM ARM DATA
   read_doe_arm_daily_average_1v(dir, fname, nfname,\
                                 data_daily)

;  CALL SUBROUTINE doe_arm_monthly_average_1v.ncl
;  TO CALCULATE MONTHLY AVERAGE FOR MULTIYEAR
   doe_arm_monthly_average_1v(data_daily, \
                              data_monthly)

;  CALL SUBROUTINE doe_arm_monthly_average_1v_multiyear.ncl
;  TO CALCULATE MULTIPEAR MONTHLY AVERAGE OF ARM DATA
   doe_arm_monthly_average_1v_multiyear(data_daily, \
                                        ydata_monthly)

;  CALL SUBROUTINE marker_map TO PLOT SGP ON THE MAP
   marker_map(wks, longitude, latitude, mpplot, plot)

;  CALL SUBROUTINE plot_trend_monthly_doe_arm.ncl
;  TO PLOT THE MONTHLY AVERAGE TREND LINE
   plot_trend_monthly_doe_arm_1v(wks, data_monthly, nmonth, \
                                 mpplot, tplot)

;  CALL SUBROUTINE marker_map TO PLOT SGP ON THE MAP
   marker_map(wks, longitude, latitude, mpplot, plot)

;  CALL SUBROUTINE plot_trend_monthly_doe_arm_multiyear.ncl
;  TO PLOT THE MULTIYEAR MONTHLY AVERAGE OF ARM DATA
   plot_trend_monthly_doe_arm_1v_multiyear(wks, ydata_monthly, \
                                           ynmonth, mpplot,    \
                                           mtplot)
print("WELL DONE BRUCE!!!")

end
