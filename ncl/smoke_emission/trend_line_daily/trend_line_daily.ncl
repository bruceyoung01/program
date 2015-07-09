;  $ID: trend_line_daily.ncl V01 09/24/2013 09:06 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM trend_line_daily READS SMOKE EMISSION HOURLY FILE, INCLUDING 
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
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/smoke_emission/read_smoke_text_daily.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/smoke_emission/plot_trend_daily_year.ncl"


begin

;  ECHO SYSTEM TIME
   tstrt     = systemfunc("date")

;  SET UP THE PLOT PLATFORM
;  type      = "x11"
   type      = "pdf"
;  type      = "png"
   wks        = gsn_open_wks(type,"1plt_trend_line_daily_year_v06")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

   
;  DEFINE BAD VALUES
   bv1       = -9999
   bv2       = -9999.
   bv3       = "missingvalue"
   str       = "string"
   factor    = 1000.
   l_leap    = False
   if (l_leap) then
      nday = 366
   else
      nday = 365
   end if

;  DIRECTORY OF PREPARED TEXT FILE
   dir       = "/Users/bruce/Documents/A/program/ncl/smoke_emission/write_emission/"
   filelist  = "daily_list"
   fname     = asciiread(dir + filelist, -1, "string")
   nemission = dimsizes(fname)

;  DEFINE NEW ARRAY FOR READING DATA
   nline     = nday
   dim1      = (/nemission, nline/)
   dim2      = (/nemission/)
   year      = new(dim1, integer, bv1)
   month     = new(dim1, integer, bv1)
   day       = new(dim1, integer, bv1)
   sstd      = new(dim1, float,   bv2)
   scv       = new(dim1, float,   bv2)
   savg      = new(dim1, float,   bv2)
   ssum      = new(dim1, float,   bv2)
   sratio    = new(dim1, float,   bv2)
   sr        = new(dim1, float,   bv2)
   ssum_avg  = new(dim2, float,   bv2)
   emission  = new(dim2, string,  str)
   plot      = new(dim2, graphic)
   plot1     = new(dim2, graphic)

;  DO EMISSION LOOP TO READ EMISSION DATA ONE BY ONE
   do i = 0, nemission-1
      read_smoke_text_daily \
      (dir, fname(i), year(i, :), month(i, :), day(i, :), \
       sstd(i, :), scv(i, :), savg(i, :), ssum(i, :), sratio(i, :), sr(i, :))
      emission(i) = str_get_cols(fname(i), -30, -16)
      ssum_avg(i) = avg(ssum(i, :))
      print("Complete = " + emission(i))
;  CONVERT Gg TO Tg
      ssum     = ssum/factor
      ssum_avg = ssum_avg/factor
;  CALL SUBROUTINE plot_trend_daily_year.ncl TO PLOT TREND LINE HOURLY
      plot_trend_daily_year \
      (wks, l_leap, nday, emission(i), ssum(i, :), ssum_avg(i), plot(i), plot1(i))
   end do
   gsn_panel(wks,plot,(/3,3/),False)

end
