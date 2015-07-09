;  $ID : trend_line_emission_diurnal.ncl V01 09/15/2013 11:15 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM trend_line_emission_diurnal READS SMOKE EMISSIONS (BINARY FILE, 
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
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/smoke_emission/plot_trend_diurnal5.ncl"

begin

;  ECHO SYSTEM TIME
   tstrt = systemfunc("date")

;  SET UP THE PLOT PLATFORM
;  type      = "x11"
   type      = "pdf"
;  type      = "png"
   wks       = gsn_open_wks(type, "1plt_trend_line_emission_diurnal_d01_v03")
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
   wfilelist = "2010_wrfem_d01"
   wfilename = asciiread(wdir + emission(0) + "/" + wfilelist, -1, str)
   nfile     = dimsizes(wfilename)
   nemission = dimsizes(emission)

;  PARAMETERS RELATED TO RECORD NUMBER CALCULATION
   hr        = 12
   nhr       = 24
   nday      = nfile/2
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
   tpm25     = new((/nemission, nhr/), float)
   mtpm25    = new((/nemission/), float)

   tpm25     = 0.0
   mtpm25    = 0.0
   icount    = 0
;  DO LOOP TO READ SMOKE EMISSION DATA FROM BINARY FILE
   setfileoption("bin", "ReadByteOrder", "BigEndian")
   do i = 0, nfile-1, 2
      print("NOW PROCESSING : " + wfilename(i))
      print("NOW PROCESSING : " + wfilename(i+1))
;  DERIVE PM2.5J RECORD NUMBER
      do k = 0, nemission-1
         sum_pm25 = 0.0
         do j = 0, nhr-1
            if (j .le. 11) then
               nrec = 1 + 1 + j*(1 + nradm) + 1 + npm25j - 1
               pm25 = fbinrecread(wdir + emission(k) + "/" + wfilename(i), nrec, dim, "float")
            else
               nrec = 1 + 1 + (j-hr)*(1 + nradm) + 1 + npm25j - 1
               pm25 = fbinrecread(wdir + emission(k) + "/" + wfilename(i+1), nrec, dim, "float")
            end if
            tpm25(k, j) = tpm25(k, j) + sum(pm25)
         end do
      end do
      icount = icount + 1
   end do
;-----------------------------------------------------------------------------------
;  PLOT THE TREND LINE FOR ALL THE FIVE EMISSIONS
;-----------------------------------------------------------------------------------
   tpm25       = tpm25/icount
   mtpm25_mean = dim_avg_n(tpm25, 1)

;  CALL SUBROUTINE plot_trend_diurnal5.ncl TO PLOT TREND LINE
   plot_trend_diurnal5 \
   (wks, emission, tpm25, mtpm25_mean, nhr)
;  ECHO USED TIME FOR THIS PROGRAM
   wallClockElapseTime(tstrt, "plot_trend_diurnal5.ncl", 0)

end
