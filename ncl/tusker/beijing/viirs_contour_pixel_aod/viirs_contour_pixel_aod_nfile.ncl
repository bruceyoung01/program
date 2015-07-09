;  $ID: viirs_contour_pixel_aod_nfile.ncl V01 01/08/2013 15:05 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM viirs_contour_pixel_aod_nfile READS VIIRS PIXEL DATA (.h5 FILE), 
;  AND PLOT IT.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/08/2013)
;******************************************************************************

;  LOAD FUNCTIONS, PROCEDURES AND LIBRARIES.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/jwang7/bruceyoung01/program/ncl/ncl_lib/procedure/beijing/process_day_viirs.ncl"
load "/home/jwang7/bruceyoung01/program/ncl/ncl_lib/procedure/beijing/read_viirs_aod_1day.ncl"
load "/home/jwang7/bruceyoung01/program/ncl/ncl_lib/procedure/beijing/plot_viirs_pixel_aod.ncl"

begin
;  SETUP WORKSTATION
;  type = "x11"
   type = "pdf"
;  type = "png" 
   wks  = gsn_open_wks(type, "Beijing_pixel_aod_550_v01")
   gsn_define_colormap(wks, "WhGrYeOrReVi200")
   setvalues NhlGetWorkspaceObjectId()
    "wsMaximumSize": 100000000
   end setvalues

; INPUT
   dir        = "/shared/aerosol/bruceyoung01/data/satellite/NPP/beijing/ip/"
   gdnbolist  = "GMTCO.list"
   svdnblist  = "IVAOT.list"
   slat       = "Latitude"
   slon       = "Longitude"
   saot       = "faot550"

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -999
   bv2        = -999.
   minlat     = 39.0
   maxlat     = 41.5
   minlon     = 115.0
   maxlon     = 118.0

;  READ VIIRS DAY-NIGHT BAND RADIANCE
   filename1  = asciiread(dir + gdnbolist, -1, "string")
   filename2  = asciiread(dir + svdnblist, -1, "string")
   nfile      = dimsizes(filename1)

   logic_leap = "nonleap"

;  DECLARE VARIABLES FOR SUBROUTINE process_day_mod04
   tmpnday    = 16
   nday       = new(1, integer, bv1)
   startinx   = new(tmpnday, integer, bv1)
   endinx     = new(tmpnday, integer, bv1)
   year       = new(tmpnday, integer, bv1)
   mon        = new(tmpnday, integer, bv1)
   date       = new(tmpnday, integer, bv1)
   times      = new(tmpnday, integer, bv1)
   timee      = new(tmpnday, integer, bv1)
   dayname    = new(tmpnday, string,  bv0)
   daynum     = new(tmpnday, integer, bv1)

;  CALL process_day_viirs.ncl TO GET FILE INFO FROM FILE NAME
   process_day_viirs \
   (dir, svdnblist, logic_leap, nday, startinx, endinx, \
    year, mon, date, times, timee, dayname, daynum)

;  DECLARE VARIABLES FOR SUBROUTINE read_viirs_aod_1day.ncl
   mnp        = 768
   mnl        = 3200
   mfactor    = 5
   tmnp       = mnp*mfactor
   mlat       = new((/tmnp, mnl/), float, bv2)
   mlon       = new((/tmnp, mnl/), float, bv2)
   maod       = new((/tmnp, mnl/), float, bv2)

   do iday = 0, 0;nday-1
    system("date")
    date_display = year(iday) + "-" + mon(iday) + "-" + date(iday) + "_" + times(iday)
    print("DATE : " + date_display)

    mlat = 0.0
    mlon = 0.0
    maod = 0.0
;  CALL SUBROUTINE read_viirs_aod_1day.ncl TO READ ALL THE LATITUDE, LONGITUDE, 
;  RADIANCE QUALITY FLAG, AND RADIANCE FOR ONE DAY.
    read_viirs_aod_1day \
    (dir, bv0, iday, startinx, endinx, filename1, filename2, \
     mlat, mlon, maod)

;  CALL SUBROUTINE plot_viirs_pixel_aod.ncl TO PLOT WHITE-BLACK IMAGE.
    plot_viirs_pixel_aod \
    (wks, date_display, minlat, maxlat, minlon, maxlon, maod)
  end do
end
