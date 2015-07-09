; $ID: wrf_contour_h_diff.ncl V01 01/21/2012 10:10 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM: wrf_contour_h_diff IS USED TO SELECT THE SAME WRFCHEM OUTPUT AS THE 
;  CALIPSO TRACK, AND PLOT THE VERTICAL CONTOUR WITH A MAP (CALIPSO GROUND 
;  TRACK) AT THE CORNER.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) type    (string) : TYPE OF OUTPUT PLOT FORMAT                    [---]
;  (2 ) wks     (graphic): WORK STATION                                  [---]
;  (3 ) plot1   (graphic): PLOT                                          [---]
;  (4 ) plot2   (graphic): PLOT                                          [---]
;  (5 ) plot3   (graphic): PLOT                                          [---]
;  (6 ) mpplot  (graphic): MAP OVERLAID WITH CALIPSO GROUND TRACK        [---]
;  (7 ) bv1     (float)  : MISSING VALUE OF FLOAT                        [---]
;  (8 ) bv2     (integer): MISSING VALUE OF INTEGER                      [---]
;  (9 ) 
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/21/2012)
;  (2 ) ADDED MAP WITH CALIPSO GROUND TRACK OVERLAID ON IT. (04/16/2012)
;******************************************************************************

;  LOAD LIBRARIES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/universal/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/read_calipso_l2.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/select_reverse_calipso_l2.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/select_wrf_calipso.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/selected_wrf_calipso.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_wrf_contour_h.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_calipso_l2_dpr.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_merge_wrf_calipso.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_merge_wrf_diff.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/map_calipso.ncl"

begin

;  SET UP THE PLOT PLATFORM
;  type = "x11" 
   type = "pdf"
;  type = "png"
   wks  = gsn_open_wks(type, "1plt_contour_h_calipso_diff_2008-02_v01_2")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  DEFINE THREE NEW ARRAYS FOR PLOT
   plot1     = new(1, graphic)
   plot2     = new(1, graphic)
   plot3     = new(1, graphic)
   plot4     = new(1, graphic)
   plot5     = new(1, graphic)
   plot6     = new(1, graphic)
   plot7     = new(1, graphic)
   mpplot    = new(1, graphic)
;  ASSIGNMENT CONSTANT AND ABBRAVIATION
   bv1       = -9999. 
   bv2       = -9999
   nfv       = "No_FillValue"
   str       = "string"
   kmtom     = 1000.

;  READ THE CALIPSO HDF DATA
   dirh      = "/home/bruce/sshfs/pfw/data/satellite/CALIPSO/sahel/2008/CAL_LID_L2_05kmAPro-Prov-V3-01/"
   filelisth = "CAL_LID_L2_05kmAPro-Prov-V3-01_02"
   nameh     = asciiread(dirh+filelisth, -1, str)
   nfnameh   = dimsizes(nameh)

;  READ WRFCHEM OUTPUT NC FILE
;  THIS NEEDS TO HAVE A ".nc" APPENDED
   dirn      = "/home/bruce/sshfs/tw/model/wrfchem33_2/WRFV3/test/em_real/wrfout/"
   filelistn = "2008_wrfout_d01"
   namen     = asciiread(dirn+filelistn, -1, str)
   nfnamen   = dimsizes(namen)
   daten     = new((/nfnamen/), string, nfv)
   timen     = new((/nfnamen/), string, nfv)

   dirw      = "/home/bruce/sshfs/tw/model/wrfchem33_3/WRFV3/test/em_real/wrfout/"
   filelistw = "2008_wrfout_d01"
   namew     = asciiread(dirw+filelistw, -1, str)
   nfnamew   = dimsizes(namew)
   datew     = new((/nfnamew/), string, nfv)
   timew     = new((/nfnamew/), string, nfv)

;  RANGE OF STUDY AREA
   minlatn   = -15.0
   maxlatn   =  35.0
   minlonn   = -25.0
   maxlonn   =  45.0

;  DEFINE THE HEIGHT LEVELS
;  MINIMUM HEIGHT, MAXIMUM HEIGHT, INTERVAL
   minh      = 0.
   maxh      = 15.
   deltah    = 0.06 
   inth      = 251
   height    = fspan(minh, maxh, inth) 

;  DEFINE # OF MAJOR X AXIS LABELS
   npts      = 6

;  READ OUT DATE AND TIME OF WRFCHEM INTO AN ARRARY
   do i = 0, nfnamen-1
    daten(i) = str_get_cols(namen(i), 11, 20)
    timen(i) = str_get_cols(namen(i), 22, 23)
   end do
   do i = 0, nfnamew-1
    datew(i) = str_get_cols(namew(i), 11, 20)
    timew(i) = str_get_cols(namew(i), 22, 23)
   end do


;  DEFINE VARIABLES WITH THE SAME DIMENSIONS FOR 
;  PROCEDURE read_calipso_l2
   dateh     = new(1, string, nfv)
   timeh     = new(1, string, nfv)
   d_or_n    = new(1, string, nfv)
   ndimh     = new(1, integer, bv2)
   timeall   = new(1, string, nfv)

;  DEFINE VARIABLES WITH THE SAME DIMENSIONS FOR 
;  PROCEDURE select_reverse_calipso_l2
   sstart    = new(1, integer, bv2)
   send      = new(1, integer, bv2)

;  DEFINE VARIABLES WITH THE SAME DIMENSIONS FOR 
;  PROCEDURE select_wrf_calipso
   sn        = 150 ; # OF SELECTED GRIDS
   aspm25h   = new((/inth, sn/),float, bv1)
   bspm25h   = new((/inth, sn/),float, bv1)
   aspth     = new((/inth, sn/),float, bv1)
   bspth     = new((/inth, sn/),float, bv1)
   aspblh    = new(sn,float, bv1)
   bspblh    = new(sn,float, bv1)
   slatn     = new(sn,float, bv1)
   aslonn1   = new(sn,float, bv1)
   bslonn1   = new(sn,float, bv1)
   in        = new(1, integer, bv2)

;  DO CALIPSO NAMES LOOP
   do i = 0, nfnameh-1
    print("# OF FILES : " + i)
;  READ THIS CALIPSO FIRST TO GET THE DIMENSION SIZE
;  IN ORDER TO DEFINE NEW ARRAY FOR THIS CALIPSO DATA
    fh       = addfile(dirh+nameh(i), "r")
    ech      = fh->Particulate_Depolarization_Ratio_Profile_532
    dimech   = dimsizes(ech)
    npixel   = dimech(0)
    nlevelh  = dimech(1)

;  DEFINE VARIABLES WITH VARIOUS DIMENSIONS FOR 
;  PROCEDURE read_calipso_l2
    lathh    = new(npixel, float, bv1)
    lonhh    = new(npixel, float, bv1)
    ech      = new((/npixel, nlevelh/), float, bv1)
    clfh1    = new((/npixel, nlevelh/), float, bv1)
    aodh     = new(npixel, float, bv1)
    sfch1    = new(npixel, float, bv1)
    indexh   = new(npixel, integer, bv2)
;  CALL PROCEDURE read_calipso_l2.ncl TO READ CALIPSO LEVEL 2 DATA
    read_calipso_l2(dirh, nameh(i), bv1,                 \; INPUT
                    minlatn, maxlatn, minlonn, maxlonn,  \; INPUT
                    dateh, timeh, lathh, lonhh, ech,     \; OUTPUT
                    clfh1, aodh, sfch1, d_or_n,          \; OUTPUT
                    indexh, ndimh, timeall)               ; OUTPUT
;  IF ndimh LOOP BEGIN
    if (ndimh .gt. 1) then
;  CALL PROCEDURE map_calipso.ncl TO PLOT MAP WITH CALIPSO 
;  GROUND TRACK OVERLAID ON IT
     map_calipso(wks, dirh, nameh(i), minlatn, maxlatn, \; INPUT
                 minlonn, maxlonn, mpplot)

;  DEFINE VARIABLES WITH VARIOUS DIMENSIONS FOR 
;  PROCEDURE select_reverse_calipso_l2
     rsech   = new((/inth, ndimh/), float, bv1)
     rsclfh  = new((/inth, ndimh/), float, bv1)
     rssfch  = new((/ndimh/), float, bv1)

;  CALL PROCEDURE select_reverse_calipso_l2.ncl TO SELECT AND 
;  REVERSE CALIPSO LEVEL 2 DATA
     select_reverse_calipso_l2(indexh, ndimh, inth, lathh, \; INPUT
                               lonhh, nlevelh, ech, clfh1, \; INPUT
                               aodh, sfch1, d_or_n, bv1,   \; INPUT
                               sstart, send, rsech,        \; OUTPUT
                               rsclfh, rssfch)              ; OUTPUT

;  CALL PROCEDURE select_wrf_calipso.ncl TO SELECT WRFCHEM 
;  DATA BASED ON CALIPSO GROUND TRACK FOR ONE WRF-CHEM OUTPUT
     select_wrf_calipso(dirn, namen, dateh, timeh, daten,  \; INPUT
                        timen, height, bv1, kmtom, inth,   \; INPUT
                        height, sstart, send, lathh, lonhh,\; INPUT
                        aspm25h, aspth, aspblh, slatn,     \; OUTPUT
                        aslonn1, in)                        ; OUTPUT

;  CALL PROCEDURE select_wrf_calipso.ncl TO SELECT WRFCHEM 
;  DATA BASED ON CALIPSO GROUND TRACK FOR ONE WRF-CHEM OUTPUT
     select_wrf_calipso(dirw, namew, dateh, timeh, datew,  \; INPUT
                        timew, height, bv1, kmtom, inth,   \; INPUT
                        height, sstart, send, lathh, lonhh,\; INPUT
                        bspm25h, bspth, bspblh, slatn,     \; OUTPUT
                        bslonn1, in)                        ; OUTPUT

;  DEFINE VARIABLES WITH VARIOUS DIMENSIONS FOR 
;  PROCEDURE selected_wrf_calipso
   asspm25h   = new((/inth, in-1/),float, bv1)
   bsspm25h   = new((/inth, in-1/),float, bv1)
   asspth     = new((/inth, in-1/),float, bv1)
   bsspth     = new((/inth, in-1/),float, bv1)
   asspblh    = new((/in-1/),float, bv1)
   bsspblh    = new((/in-1/),float, bv1)

;  CALL PROCEDURE selected_wrf_calipso.ncl TO SELECT SELECTED 
;  WRFCHEM DATA BASED ON CALIPSO GROUND TRACK
     selected_wrf_calipso(in, aspm25h, aspth, aspblh,      \; INPUT
                          asspm25h, asspth, asspblh)       \; OUTPUT

;  CALL PROCEDURE selected_wrf_calipso.ncl TO SELECT SELECTED 
;  WRFCHEM DATA BASED ON CALIPSO GROUND TRACK
     selected_wrf_calipso(in, bspm25h, bspth, bspblh,      \; INPUT
                          bsspm25h, bsspth, bsspblh)       \; OUTPUT

;  CALL PROCEDURE plot_calipso_l2_dpr.ncl TO PLOT CALIPSO L2 DATA
     plot_calipso_l2_dpr \
                    (wks, height, maxh, minh, in, npts,    \; INPUT
                     slatn, aslonn1, timeall, dateh, timeh,\; INPUT
                     ndimh, rsech, rsclfh, rssfch,         \; INPUT
                     plot1)                                \; OUTPUT  

;  IF IN IS NOT EQUAL TO 0
     if (in .gt. 0) then

;  CALL PROCEDURE plot_wrf_contour_h.ncl TO PLOT WRFCHEM 
;  VERTICAL CONTOUR
     plot_wrf_contour_h(wks, height, maxh, minh, in, npts, \; INPUT
                        slatn, aslonn1, dateh, timeh,      \; INPUT
                        asspm25h, asspth,                  \; INPUT
                        plot2, plot3)                       ; OUTPUT

;  CALL PROCEDURE plot_wrf_contour_h.ncl TO PLOT WRFCHEM 
;  VERTICAL CONTOUR
     plot_wrf_contour_h(wks, height, maxh, minh, in, npts, \; INPUT
                        slatn, bslonn1, dateh, timeh,      \; INPUT
                        bsspm25h, bsspth,                  \; INPUT
                        plot4, plot5)                       ; OUTPUT

;  CALCULATE THE DIFFERENCE BETWEEN WRF-CHEM OUTPUT1 AND OUTPUT2
     sspm25h_diff = bsspm25h - asspm25h
     sspth_diff   = bsspth   - asspth
     sspblh_diff  = bsspblh  - asspblh

;  CALL PROCEDURE plot_wrf_contour_h.ncl TO PLOT WRFCHEM 
;  VERTICAL CONTOUR
     plot_wrf_contour_h(wks, height, maxh, minh, in, npts, \; INPUT
                        slatn, bslonn1, dateh, timeh,      \; INPUT
                        sspm25h_diff, sspth_diff,          \; INPUT
                        plot6, plot7)                       ; OUTPUT

;  CALL PROCEDURE plot_merge_wrf_calipso TO MERGE ALL PLOTS 
;  INTO ONE PLOT
;    plot_merge_wrf_calipso(wks, plot2, plot3, plot1, mpplot)

;    plot_merge_wrf_calipso(wks, plot4, plot5, plot1, mpplot)

;    plot_merge_wrf_calipso(wks, plot6, plot7, plot1, mpplot)

     plot_merge_wrf_diff(wks, plot2, plot4, plot6, mpplot)

     end if ; END OF in IF STATEMENT

;  DELETE VARIOUS DEFINED VARIABLES
     delete([/rsech, rsclfh, rssfch,                         \ ; FOR select_reverse_calipso_l2
              asspm25h, asspth, asspblh,                     \ ; FOR selected_wrf_calipso
              bsspm25h, bsspth, bsspblh,                     \ ; FOR selected_wrf_calipso
              sspm25h_diff, sspth_diff, sspblh_diff/])         ; FOR selected_wrf_calipso
    end if ; END OF ndimh IF STATEMENT
    delete([/lathh, lonhh, ech, clfh1, aodh, sfch1, indexh/])
   end do ; END OF I LOOP
end
