;  $ID: write_emission_whole.ncl V01 09/16/2013 11:43 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM write_emission_whole READS SMOKE EMISSION DATA, INCLUDING FLAMBE, FINN, 
;  GFED, FEER-SEVIRI, AND GFAS. COMPUTES THE PARAMETERS USED FOR PLOTING taylor 
;  DIAGRAMS, WHICH INCLUDES THE CORRELATION COEFFICIENT (R), THE CENTERED RMS 
;  DIFFERENCE (E), AND THE STANDARD DEVIATIONS OF THE "TEST" FIELD AND THE 
;  REFERENCE FIELD.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (09/16/2013)
;******************************************************************************
;
;  LOADING FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/function/correlation_nd.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/function/int2string.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/universal/gsn_csm_epa.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/smoke_emission/calculate_statistics.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/smoke_emission/write_smoke_hourly.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/smoke_emission/write_smoke_daily.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/smoke_emission/write_smoke_monthly.ncl"

begin

;  ECHO SYSTEM TIME
   tstrt = systemfunc("date")

;  DEFINE BAD VALUES
   bv1       = -9999
   bv2       = -9999.
   bv3       = "missingvalue"
   str       = "string"
;  FACTOR : CONVERT ug/m^2/s TO Gg
   factor    = 60.*60.*81.^2*10^(-7)

;  SPECIFY WRF EMISSION DIRECTORY
   dir       = "/work/jwang7/bruceyoung01/parallel/data/wrf_input/met_em/2010sahel_650_81/"
   filename  = "met_em.d01.2010-02-01_00:00:00.nc"
   wdir      = "/work/jwang7/bruceyoung01/parallel/data/wrf_input/smoke_emission/smoke_comparison/"
   emission  = (/"FLAMBE", "FINN", "GFED", "FEER_SEVIRI", "GFAS", "GBBEP", "QFED"/)
   cyear     = "2010"
   year      = stringtoint(cyear)
   cmonth    = (/"01", "02", "03", "04", "05", "06", \
                 "07", "08", "09", "10", "11", "12"/)
   ncmonth   = dimsizes(cmonth)
   wfilelist = "2010_wrfem_d01_"
   nemission = dimsizes(emission)
   setfileoption("bin", "ReadByteOrder", "BigEndian")

;  PARAMETERS RELATED TO RECORD NUMBER CALCULATION
   hr        = 12
   nhr       = 24
   nradm     = 30
   npm25j    = 21

;  READ LATITUDE, LONGITUDE FROM met_em FILE
   a         = addfile(dir + filename, "r")
   lat       = a->CLAT(0, :, :)
   lon       = a->CLONG(0, :, :)
   ndim      = dimsizes(lat)
   nlat      = ndim(0)
   nlon      = ndim(1)
   nlevel    = 19

;  DEFINE SMOKE EMISSION DATA DIMENSION
   dim          = (/nlat, nlevel, nlon/)
   dim2         = (/nlat, nlon/)
   dim3         = (/nemission, nlat, nlon/)
   dim4         = (/nemission/)
   tpm25        = new(dim2, float, bv2)
   rpm25        = new(dim2, float, bv2)
   rrpm25       = new(dim2, float, bv2)
   rrrpm25      = new(dim2, float, bv2)
   total_pm25_daily   = new(dim3, float, bv2)
   total_pm25_monthly = new(dim3, float, bv2)
   avg_hourly   = new(dim4, float, bv2)
   avg_daily    = new(dim4, float, bv2)
   avg_monthly  = new(dim4, float, bv2)
   sum_hourly   = new(dim4, float, bv2)
   sum_daily    = new(dim4, float, bv2)
   sum_monthly  = new(dim4, float, bv2)
   std_hourly   = new(dim4, float, bv2)
   std_daily    = new(dim4, float, bv2)
   std_monthly  = new(dim4, float, bv2)
   cv_hourly    = new(dim4, float, bv2)
   cv_daily     = new(dim4, float, bv2)
   cv_monthly   = new(dim4, float, bv2)
   ratio_hourly = new(dim4, float, bv2)
   ratio_daily  = new(dim4, float, bv2)
   ratio_monthly= new(dim4, float, bv2)
   r_hourly     = new(dim4, float, bv2)
   r_daily      = new(dim4, float, bv2)
   r_monthly    = new(dim4, float, bv2)
   rtstd_hourly = new(dim4, float, bv2)
   rtstd_daily  = new(dim4, float, bv2)
   rtstd_monthly= new(dim4, float, bv2)
   plot         = new((/1/), graphic)

;  DO MONTH LOOP TO READ SMOKE EMISSION DATA MONTH BY MONTH
   switch  = 0
   sswitch = 0
   ssswitch= 0
   do icmonth   = 0, ncmonth-1
      wfilename = asciiread(wdir + emission(0) + "/" + wfilelist + cyear + cmonth(icmonth), -1, str)
      nfile     = dimsizes(wfilename)
      ntotal    = nfile*nhr
      month     = stringtoint(cmonth(icmonth))

;  DEFINE NEW ARRAY
      dim5      = (/nemission, ntotal, nlat, nlon/)
      total_pm25= new(dim5, float)

;  DO LOOP TO READ SMOKE EMISSION DATA FROM BINARY FILE
;  DEFINE NEW ARRAY
      dim6           = (/nemission, nhr, nlat, nlon/)
      total_pm25_nhr = new(dim6, float)
      icount    = 0
      do i = 0, nfile-1, 2
         print("NOW PROCESSING : " + wfilename(i))
         day     = stringtoint(str_get_cols(wfilename(i), 8, 9))
;  DERIVE PM2.5J RECORD NUMBER
         do j = 0, nhr-1
;  GET TIMES
            do k = 0, nemission-1
               if (j .le. 11) then
                  nrec  = 1 + 1 + j*(1 + nradm) + 1 + npm25j - 1
                  ahr   = j + 1
                  times = str_get_cols(wfilename(i), 0, 9) + " " + int2string(ahr) + ":00"
                  pm25  = fbinrecread(wdir + emission(k) + "/" + wfilename(i),   nrec, dim, "float")
               else
                  nrec = 1 + 1 + (j-hr)*(1 + nradm) + 1 + npm25j - 1
                  ahr   = j + 1
                  times = str_get_cols(wfilename(i), 0, 9) + " " + int2string(ahr) + ":00"
                  pm25  = fbinrecread(wdir + emission(k) + "/" + wfilename(i+1), nrec, dim, "float")
               end if
               pm25 = pm25*factor
               print( emission(k) + times)
;  SUM ALL THE LEVELS
               tpm25 = dim_sum_n(pm25, 1)
               total_pm25(k, icount, :, :) = tpm25
               total_pm25_nhr(k, j, :, :)  = tpm25
            end do
;  =============================HOURLY====================================================================
            rpm25 = dim_avg_n(total_pm25(:, icount, :, :), 0)
            do k = 0, nemission-1
;  CALL SUBROUTINE calculate_statistics.ncl TO CALCULATE STATISTICS INFO
               calculate_statistics(bv2, total_pm25(k, icount, :, :), rpm25, std_hourly(k), \
                                    cv_hourly(k), avg_hourly(k), sum_hourly(k),             \
                                    rtstd_hourly(k), r_hourly(k))
;  CALL SUBROUTINE write_smoke_hourly.ncl TO WRITE STATISTICS INFO INTO AN ASCII FILE
               write_smoke_hourly(switch, emission(k), year, month, day, ahr, std_hourly(k), \
                                  cv_hourly(k), avg_hourly(k), sum_hourly(k), rtstd_hourly(k), r_hourly(k))
            end do
            icount = icount + 1
            switch = switch + 1
         end do
;  =============================DAILY======================================================================
         total_pm25_daily = dim_avg_n(total_pm25_nhr, 1)
         rrpm25           = dim_avg_n(total_pm25_daily, 0)
         do k = 0, nemission-1
;  CALL SUBROUTINE calculate_statistics.ncl TO CALCULATE STATISTICS INFO
            calculate_statistics(bv2, total_pm25_daily(k, :, :), rrpm25, std_daily(k), \
                                 cv_daily(k), avg_daily(k), sum_daily(k),              \
                                 rtstd_daily(k), r_daily(k))
;  CALL SUBROUTINE write_smoke_daily.ncl TO WRITE STATISTICS INFO INTO AN ASCII FILE
            write_smoke_daily(sswitch, emission(k), year, month, day, std_daily(k), \
                              cv_daily(k), avg_daily(k), sum_daily(k), rtstd_daily(k), r_daily(k))
         end do
         sswitch = sswitch + 1
      end do

;  =============================MONTHLY======================================================================
      total_pm25_monthly = dim_avg_n(total_pm25, 1)
      rrrpm25            = dim_avg_n(total_pm25_monthly, 0)
      do k = 0, nemission-1
;  CALL SUBROUTINE calculate_statistics.ncl TO CALCULATE STATISTICS INFO
         calculate_statistics(bv2, total_pm25_monthly(k, :, :), rrrpm25, std_monthly(k), \
                              cv_monthly(k), avg_monthly(k), sum_monthly(k),             \
                              rtstd_monthly(k), r_monthly(k))
;  CALL SUBROUTINE write_smoke_monthly.ncl TO WRITE STATISTICS INFO INTO AN ASCII FILE 
         write_smoke_monthly(ssswitch, emission(k), year, month, std_monthly(k), \
                             cv_monthly(k), avg_monthly(k), sum_monthly(k), rtstd_monthly(k), r_monthly(k))
      end do
      ssswitch = ssswitch + 1

     delete([/wfilename, total_pm25/])
   end do

;  ECHO USED TIME FOR THIS PROGRAM
   wallClockElapseTime(tstrt, "write_emission.ncl", 0)

end
