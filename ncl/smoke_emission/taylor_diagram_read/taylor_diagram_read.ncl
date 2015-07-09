;  $ID: taylor_diagram_read.ncl V01 09/24/2013 09:06 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM taylor_diagram_read READS SMOKE EMISSION MONTHLY FILE, INCLUDING 
;  AVERAGE, SUM, STANDARD DEVIATION, RATIO, AND CORRELATION CORFFICIENT WITH 
;  REFERENCE FIELD, AND PLOTS AS TREND LINE.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (09/24/2013)
;******************************************************************************
;
;  LOADING FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/universal/gsn_csm_epa.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/universal/taylor_diagram.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/smoke_emission/read_smoke_text_monthly.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/smoke_emission/plot_taylor_diagram_read.ncl"


begin

;  ECHO SYSTEM TIME
   tstrt     = systemfunc("date")

;  SET UP THE PLOT PLATFORM
   type      = "x11"
;  type      = "pdf"
;  type      = "png"
   wks        = gsn_open_wks(type,"1plt_taylor_diagram_stddev_read_month_v02")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

   
;  DEFINE BAD VALUES
   bv1       = -9999
   bv2       = -9999.
   bv3       = "missingvalue"
   str       = "string"
   factor    = 5.
   nmonth    = 12

   var       = (/" "/)
   cyear     = "2010 "
   cmonth    = (/"01", "02", "03", "04", "05", "06", \
                 "07", "08", "09", "10", "11", "12"/)
   cy_mon    = cyear + cmonth

;  DIRECTORY OF PREPARED TEXT FILE
   dir       = "/Users/bruce/Documents/A/program/ncl/smoke_emission/write_emission/"
   filelist  = "monthly_list"
   fname     = asciiread(dir + filelist, -1, "string")
   nemission = dimsizes(fname)

;  DEFINE NEW ARRAY FOR READING DATA
   nline     = nmonth
   dim1      = (/nemission, nline/)
   dim2      = (/nemission/)
   dim3      = (/nemission, 1/)
   year      = new(dim1, integer, bv1)
   month     = new(dim1, integer, bv1)
   sstd      = new(dim1, float,   bv2)
   scv       = new(dim1, float,   bv2)
   savg      = new(dim1, float,   bv2)
   ssum      = new(dim1, float,   bv2)
   sratio    = new(dim1, float,   bv2)
   sr        = new(dim1, float,   bv2)
   pcv       = new(dim3, float,   bv2)
   pr        = new(dim3, float,   bv2)
   emission  = new(dim2, string,  str)
   plot      = new(dim2, graphic)
;  plot1     = new(dim2, graphic)

;  DO EMISSION LOOP TO READ EMISSION DATA ONE BY ONE
   do i = 0, nemission-1
      read_smoke_text_monthly \
      (dir, fname(i), year(i, :), month(i, :), \
       sstd(i, :), scv(i, :), savg(i, :), ssum(i, :), sratio(i, :), sr(i, :))
      emission(i) = str_get_cols(fname(i), -33, -18)
      print("Complete = " + emission(i))
   end do

;  DO MONTH LOOP TO PLOT TAYLOR DIAGRAM
   do j = 0, nmonth-1
      print("Start to plot = " + cy_mon(j))
      pcv(:, 0)    = sratio(:, j)/factor
      pr(:, 0)     = sr(:, j)
;  CALL SUBROUTINE plot_taylor_diagram.ncl TO PLOT TAYLOR DIAGRAM MONTHLY
      plot_taylor_diagram_read \
     (wks, cy_mon(j), emission, var, pcv, pr, plot)
   end do

   pcv(:, 0) = dim_avg_n(sratio, 1)/factor
   pr(:, 0)  = dim_avg_n(pr, 1)
;  CALL SUBROUTINE plot_taylor_diagram.ncl TO PLOT TAYLOR DIAGRAM MONTHLY
   plot_taylor_diagram_read \
  (wks, cyear, emission, var, pcv, pr, plot)

;  gsn_panel(wks,plot,(/2,3/),False)

end
