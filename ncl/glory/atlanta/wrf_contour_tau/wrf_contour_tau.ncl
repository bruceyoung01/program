; $ID: wrf_contour_tau.ncl V01 05/18/2012 10:36 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_contour_tau READS AND PLOTS AOD CONTOUR AT DIFFERENT WAVELENGTH.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) 
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/18/2012)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/plot_wrf_contour_variable_aod.ncl"


begin
;  SET UP THE PLOT PLATFORM
;  type      = "x11" 
   type      = "pdf"
;  type      = "ps"
;  type      = "png"
   wks       = gsn_open_wks(type, "1plt_wrf_contour_tau_v02")
   gsn_define_colormap(wks,"WhGrYeOrReVi200")

;  DEFINE BAD VALUES
   bv1       = -9999
   bv2       = -9999.
   bv3       = "missingvalue"
   str       = "string"

   factor    = 1.8

;  SPECIFY WRF OUTPUT DIRECTORY
   dir       = "/home/bruce/sshfs/shw/data/wrf_output/wrfout_atlanta/"
   filelist  = "2012_wrfout_d03_night"
   filename  = asciiread(dir + filelist, -1, str)
   nfile     = dimsizes(filename)

;  SET UP LIMITED REGION
   minlat    =  33.0
   maxlat    =  34.5
   minlon    = -85.5
   maxlon    = -83.0
   plot      = new(1, graphic)

;  DO FILE NAME LOOP TO READ AND PLOT EACH FILE
   do i = 0, nfile-1
    a    = addfile(dir + filename(i) + ".nc", "r")
    time = a->Times(0, :)
    print("NOW WORKING ON : " + time)
    lat  = a->XLAT
    lon  = a->XLONG
    tau  = a->TAUAER2(0, :, :, :)
    ttau = dim_sum_n(tau, 0)*factor
    ttau@lat2d = a->XLAT(0,:,:)
    ttau@lon2d = a->XLONG(0,:,:)

;  CALL SUBROUTINE plot_wrf_contour_variable_aod.ncl TO PLOT CONTOUR 
    plot_wrf_contour_variable_aod \
    (wks, minlat, maxlat, minlon, maxlon, time, ttau)
   
   end do    
end

