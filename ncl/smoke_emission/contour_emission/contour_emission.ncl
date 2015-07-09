;  $ID : contour_emission.ncl V01 09/14/2013 13:43 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_emission READS SMOKE EMISSIONS (BINARY FILE, INCLUDING 
;  FLAMBE, FINN, GBBEP, GFED, FEER-SEVIRI, AND GFAS) AND GEOLOCATION INFO FROM 
;  met_em.d* FILE GENERATED FROM WPS. AND PLOTS THEM WITH CONTOUR.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (09/14/2013)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/Users/bruceyoung01/Documents/A/program/ncl/ncl_lib/function/int2string.ncl"
load "/Users/bruceyoung01/Documents/A/program/ncl/ncl_lib/procedure/universal/gsn_csm_epa.ncl"
load "/Users/bruceyoung01/Documents/A/program/ncl/ncl_lib/procedure/smoke_emission/plot_wrf_contour_variable_pm25j_daily.ncl"
load "/Users/bruceyoung01/Documents/A/program/ncl/ncl_lib/procedure/smoke_emission/plot_wrf_contour_variable_pm25j_monthly.ncl"
load "/Users/bruceyoung01/Documents/A/program/ncl/ncl_lib/procedure/smoke_emission/plot_wrf_contour_variable_pm25j_yearly.ncl"

begin

;  ECHO SYSTEM TIME
   tstrt = systemfunc("date")

;  SET UP THE PLOT PLATFORM
   type      = "x11"
;  type      = "pdf"
;  type      = "png"

;  DEFINE BAD VALUES
   bv1       = -9999
   bv2       = -9999.
   bv3       = "missingvalue"
   str       = "string"
;  FACTOR : CONVERT ug/m^2/s TO Gg
   factor    = 60.*60.*81.^2*10^(-7)

;  SPECIFY WRF EMISSION DIRECTORY
   dir       = "/Users/bruce/Documents/A/model/WRFChem/WRFChem3_5_1/WPS/"
   filename  = "met_em.d01.2010-02-01_00:00:00.nc"
   wdir      = "/Users/bruce/Documents/A/model/WEPS/results/"
;  wdir      = "/Volumes/TOSHIBA_3B/iproject/smoke_emission/weps_emission/"
   emission  = (/"SEVIRI"/)
;  emission  = (/"FLAMBE", "FINN", "GFED", "FEER_SEVIRI", "GFAS", "GBBEP", "QFED"/)
   cyear     = "2010"
   cmonth    = (/"02"/)
;  cmonth    = (/"01", "02", "03", "04", "05", "06", \
;                "07", "08", "09", "10", "11", "12"/)
   ncmonth   = dimsizes(cmonth)
   wfilelist = "2010_wrfem_d01_"
   nemission = dimsizes(emission)

;  SET UP LIMITED REGION
   minlat    = -10.0
   maxlat    =  20.0
   minlon    = -20.0
   maxlon    =  45.0

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
   re_pm25   = new(dim,  float)
   tpm25     = new(dim2, float)
   mtpm25    = new(dim3, float)
   mmtpm25   = new(dim3, float)
   plot      = new((/nemission/), graphic)

;  ============================================================================
;  FOR WEPS RESULTS GENERATED FROM TUSKER(UNIX), YOU NEED THIS STATEMENT
;  FOR WEPS RESULTS GENERATED FROM MODIS(MAC), YOU DO NOT NEED THIS STATEMENT
;  setfileoption("bin", "ReadByteOrder", "BigEndian")
;  ============================================================================

;  DO LOOP TO READ SMOKE EMISSION DATA FROM BINARY FILE
   mmtpm25   = 0.0
   do icmonth   = 0, ncmonth-1
      mtpm25    = 0.0
      wfilename = asciiread(wdir + emission(0) + "/" + wfilelist + cyear + cmonth(icmonth), -1, str)
      nfile     = dimsizes(wfilename)
      month     = str_get_cols(wfilename(0), 0, 6)
      wks       = gsn_open_wks(type, "1plt_contour_emission_d01_v13_total_" + month)
      gsn_define_colormap(wks,"WhGrYeOrReVi200")

;  DO LOOP TO READ SMOKE EMISSION DATA FROM BINARY FILE
      do i = 0, 1;nfile-1
         print("NOW PROCESSING : " + wfilename(i))
         do j = 0, hr-1
;  GET TIMES
            ahr   = stringtoint(str_get_cols(wfilename(i), 16, 17))
            ahr   = ahr + j + 1
            times = str_get_cols(wfilename(i), 0, 9) + " " + int2string(ahr) + ":00"
;  DERIVE PM2.5J RECORD NUMBER
            nrec  = 1 + 1 + j*(1 + nradm) + 1 + npm25j - 1
            do k = 0, nemission-1
               pm25 = fbinrecread(wdir + emission(k) + "/" + wfilename(i), nrec, dim, "float")
               pm25 = pm25*factor
               pm25!0 = "lat"
               pm25!1 = "level"
               pm25!2 = "lon"
;  REVERSE THE ORDER OF ARRAY pm25
               re_pm25 = pm25(lat|:, level|:, lon|:)
               re_pm25@lat2d = lat
               re_pm25@lon2d = lon
;  SUM ALL THE LEVELS
               tpm25 = dim_sum_n(re_pm25, 1)
               tpm25@lat2d = lat
               tpm25@lon2d = lon
               mtpm25(k, :, :) = mtpm25(k, :, :) + tpm25

;  CALL SUBROUTINE plot_wrf_contour_variable_pm25j_daily.ncl TO PLOT SMOKE EMISSION CONTOUR
               plot_wrf_contour_variable_pm25j_daily \
               (wks, emission(k), minlat, maxlat, minlon, maxlon, tpm25, times, plot(k))
            end do
            gsn_panel(wks,plot,(/2,3/),False)
            delete([/times/])
         end do
         mmtpm25 = mmtpm25 + mtpm25
      end do
;-----------------------------------------------------------------------------------
;  PLOT THE MONTHLY TOTAL SMOKE EMISSION
;-----------------------------------------------------------------------------------
      mtpm25@lat2d = lat
      mtpm25@lon2d = lon
      do k = 0, nemission-1
;  CALL SUBROUTINE plot_wrf_contour_variable_pm25j_monthly.ncl TO PLOT SMOKE EMISSION CONTOUR
         plot_wrf_contour_variable_pm25j_monthly \
         (wks, emission(k), minlat, maxlat, minlon, maxlon, mtpm25(k, :, :), month, plot(k))
      end do
      gsn_panel(wks,plot,(/3,3/),False)
      delete([/wfilename/])
   end do

;-----------------------------------------------------------------------------------
;  PLOT THE TOTAL SMOKE EMISSION
;-----------------------------------------------------------------------------------
;  CONVERT Gg TO Tg
   mmtpm25 = mmtpm25/1000.
   mmtpm25@lat2d = lat
   mmtpm25@lon2d = lon
   do k = 0, nemission-1
;  CALL SUBROUTINE plot_wrf_contour_variable_pm25j_yearly.ncl TO PLOT SMOKE EMISSION CONTOUR
      plot_wrf_contour_variable_pm25j_yearly \
      (wks, emission(k), minlat, maxlat, minlon, maxlon, mmtpm25(k, :, :), cyear, plot(k))
   end do
   gsn_panel(wks,plot,(/3,3/),False)
;  ECHO USED TIME FOR THIS PROGRAM
   wallClockElapseTime(tstrt, "contour_emission.ncl", 0)

end
