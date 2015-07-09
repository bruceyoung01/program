;  $ID: trend_line_diurnal.ncl V01 09/24/2013 09:06 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM trend_line_diurnal READS SMOKE EMISSION HOURLY FILE, INCLUDING 
;  AVERAGE, SUM, STANDARD DEVIATION, RATIO, AND CORRELATION CORFFICIENT WITH 
;  REFERENCE FIELD, AND PLOTS AS DIURNAL TREND LINE.
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
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/universal/gsn_csm_epa.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/smoke_emission/read_smoke_text_hourly.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/smoke_emission/plot_trend_diurnal7.ncl"


begin

;  ECHO SYSTEM TIME
   tstrt     = systemfunc("date")

;  SET UP THE PLOT PLATFORM
;  type      = "x11"
   type      = "pdf"
;  type      = "png"
   wks        = gsn_open_wks(type,"1plt_trend_line_diurnal_year_v02")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

   
;  DEFINE BAD VALUES
   bv1       = -9999
   bv2       = -9999.
   bv3       = "missingvalue"
   str       = "string"
   l_leap    = False
   nhr       = 24
   if (l_leap) then
      nday = 366
   else
      nday = 365
   end if

;  DIRECTORY OF PREPARED TEXT FILE
   dir       = "/work/jwang7/bruceyoung01/model/ncl/smoke_emission/write_emission/"
   filelist  = "hourly_list"
   fname     = asciiread(dir + filelist, -1, "string")
   nemission = dimsizes(fname)

;  DEFINE NEW ARRAY FOR READING DATA
   nline     = nday*nhr
   dim1      = (/nemission, nline/)
   dim2      = (/nemission/)
   dim3      = (/nemission, nhr/)
   year      = new(dim1, integer, bv1)
   month     = new(dim1, integer, bv1)
   day       = new(dim1, integer, bv1)
   hour      = new(dim1, integer, bv1)
   sstd      = new(dim1, float,   bv2)
   scv       = new(dim1, float,   bv2)
   savg      = new(dim1, float,   bv2)
   ssum      = new(dim1, float,   bv2)
   sratio    = new(dim1, float,   bv2)
   sr        = new(dim1, float,   bv2)
   ssum_avg  = new(dim3, float,   bv2)
   sssum_avg = new(dim2, float,   bv2)
   emission  = new(dim2, string,  str)
   plot      = new(dim2, graphic)

;  DO EMISSION LOOP TO READ EMISSION DATA ONE BY ONE
   ssum_avg = 0.0
   do i = 0, nemission-1
      read_smoke_text_hourly \
      (dir, fname(i), year(i, :), month(i, :), day(i, :), hour(i, :), \
       sstd(i, :), scv(i, :), savg(i, :), ssum(i, :), sratio(i, :), sr(i, :))
      emission(i) = str_get_cols(fname(i), -33, -17)
      print("Complete = " + emission(i))

;  CALCULATE DIURNAL VARIATION
      do j = 0, nhr-1
         total  = 0.0
         icount = 0
         do k = 0, nday-1
            l = k*nhr+j
            if (ismissing(ssum(i, l))) then
               total = total
            else
               total  = total + ssum(i, l)
               icount = icount + 1
            end if
         end do
         if (icount .gt. 0) then
            ssum_avg(i, j) = total/icount
         else
            ssum_avg(i, j) = 0.0
         end if
      end do
;  CONVERT Gg TO Tg
      ssum_avg     = ssum_avg + 1
      sssum_avg(i) = avg(ssum_avg(i, :))
   end do
;  CALL SUBROUTINE plot_trend_diurnal7.ncl TO PLOT TREND LINE HOURLY
   plot_trend_diurnal7 \
   (wks, emission, ssum_avg, sssum_avg, nhr)

end
