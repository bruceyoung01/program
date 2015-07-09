;  $ID: taylor_disgrams.ncl V01 09/16/2013 11:43 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM taylor_disgrams READS SMOKE EMISSION DATA, INCLUDING FLAMBE, FINN, 
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
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/universal/taylor_diagram.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/universal/taylor_metrics_table.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/smoke_emission/plot_taylor_diagram.ncl"


begin

;  ECHO SYSTEM TIME
   tstrt = systemfunc("date")

;  SET UP THE PLOT PLATFORM
;  type      = "x11"
   type      = "pdf"
;  type      = "png"

;  DEFINE BAD VALUES
   bv1       = -9999
   bv2       = -9999.
   bv3       = "missingvalue"
   str       = "string"

;  LOGIC TO CALCULATE STANDARD DEVIATION OR CORRELATION OF VARIATION
;  STANDARD DEVIATION       = "t_stddev"
;  CORRELATION OF VARIATION = "t_cv"
   l_stddev_cv = "t_stddev"

;  SPECIFY WRF EMISSION DIRECTORY
   dir       = "/work/jwang7/bruceyoung01/parallel/data/wrf_input/met_em/2010sahel_650_81/"
   filename  = "met_em.d01.2010-02-01_00:00:00.nc"
   wdir      = "/work/jwang7/bruceyoung01/model/UNL_WRFChem/WEPS_v03/results/"
   emission  = (/"FLAMBE", "FINN", "GFED", "FEER_SEVIRI", "GFAS"/)
   var       = (/" "/)
   cyear     = "2010"
   cmonth    = (/"01", "02", "03", "04", "05", "06", \
                 "07", "08", "09", "10", "11", "12"/)
   ncmonth   = dimsizes(cmonth)
   wfilelist = "2010_wrfem_d01_"
   nemission = dimsizes(emission)
   nvar      = dimsizes(var)
   setfileoption("bin", "ReadByteOrder", "BigEndian")

;  PARAMETERS RELATED TO RECORD NUMBER CALCULATION
   hr        = 12
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
   dim       = (/nlat, nlevel, nlon/)
   dim2      = (/nlat, nlon/)
   dim3      = (/nemission, nlat, nlon/)
   tpm25     = new(dim2, float)
   avg_tpm25p   = new(dim2, float)
   mavg_tpm25p  = new(dim2, float)
   mmavg_tpm25p = new(dim2, float)
   mtpm25p   = new(dim3, float)
   mtpm25    = new(dim3, float)
   mmtpm25   = new(dim3, float)
   plot      = new((/1/), graphic)

;  DO MONTH LOOP TO READ SMOKE EMISSION DATA MONTH BY MONTH
   mmtpm25 = 0.0
   do icmonth   = 0, ncmonth-1
      mtpm25    = 0.0
      wfilename = asciiread(wdir + emission(0) + "/" + wfilelist + cyear + cmonth(icmonth), -1, str)
      nfile     = dimsizes(wfilename)
      month     = str_get_cols(wfilename(0), 0, 6)
      wks       = gsn_open_wks(type, "1plt_taylor_diagram_" + l_stddev_cv + "_d01_v02_" + month)
      gsn_define_colormap(wks,"WhGrYeOrReVi200")

;  DO LOOP TO READ SMOKE EMISSION DATA FROM BINARY FILE
      do i = 0, nfile-1
         print("NOW PROCESSING : " + wfilename(i))
         mtpm25p = 0.0

;  DERIVE PM2.5J RECORD NUMBER
         do j = 0, hr-1
;  GET TIMES
            ahr   = stringtoint(str_get_cols(wfilename(i), 16, 17))
            ahr   = ahr + j + 1
            times = str_get_cols(wfilename(i), 0, 9) + " " + int2string(ahr) + ":00"
            nrec  = 1 + 1 + j*(1 + nradm) + 1 + npm25j - 1 
            do k = 0, nemission-1
               print( emission(k) + times)
               pm25 = fbinrecread(wdir + emission(k) + "/" + wfilename(i), nrec, dim, "float")
;  SUM ALL THE LEVELS
               tpm25 = dim_sum_n(pm25, 1)
               mtpm25p(k, :, :) = tpm25
               mtpm25(k, :, :)  = mtpm25(k, :, :) + tpm25
            end do
;  CALCULATE HOURLY taylor DIAGRAM INFO
            avg_mtpm25p = dim_avg_n(mtpm25p, 0)
;  CALL SUBROUTINE plot_taylor_diagram.ncl TO PLOT TAYLOR DIAGRAM
            plot_taylor_diagram \
            (wks, l_stddev_cv, times, emission, var, mtpm25p, avg_mtpm25p, plot)
         end do
      end do
;  CALCULATE MONTHLY taylor DIAGRAM INFO
      mavg_mtpm25 = dim_avg_n(mtpm25, 0)
      month = str_get_cols(wfilename(i), 0, 6)
;  CALL SUBROUTINE plot_taylor_diagram.ncl TO PLOT TAYLOR DIAGRAM
      plot_taylor_diagram \
     (wks, l_stddev_cv, month, emission, var, mtpm25, mavg_mtpm25, plot)
     delete([/wfilename/])
     mmtpm25 = mmtpm25 + mtpm25
   end do

;  CALCULATE TOTAL taylor DIAGRAM INFO
   mmavg_mtpm25  = dim_avg_n(mmtpm25, 0)
   year          = str_get_cols(month, 0, 3)
;  CALL SUBROUTINE plot_taylor_diagram.ncl TO PLOT TAYLOR DIAGRAM
   plot_taylor_diagram \
   (wks, l_stddev_cv, year, emission, var, mmtpm25, mmavg_mtpm25, plot)

;  ECHO USED TIME FOR THIS PROGRAM
   wallClockElapseTime(tstrt, "taylor_disgrams.ncl", 0)

end
