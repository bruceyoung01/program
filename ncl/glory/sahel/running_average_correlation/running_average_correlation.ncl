; $ID: running_average_correlation.ncl V01 05/11/2012 11:22 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM running_average_correlation PLOTS THE CORRELATION BETWEEN AERONET 
;  AND WRFCHEM WITH DIFFERENT NUMBER OF RUNNING AVERAGE.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/11/2012)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/read_asc4_bruce/read_asc4_bruce.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/plot_trend_marker.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
;  type     = "x11"
   type     = "pdf"
;  type     = "png"
   wks      = gsn_open_wks(type,"1plt_aeronet_wrf_running_average_correlation_v01")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  CORRELATION DATA DIRECTORY AND FILENAME
   dir      = "/home/bruce/program/ncl/tutorial/test/sahel/running_average_correlation/"
   filelist = "aeronet_correlation_list"
   fname    = asciiread(dir + filelist, -1, "string")
   nsites   = dimsizes(fname)

;  SET UP BAD VALUE
   bv1      = -9999
   bv2      = -9999.
;  SET UP INFO OF DATA FILE
   nheader  = 1
   nfooter  = 0
   nline    = 10
   sitename = new(1, string)
   nave     = new(nline, integer, bv1)
   cor_coe  = new(nline, float, bv2)
   rmse     = new(nline, float, bv2)

;  DEFINE VARIABLES FOR plot_trend_marker.ncl
   tawplot  = new(1, graphic)

;  DO # OF SITES LOOP
   do i = 0, nsites-1
    print("NOW WORKING ON " + i + " OF " + nsites)
;  CALL SUBROUTINE read_asc4_bruce.ncl TO READ DATA
    read_asc4_bruce(dir, fname(i), nheader, nfooter, \
                    sitename, nave, cor_coe, rmse)

;  CALL SUBROUTINE plot_trend_marker.ncl TO PLOT 
;  CORRELATION COEFFICIENT AND RMSE
    plot_trend_marker(wks, sitename, nave, cor_coe, rmse, tawplot)
   end do

end
