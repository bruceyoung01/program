;  $ID: calipso_contour_vfm.ncl V01 09/25/2012 11:40 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM calipso_contour_vfm READS CALIPSO LIDAR LEVEL 2 VERTICAL 
;  FEATURE MASK PRODUCT, WHOSE FORMAT IS LIKE AS FOLLOWING:
;  CAL_LID_L2_VFM-ValStage1-V3-01.2008-02-01T13-07-42ZD.hdf
;  SELECTS WRFCHEM GRIDS DEPENDING ON CALIPSO GROUND TRACK INFO, 
;  AND PLOTS THE VFM THE SAME AS CALIPSO WEBSITE IMAGES AND WRFCHEM DUST AND 
;  SMOKE VERTICAL CROSS SECTION WITH 2-D COLOR BAR.
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
;  (3 ) MODIFIED FROM wrf_contour_h_ec.ncl. (04/22/2013)
;  (4 ) MODIFIED FROM calipso_contour_h_vfm.ncl. (04/25/2013)
;******************************************************************************

;  LOAD LIBRARIES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/universal/WRFUserARW.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/sahel/read_calipso_l2_vfm_sfc.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/sahel/select_reverse_calipso_l2_vfm_sfc.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/sahel/select_wrf_calipso_dust_smoke_height.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/sahel/selected_wrf_calipso_vfm.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/sahel/convert_1d_to_2d.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/sahel/plot_wrf_polymarker_vector_ph_vfm.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/sahel/plot_calipso_l2_vfm_sfc.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/sahel/plot_wrf_contour_h_vfm.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/sahel/plot_merge_wrf_calipso_vfm.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/sahel/map_calipso.ncl"

begin

;  SET UP THE PLOT PLATFORM
;  type = "x11" 
   type = "pdf"
   wks  = gsn_open_wks(type, "1plt_calipso_contour_h_vfm_sfc_v05_1b")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  DEFINE THREE NEW ARRAYS FOR PLOT
   plot1     = new(1, graphic)
   plot2     = new(1, graphic)
   plot3     = new(1, graphic)
   mpplot    = new(1, graphic)
;  ASSIGNMENT CONSTANT AND ABBRAVIATION
   bv0       = " "
   bv1       = -9999
   bv2       = -9999.
   nfv       = "No_FillValue"
   str       = "string"
   kmtom     = 1000.

;  READ THE CALIPSO HDF DATA
   dirh1     = "/shared/aerosol/bruceyoung01/data/satellite/CALIPSO/sahel/2008/CAL_LID_L2_05kmAPro-Prov-V3-01/"
   filelisth1= "CAL_LID_L2_05kmAPro-Prov-V3-01_match1"
   nameh1    = asciiread(dirh1+filelisth1, -1, str)
   nfnameh1  = dimsizes(nameh1)
   dirh      = "/shared/aerosol/bruceyoung01/data/satellite/CALIPSO/sahel/2008/CAL_LID_L2_VFM-ValStage1-V3-01/"
   filelisth = "CAL_LID_L2_VFM-ValStage1-V3-01_match1"
   nameh     = asciiread(dirh+filelisth, -1, str)
   nfnameh   = dimsizes(nameh)

;  READ WRFCHEM OUTPUT NC FILE FOR DUST+SMOKE AND SMOKE
;  THIS NEEDS TO HAVE A ".nc" APPENDED
   dirn1     = "/shared/aerosol/bruceyoung01/data/wrf_output/wrfout_sahel_85_smoke_dust_650/wrfout/"
   dirn2     = "/shared/aerosol/bruceyoung01/data/wrf_output/wrfout_sahel_85_smoke_650/wrfout/"
   filelistn = "2008_wrfout_d01"
   namen     = asciiread(dirn1 + filelistn, -1, str)
   nfnamen   = dimsizes(namen)
   daten     = new((/nfnamen/), string, nfv)
   timen     = new((/nfnamen/), string, nfv)

;  RANGE OF STUDY AREA
   minlatn   = -15.0
   maxlatn   =  35.0
   minlonn   = -25.0
   maxlonn   =  45.0

;  DEFINE THE HEIGHT LEVELS
   base0     = 30.1
   base1     = 20.2
   base2     =  8.2
   base3     =  0.0
;  MINIMUM HEIGHT, MAXIMUM HEIGHT, INTERVAL
   minh      = 0.
   maxh      = 18.
   deltah1   = 0.18 
   inth1     = 101
   height1   = fspan(minh, maxh, inth1) 
   deltah2   = 0.06 
   inth2     = 301
   height2   = fspan(minh, maxh, inth2) 
   deltah3   = 0.03 
   inth3     = 601
   height3   = fspan(minh, maxh, inth3)

;  DEFINE THE PRESSURE LEVELS
;  MINIMUM PRESSURE, MAXIMUM PRESSURE, INTERVAL
   minpres   = 100.
   maxpres   = 1000.
   intpres   = 181
   pressure  = fspan(maxpres, minpres, intpres)
   pressure@units = "hPa"

;  DEFINE # OF MAJOR X AXIS LABELS
   npts      = 6

;  READ OUT DATE AND TIME OF WRFCHEM INTO AN ARRARY
   do i = 0, nfnamen-1
    daten(i) = str_get_cols(namen(i), 11, 20)
    timen(i) = str_get_cols(namen(i), 22, 23)
   end do

;  DEFINE VARIABLES WITH THE SAME DIMENSIONS FOR 
;  PROCEDURE read_calipso_l2_vfm.ncl
   dateh     = new(1, string, nfv)
   timeh     = new(1, string, nfv)
   d_or_n    = new(1, string, nfv)
   timeall   = new(1, string, nfv)

;  DEFINE VARIABLES WITH THE SAME DIMENSIONS FOR 
;  PROCEDURE select_reverse_calipso_l2.ncl
   sstart1   = new(1, integer, bv1)
   send1     = new(1, integer, bv1)
   sstart2   = new(1, integer, bv1)
   send2     = new(1, integer, bv1)
   sstart3   = new(1, integer, bv1)
   send3     = new(1, integer, bv1)

;  DEFINE VARIABLES WITH THE SAME DIMENSIONS FOR 
;  PROCEDURE select_wrf_calipso_dust_smoke.ncl
   sn        = 150 ; # OF SELECTED GRIDS
   adusth    = new((/inth3, sn/), float, bv2)
   aspm25h   = new((/inth3, sn/), float, bv2)
   aspth     = new((/inth3, sn/), float, bv2)
   asuh      = new((/inth3, sn/), float, bv2)
   asvh      = new((/inth3, sn/), float, bv2)
   aspblh    = new(sn, float,   bv2)
   slatn     = new(sn, float,   bv2)
   aslonn    = new(sn, float,   bv2)
   in        = new(1,  integer, bv1)

;  DO CALIPSO NAMES LOOP
   do i = 25, 49;nfnameh-1
    ii = i + 1
    print("# OF FILES : " + ii)
;  READ THIS CALIPSO FIRST TO GET THE DIMENSION SIZE
;  IN ORDER TO DEFINE NEW ARRAY FOR THIS CALIPSO DATA
    fh       = addfile(dirh+nameh(i), "r")
    vfmh     = fh->Feature_Classification_Flags
    dimech   = dimsizes(vfmh)
    npixel   = dimech(0)

;  DEFINE VARIABLES WITH VARIOUS DIMENSIONS FOR PROCEDURE read_calipso_l2_vfm.ncl
;  SET UP A SWITCH FOR QUICK PROCESS(qp), WHICH JUST SELECTS ONE PROFILE IN EACH BLOCK
;  AND NORMAL PROCESS(np), WHICH SELECTS ALL THE PROFILES IN EACH BLOCK
    qp        = True
;  block1
    block1    = 1
    nblock1   = 55
    nprofile1 = 3
;  block2
    block2    = 2
    nblock2   = 200
    nprofile2 = 5
;  block3
    block3    = 3
    nblock3   = 290
    nprofile3 = 15
    if (qp) then
     nprofile1 = 1
     nprofile2 = 1
     nprofile3 = 1
    end if
    npixel1   = npixel*nprofile1
    npixel2   = npixel*nprofile2
    npixel3   = npixel*nprofile3
    lath1     = new((/npixel1/), float,   bv2)
    lonh1     = new((/npixel1/), float,   bv2)
    sfch1     = new((/npixel1/), float,   bv2)
    vfmh1     = new((/npixel1, nblock1/), float, bv2)
    indexh1   = new((/npixel1/), integer, bv1)
    ndimh1    = new((/1/),   integer, bv1)
    lath2     = new((/npixel2/), float,   bv2)
    lonh2     = new((/npixel2/), float,   bv2)
    sfch2     = new((/npixel2/), float,   bv2)
    vfmh2     = new((/npixel2, nblock2/), float, bv2)
    indexh2   = new((/npixel2/), integer, bv1)
    ndimh2    = new((/1/),   integer, bv1)
    lath3     = new((/npixel3/), float,   bv2)
    lonh3     = new((/npixel3/), float,   bv2)
    sfch3     = new((/npixel3/), float,   bv2)
    vfmh3     = new((/npixel3, nblock3/), float, bv2)
    indexh3   = new((/npixel3/), integer, bv1)
    ndimh3    = new((/1/),   integer, bv1)


;  CALL PROCEDURE read_calipso_l2_vfm_sfc.ncl TO READ CALIPSO LEVEL 2 VFM DATA
    read_calipso_l2_vfm_sfc \
   (dirh1, nameh1(i), dirh, nameh(i), bv0, bv1, bv2,              \; INPUT
    minlatn, maxlatn, minlonn, maxlonn,                           \; INPUT
    nprofile1, npixel1, nblock1, nprofile2, npixel2, nblock2,     \; INPUT
    nprofile3, npixel3, nblock3,                                  \; INPUT
    dateh, timeh, d_or_n, timeall,                                \; OUTPUT
    lath1, lonh1, sfch1, vfmh1, indexh1, ndimh1,                  \; OUTPUT
    lath2, lonh2, sfch2, vfmh2, indexh2, ndimh2,                  \; OUTPUT
    lath3, lonh3, sfch3, vfmh3, indexh3, ndimh3)                   ; OUTPUT

    print("Selected Pixels for Block #1, #2, #3 = " \
           + ndimh1 + ", " + ndimh2 + ", " + ndimh3)
;  IF ndimh1 LOOP BEGIN
    if (ndimh1 .gt. 1 .and. \
        ndimh2 .gt. 1 .and. \
        ndimh3 .gt. 1) then
;  CALL PROCEDURE map_calipso.ncl TO PLOT MAP WITH CALIPSO 
;  GROUND TRACK OVERLAID ON IT
     map_calipso \
    (wks, dirh, nameh(i), minlatn, maxlatn, \; INPUT
     minlonn, maxlonn, mpplot)

;  DEFINE VARIABLES WITH VARIOUS DIMENSIONS FOR PROCEDURE select_reverse_calipso_l2_vfm.ncl
     rssfch1 = new((/ndimh1/), float, bv2)
     rsvfmh1 = new((/inth1, ndimh1/), float, bv2)
     rssfch2 = new((/ndimh2/), float, bv2)
     rsvfmh2 = new((/inth2, ndimh2/), float, bv2)
     rssfch3 = new((/ndimh3/), float, bv2)
     rsvfmh3 = new((/inth3, ndimh3/), float, bv2)

;  CALL PROCEDURE select_reverse_calipso_l2_vfm_sfc.ncl TO SELECT AND 
;  REVERSE CALIPSO LEVEL 2 DATA
     if (maxh .gt. base1) then
      select_reverse_calipso_l2_vfm_sfc \
     (block1, nblock1, base1, base0, maxh, deltah1, indexh1, \; INPUT
      ndimh1, inth1, lath1, lonh1, sfch1, vfmh1, d_or_n, bv2,\; INPUT
      sstart1, send1, rssfch1, rsvfmh1)                       ; OUTPUT
     else
      print("The selected Height1 is below block #1")
     end if
     if (maxh .gt. base2) then
      select_reverse_calipso_l2_vfm_sfc \
     (block2, nblock2, base2, base1, maxh, deltah2, indexh2, \; INPUT
      ndimh2, inth2, lath2, lonh2, sfch2, vfmh2, d_or_n, bv2,\; INPUT
      sstart2, send2, rssfch2, rsvfmh2)                       ; OUTPUT
     else
      print("The selected Height2 is below block #2")
     end if
     select_reverse_calipso_l2_vfm_sfc \
    (block3, nblock3, base3, base2, maxh, deltah3, indexh3, \; INPUT
     ndimh3, inth3, lath3, lonh3, sfch3, vfmh3, d_or_n, bv2,\; INPUT
     sstart3, send3, rssfch3, rsvfmh3)                       ; OUTPUT

;  CALL PROCEDURE select_wrf_calipso_dust_smoke_height.ncl TO SELECT WRFCHEM 
;  DATA BASED ON CALIPSO GROUND TRACK
     select_wrf_calipso_dust_smoke_height \
    (dirn1, dirn2, namen, dateh, timeh, daten,\; INPUT
     timen, height3, bv2, kmtom, inth3, sn,   \; INPUT
     sstart3, send3, lath3, lonh3,            \; INPUT
     adusth, aspm25h, aspth, aspblh, asuh,    \; OUTPUT
     asvh, slatn, aslonn, in)                  ; OUTPUT

;  IF IN IS NOT EQUAL TO 0
     if (in .gt. 0) then
;  DEFINE ARRAY FOR SUBROUTINE convert_1d_to_2d.ncl
      latlon    = new((/inth3, in-1/),float, bv2)
      hgt       = new((/inth3, in-1/),float, bv2)

;  CALL SUBROUTINE convert_1d_to_2d.ncl TO GET 2-D LATLON AND HEIGHT
      convert_1d_to_2d \
     (inth3, in, height3, latlon, hgt)

;  DEFINE VARIABLES WITH VARIOUS DIMENSIONS FOR 
;  PROCEDURE selected_wrf_calipso
      sspm25h   = new((/inth3, in-1/),float, bv2)
      sdusth    = new((/inth3, in-1/),float, bv2)
      sspblh    = new((/in-1/),float, bv2)
      svh       = new((/inth3, in-1/),float, bv2)
      swh       = new((/inth3, in-1/),float, bv2)

;  CALL PROCEDURE selected_wrf_calipso_vfm.ncl TO SELECT SELECTED 
;  WRFCHEM DATA BASED ON CALIPSO GROUND TRACK
      selected_wrf_calipso_vfm \
     (in, aspm25h, adusth, aspblh, asuh, asvh, \; INPUT
      sspm25h, sdusth, sspblh, svh, swh)        ; OUTPUT
      rsvfmh3 = rsvfmh3-1
;  CALL PROCEDURE plot_calipso_l2_vfm_sfc.ncl TO PLOT CALIPSO L2 DATA
      plot_calipso_l2_vfm_sfc \
     (wks, height3, maxh, minh, in, npts,     \; INPUT
      slatn, aslonn, timeall, dateh, timeh,   \; INPUT
      ndimh3, rssfch3, rsvfmh3,               \; INPUT
      plot1)                                   ; OUTPUT  

;  CALL PROCEDURE plot_wrf_contour_h_vfm.ncl TO PLOT WRFCHEM 
;  VERTICAL CONTOUR
      plot_wrf_contour_h_vfm \
     (wks, height3, maxh, minh, in, npts,       \; INPUT
      slatn, aslonn, latlon, hgt, dateh, timeh, \; INPUT
      sdusth, sspm25h,                          \; INPUT
      plot2)                                     ; OUTPUT

;  CALL PROCEDURE plot_wrf_polymarker_vector_ph_vfm.ncl TO PLOT WRFCHEM 
;  VERTICAL RASTER
;    plot_wrf_polymarker_vector_ph_vfm \
;   (wks, ndim1, npts, slatn, aslonn, pressure, dateh, \; INPUT
;    timeh, svh, swh, adusth, aspm25h,                 \; INPUT
;    plot2)                                             ; OUTPUT

;  CALL PROCEDURE plot_merge_wrf_calipso_vfm.ncl TO MERGE ALL PLOTS 
;  INTO ONE PLOT
;    plot_merge_wrf_calipso_vfm \
;   (wks, plot2, plot1, mpplot)

      delete([/latlon, hgt, sspm25h, sdusth, sspblh, svh, \ ; FOR selected_wrf_calipso_vfm
               swh/])
     end if ; END OF in IF STATEMENT

;  DELETE VARIOUS DEFINED VARIABLES
     delete([/vfmh, sfch1, sfch2, sfch3,                             \ ; DIMENSION VARIOUS ARRAY
              lath1, lonh1, lath2, lonh2, lath3, lonh3,              \ ; FOR read_calipso_l2_vfm
              vfmh1, vfmh2, vfmh3, indexh1, indexh2, indexh3,        \ ; FOR read_calipso_l2_vfm
              rssfch1, rssfch2, rssfch3, rsvfmh1, rsvfmh2, rsvfmh3/])  ; FOR select_reverse_calipso_l2_vfm
    end if ; END OF ndimh IF STATEMENT
   end do ; END OF I LOOP
end
