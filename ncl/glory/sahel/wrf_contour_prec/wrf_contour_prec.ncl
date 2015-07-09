;  $ID: wrf_contour_prec.ncl V01 03/06/2013 22:14 BRUCE EXP$
;******************************************************************************
;  PROGRAM wrf_contour_prec PLOTS THE CONTOUR PLOT USING WRF/CHEM OUTPUT 
;  THE STEPS ARE AS FOLLOWING : 
;  (1 ) READ DATA FROM WRF OUTPUT .NC FILE
;  (2 ) PLOT A MAP WITH A SPECIFIED PROJECTION (NOT NATIVE)
;  (3 ) PLOT A CONTOUR OVER A MAP
;  (4 ) MODIFY FOR ONE-HOUR PER FILE (BRUCE 11/15/2011 CONTINUING)
;  (5 ) PLOT TOTAL PRECIPITATION. (BRUCE 02/29/2012 23:38)
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (03/06/2013)
;******************************************************************************
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_wrf_contour_variable_prec.ncl"

begin

;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_wrf_contour_prec_2008-02_v04")
   gsn_define_colormap(wks,"WhGrYeOrReVi200")

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -9999
   bv2        = -9999.

;  SET UP STUDY REGION
   minlat     = -15.0
   maxlat     =  35.0
   minlon     = -25.0
   maxlon     =  45.0

;  OPEN WRF/CHEM OUTPUT FILE
   dir        = "/home/bruce/sshfs/shw/data/wrf_output/wrfout_sahel_85_smoke_dust_650/wrfout/"
   filelist   = "2008_wrfout_d01_00"
   fname      = asciiread(dir + filelist, -1, "string")
   nfname     = dimsizes(fname)

;  GET THE DIMENSION OF WRF OUTPUT DATA
   a          = addfile(dir + fname(0) + ".nc", "r")
   v_2d       = a->RAINNC(0, :, :)
   ndim       = dimsizes(v_2d)
   nlat       = ndim(0)
   nlon       = ndim(1)
;  DEFINE A NEW ARRAY FOR MONTHLY DATA
   rain       = new((/nlat, nlon/), float, bv2)
   rain       = 0.0
   icount     = 0
;  PLOT THE CONTOUR OVER THE CE MAP
   do i = 0, nfname-1
    a              = addfile(dir + fname(i) + ".nc", "r")
;  READ PRECIPITATION DATA FROM WRF/CHEM OUTPUT FILE AND 
;  SET XLAT AND XLONG AS THE ATTRIBUTE OF PRECIPITATION
    times          = a->Times
    time           = charactertostring(times)
    print("NOW WORKING ON : " + time)
    rain_exp       = a->RAINNC(0,:,:)
    rain_con       = a->RAINC(0,:,:)
    rain_tot       = rain_exp + rain_con
    rain_tot@lat2d = a->XLAT(0,:,:)
    rain_tot@lon2d = a->XLONG(0,:,:)
    rain           = rain + rain_tot
    icount         = icount + 1
;  CALL SUBROUTINE plot_wrf_contour_variable_prec.ncl TO PLOT CONTOUR
    plot_wrf_contour_variable_prec \
    (wks, minlat, maxlat, minlon, maxlon, rain_tot, time)
   end do

;  ===========================PROCESS MONTHLY DATA=============================
   printMinMax(rain, True)
   rain = rain/icount
   rain@lat2d = a->XLAT(0,:,:)
   rain@lon2d = a->XLONG(0,:,:)
;  CALL SUBROUTINE plot_wrf_contour_variable_prec.ncl TO PLOT MONTHLY CONTOUR
   plot_wrf_contour_variable_prec \
   (wks, minlat, maxlat, minlon, maxlon, rain, time)
end
