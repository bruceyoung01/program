;  $ID : trend_line_emission_hourly.ncl V01 09/15/2013 11:15 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM trend_line_emission_hourly READS SMOKE EMISSIONS (BINARY FILE, 
;  INCLUDING FLAMBE, FINN, GBBEP, GFED, FEER-SEVIRI, AND GFAS) AND GEOLOCATION 
;  INFO FROM met_em.d* FILE GENERATED FROM WPS. AND PLOTS THEM WITH TREND LINE.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (09/15/2013)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/int2string.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/smoke_emission/plot_trend_hourly5.ncl"

begin

;  ECHO SYSTEM TIME
   tstrt = systemfunc("date")

;  SET UP THE PLOT PLATFORM
;  type      = "x11"
   type      = "pdf"
;  type      = "png"
   wks       = gsn_open_wks(type, "1plt_trend_line_emission_hourly_d01_v02_201004")
   gsn_define_colormap(wks,"WhGrYeOrReVi200")

;  DEFINE BAD VALUES
   bv1       = -9999
   bv2       = -9999.
   bv3       = "missingvalue"
   str       = "string"

;  SPECIFY WRF EMISSION DIRECTORY
   dir       = "/home/bruce/sshfs/tw/parallel/data/wrf_input/met_em/2010sahel_650_81/"
   filename  = "met_em.d01.2010-02-01_00:00:00.nc"
   wdir      = "/home/bruce/sshfs/tw/model/UNL_WRFChem/WEPS_v04/results/"
   emission  = (/"FLAMBE", "FINN", "GFED", "FEER_SEVIRI", "GFAS", "GBBEP"/)
   wfilelist = "2010_wrfem_d01_201004"
   wfilename = asciiread(wdir + emission(0) + "/" + wfilelist, -1, str)
   nfile     = dimsizes(wfilename)
   nemission = dimsizes(emission)

;  SET UP LIMITED REGION
   minlat    =-15.0
   maxlat    = 35.0
   minlon    =-25.0
   maxlon    = 45.0

;  PARAMETERS RELATED TO RECORD NUMBER CALCULATION
   hr        = 12
   nradm     = 30
   npm25j    = 21
   nday      = nfile/2

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
   tpm25     = new((/nemission, nfile*hr/), float)
   mtpm25    = new((/nemission/), float)

   mtpm25    = 0.0
   icount    = 0
;  DO LOOP TO READ SMOKE EMISSION DATA FROM BINARY FILE
   do i = 0, nfile-1
      print("NOW PROCESSING : " + wfilename(i))
      setfileoption("bin", "ReadByteOrder", "BigEndian")
;  DERIVE PM2.5J RECORD NUMBER
      do j = 0, hr-1
         do k = 0, nemission-1
            nrec = 1 + 1 + j*(1 + nradm) + 1 + npm25j - 1
            pm25 = fbinrecread(wdir + emission(k) + "/" + wfilename(i), nrec, dim, "float")
            tpm25(k, (i*hr+j)) = sum(pm25)
         end do
         icount = icount + 1
      end do
   end do
;-----------------------------------------------------------------------------------
;  PLOT THE TREND LINE FOR ALL THE FIVE EMISSIONS
;-----------------------------------------------------------------------------------
   mtpm25_mean = dim_avg_n(tpm25, 1)

;  CALL SUBROUTINE plot_trend_hourly5.ncl TO PLOT TREND LINE
   plot_trend_hourly5 \
   (wks, emission, tpm25, mtpm25_mean, nday)
;  ECHO USED TIME FOR THIS PROGRAM
   wallClockElapseTime(tstrt, "plot_trend_hourly5.ncl", 0)

end
