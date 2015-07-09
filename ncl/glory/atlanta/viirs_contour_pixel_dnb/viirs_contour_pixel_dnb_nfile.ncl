;  $ID: viirs_contour_pixel_dnb_nfile.ncl V01 01/08/2013 15:05 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM viirs_contour_pixel_dnb_nfile READS VIIRS PIXEL DATA (.h5 FILE), 
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
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/process_day_svdnb.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/atlanta/read_viirs_rad_1day.ncl"

begin
;  SETUP WORKSTATION
;  type = "x11"
   type = "pdf"
;  type = "png" 
   wks  = gsn_open_wks(type, "Atlanta_pixel_dnb_700nm_v01")
   gsn_define_colormap(wks, "gsdtol")
   setvalues NhlGetWorkspaceObjectId()
    "wsMaximumSize": 100000000
   end setvalues

; INPUT
   dir        = "/home/bruce/sshfs/shw/data/satellite/NPP/atlanta/svdnb/"
   gdnbolist  = "GDNBO_list"
   svdnblist  = "SVDNB_list"
   slat       = "Latitude"
   slon       = "Longitude"
   saot       = "Radiance"
   nfile      = 2
   nfactor    = 10000000

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -999
   bv2        = -999.
   minlat     = 33.0
   maxlat     = 34.5
   minlon     = -85.5
   maxlon     = -83.5

;  READ VIIRS DAY-NIGHT BAND RADIANCE
   filename1  = asciiread(dir + gdnbolist, -1, "string")
   filename2  = asciiread(dir + svdnblist, -1, "string")
   nfile      = dimsizes(filename1)

   logic_leap = "leap"

;  DECLARE VARIABLES FOR SUBROUTINE process_day_mod04
   tmpnday    = 35
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

;  CALL process_day_svdnb.ncl TO GET FILE INFO FROM FILE NAME
   process_day_svdnb \
   (dir, svdnblist, logic_leap, nday, startinx, endinx, \
    year, mon, date, times, timee, dayname, daynum)

;  DECLARE VARIABLES FOR SUBROUTINE read_modis_aod_1day.ncl
   mnp        = 768
   mnl        = 4064
   mfactor    = 5
   tmnp       = mnp*mfactor
   mlat       = new((/nday, tmnp, mnl/), float, bv2)
   mlon       = new((/nday, tmnp, mnl/), float, bv2)
   maod       = new((/nday, tmnp, mnl/), float, bv2)
   maod_qf    = new((/nday, tmnp, mnl/), integer, bv1)

   do i = 0, nday
     system("date")
     date_display = year(iday) + "-" + mon(iday) + "-" + date(iday) + "_" + times(iday)
     print("DATE : " + date_display)

;  CALL SUBROUTINE read_viirs_rad_1day.ncl TO READ ALL THE LATITUDE, LONGITUDE, 
;  RADIANCE QUALITY FLAG, AND RADIANCE FOR ONE DAY.
     read_viirs_rad_1day \
     (dir, bv0, iday, startinx, endinx, filename1, filename2, \
      mlat(iday, :, :), mlon(iday, :, :),                     \
      maod_qf(iday, :, :), maod(iday, :, :))

;***************************************************************
; Simple data exploration:   Distribution statistics
;***************************************************************

   opt           = True
   opt@PrintStat = True
   statb         = stat_dispersion(maod, opt)
   res                      = True
   res@gsnAddCyclic         = False

;---This resource not needed in V6.1.0
   res@gsnSpreadColors      = True
   res@gsnMaximize          = True
   res@gsnPaperOrientation  = "portrait"
     
   res@cnFillOn             = True
   res@cnLinesOn            = False
   res@cnLineLabelsOn       = False
  ;res@cnFillMode           = "CellFill"
   res@cnFillMode           = "RasterFill"
  
   res@cnLevelSelectionMode = "ManualLevels"
   res@cnMinLevelValF       = 0.0
   res@cnMaxLevelValF       = 1.0
   res@cnLevelSpacingF      = 0.1

   res@lbOrientation        = "vertical"
   res@lbLabelFontHeightF   = 0.012
   res@pmLabelBarWidthF     = 0.1

   res@mpProjection         = "CylindricalEquidistant"
   res@mpCenterRotF         = 0.0
   res@mpGridAndLimbOn      = True
   res@mpLimitMode          = "latlon"
   res@mpMinLatF            =  33.0
   res@mpMaxLatF            =  34.5
   res@mpMinLonF            = -85.5
   res@mpMaxLonF            = -83.5
   res@mpGridLatSpacingF    = 0.2
   res@mpGridLonSpacingF    = 0.2
;  COLOR OF CONTINIENTAL OUTLINES
   res@mpOutlineOn                  = True
   res@mpGeophysicalLineColor       = "Black"
   res@mpNationalLineColor          = "Black"
   res@mpUSStateLineColor           = "Black"
   res@mpGridLineColor              = "Black"
   res@mpLimbLineColor              = "Black"
   res@mpPerimLineColor             = "Black"
   res@mpGeophysicalLineThicknessF  = 3.0
   res@mpGridLineThicknessF         = 1.5
   res@mpLimbLineThicknessF         = 2.0
   res@mpNationalLineThicknessF     = 3.0
   res@mpUSStateLineThicknessF      = 3.0
   res@mpGridLineDashPattern        = 2
   res@mpOutlineBoundarySets        = "GeophysicalAndUSStates"
   res@mpFillOn                     = False
   res@mpOutlineOn                  = True
   res@mpOutlineBoundarySets        = "AllBoundaries"
   res@mpDataSetName                = "Earth..4"
   res@mpDataBaseVersion            = "MediumRes"
   res@pmTickMarkDisplayMode        = "always"
   res@mpFillDrawOrder              = "PreDraw"
   res@gsnLeftString                = "VIIRS AOT (488 nm)"
   plot = gsn_csm_contour_map_ce(wks, maod, res)
  end do
end
