;  $ID: contour_gfed_datasources.ncl V01 09/09/2013 14:50 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_gfed_datasources.ncl READS DATA SOURCES FROMGFEDV3 EMISSION 
;  DATA AND PLOTS IT AS CONTOUR PLOT.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) 
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (09/09/2013)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/smoke_emission/plot_contour_gfed_datasources.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_contour_gfed_datasources_v01")
   gsn_define_colormap(wks,"WhAqGrYeOrReVi200")
    
;  OPEN WRF/CHEM OUTPUT FILES
;  LIST THE NC FILES AND READ NC FILES
   wdir       = "/home/bruce/sshfs/tw/parallel/data/smoke/GFED/GFEDV3/GFED3_3HOURLY/2010/"
   wfilelist  = "gfed_list_2010"
   wname      = asciiread(wdir+wfilelist, -1, "string")
   nwname     = dimsizes(wname)
    
;  DEFINE BAD VALUE
   bv2        = -9999.
    
;  SET UP LIMITED REGION
   minlat     =-90.0  ;-15.0      
   maxlat     = 90.0  ; 35.0      
   minlon     =-180.0 ;-25.0      
   maxlon     = 180.0 ; 45.0

;  GET THE DIMENSION OF VARIABLES
   a         = addfile(wdir+wname(0) + ".nc", "r")
   variable  = a->DataSources
   ndim      = dimsizes(variable)
   nleveln   = ndim(0)
   nlatn     = ndim(1)

;  DO LOOP TO PLOT THE WRF/CHEM DATA
   do i = 0, 0;nwname-1
    print("START TIME : ")
    system("date")
;  READ WRF/CHEM DATA
    wf          = addfile(wdir + wname(i) + ".nc", "r")
    times       = wf->time
    print("NOW WORKING ON : " + times)
    wdust       = wf->DataSources
    wlat        = wf->lat
    wlon        = wf->lon
    wdust@lat1d = wlat
    wdust@lon1d = wlon

;  CALL SUBROUTINE plot_contour_gfed_datasources TO PLOT CONTOUR
    plot_contour_gfed_datasources \
    (wks, minlat, maxlat, minlon, maxlon, wdust, times)
   end do

end
