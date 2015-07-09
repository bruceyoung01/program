; $ID: calipso_contour_ec.ncl V01 01/21/2012 10:10 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM calipso_contour_ec READS CALIPSO L2 EXTINCTION COEFFICIENT DATA 
;  AND WRFCHEM PM2.5 DATA, SELECTS WRFCHEM GRIDS DEPENDING ON CALIPSO GROUND 
;  TRACK INFO, AND PLOTS VERTICAL CROSS SECTION FOR CALIPSO
;  OVERLAID WITH GROUND TRACK ON A MAP.
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
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/gsn_csm_epa.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/WRFUserARW.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/read_calipso_l2_ec1064.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_reverse_calipso_l2.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_calipso_l2.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/map_calipso.ncl"

begin

;  SET UP THE PLOT PLATFORM
;  type = "x11" 
;  type = "pdf"
   type = "png"
   wks  = gsn_open_wks(type, "1plt_calipso_contour_ec_v01_200709")
   gsn_define_colormap(wks,"WhBlGrYeOrReVi202")

;  DEFINE THREE NEW ARRAYS FOR PLOT
   plot1     = new(1, graphic)
   plot2     = new(1, graphic)
   plot3     = new(1, graphic)
   mpplot    = new(1, graphic)
;  ASSIGNMENT CONSTANT AND ABBRAVIATION
   bv1       = -9999. 
   bv2       = -9999
   nfv       = "No_FillValue"
   str       = "string"
   kmtom     = 1000.

;  READ THE CALIPSO HDF DATA
   dirh      = "/home/vy57456/zzbatmos_common/Data/CALIPSO/CAL_LID_L2_05kmAPro/2007/"
   filelisth = "filelist_CAL_LID_L2_05kmAPro-Prov-V3-01_200709"
   nameh     = asciiread(dirh+filelisth, -1, str)
   nfnameh   = dimsizes(nameh)

;  RANGE OF STUDY AREA
   minlatn   = -30.0
   maxlatn   =  10.0
   minlonn   = -20.0
   maxlonn   =  20.0

;  DEFINE THE HEIGHT LEVELS
;  MINIMUM HEIGHT, MAXIMUM HEIGHT, INTERVAL
   minh      = 0.
   maxh      = 15.
   deltah    = 0.06 
   inth      = 251
   height    = fspan(minh, maxh, inth) 

;  DEFINE # OF MAJOR X AXIS LABELS
   npts      = 6

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

;  DO CALIPSO NAMES LOOP
   do i = 0, nfnameh-1
    ifile = i + 1
;  READ THIS CALIPSO FIRST TO GET THE DIMENSION SIZE
;  IN ORDER TO DEFINE NEW ARRAY FOR THIS CALIPSO DATA
    fh       = addfile(dirh+nameh(i), "r")
    ech      = fh->Extinction_Coefficient_1064
    dimech   = dimsizes(ech)
    npixel   = dimech(0)
    nlevelh  = dimech(1)
    in       = npixel

;  DEFINE VARIABLES WITH VARIOUS DIMENSIONS FOR 
;  PROCEDURE read_calipso_l2
    lathh    = new(npixel, float, bv1)
    lonhh    = new(npixel, float, bv1)
    ech      = new((/npixel, nlevelh/), float, bv1)
    clfh1    = new((/npixel, nlevelh/), float, bv1)
    aodh     = new(npixel, float, bv1)
    sfch1    = new(npixel, float, bv1)
    indexh   = new(npixel, integer, bv2)
;  CALL PROCEDURE read_calipso_l2_ec1064.ncl TO READ CALIPSO LEVEL 2 DATA
    read_calipso_l2_ec1064\
    (dirh, nameh(i), bv1,                 \; INPUT
     minlatn, maxlatn, minlonn, maxlonn,  \; INPUT
     dateh, timeh, lathh, lonhh, ech,     \; OUTPUT
     clfh1, aodh, sfch1, d_or_n,          \; OUTPUT
     indexh, ndimh, timeall)               ; OUTPUT

;  IF ndimh LOOP BEGIN
    if (.not.ismissing(ndimh)       .and. \
        .not.all(ismissing(indexh)) .and. \
        ndimh .gt. 1) then

;  DEFINE VARIABLES WITH VARIOUS DIMENSIONS FOR 
;  PROCEDURE select_reverse_calipso_l2
     rsech   = new((/inth, ndimh/), float, bv1)
     rsclfh  = new((/inth, ndimh/), float, bv1)
     rssfch  = new((/ndimh/), float, bv1)

     print("Now Processing : " + nameh(i))
;  CALL PROCEDURE select_reverse_calipso_l2.ncl TO SELECT AND 
;  REVERSE CALIPSO LEVEL 2 DATA
     select_reverse_calipso_l2 \
    (indexh, ndimh, inth, lathh, \; INPUT
     lonhh, nlevelh, ech, clfh1, \; INPUT
     aodh, sfch1, d_or_n, bv1,   \; INPUT
     sstart, send, rsech,        \; OUTPUT
     rsclfh, rssfch)              ; OUTPUT

;  CALL PROCEDURE plot_calipso_l2.ncl TO PLOT CALIPSO L2 DATA
     plot_calipso_l2 \
    (wks, height, maxh, minh, ndimh, npts,    \; INPUT
     lathh(0:ndimh-1), lonhh(0:ndimh-1), timeall, dateh, timeh,  \; INPUT
     ndimh, rsech, rsclfh, rssfch,         \; INPUT
     plot1)                                \; OUTPUT  

;  CALL PROCEDURE map_calipso.ncl TO PLOT MAP WITH CALIPSO 
;  GROUND TRACK OVERLAID ON IT
     map_calipso(wks, dirh, nameh(i), minlatn, maxlatn, \; INPUT
                 minlonn, maxlonn, mpplot)
;  DELETE VARIOUS DEFINED VARIABLES
     delete([/rsech, rsclfh, rssfch/])
    end if ; END OF ndimh IF STATEMENT
    delete([/lathh, lonhh, ech, clfh1, aodh, sfch1, indexh/]) ; FOR read_calipso_l2
   end do ; END OF I LOOP
end
