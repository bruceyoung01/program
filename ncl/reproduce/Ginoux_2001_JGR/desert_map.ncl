;  ID: desert_map.ncl V01 02/25/2015 12:56 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM desert_map PLOTS GLOBAL MAP WITH OUTLINED COUNTRIES AND MARKS
;  SPECIFIC AREAS.
;
;  VARIBALES:
;  ============================================================================
;  (1 ).
;
;  NOTES:
;  ============================================================================
;  (1 ). ORIGINALLY WRITTEN BY BRUCE. (02/25/2015)
;******************************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/Users/bruceyoung01/Documents/A/program/ncl/ncl_lib/function/add_markers.ncl"

begin
;  SET UP THE PLOT PLATFORM
;  type      = "x11"
   type      = "pdf"
;  type      = "png"
   wks       = gsn_open_wks(type,"1plt_desert_map")
   gsn_define_colormap(wks,"uniform")


; Set up arrays to contain names of countries in Africa that we
; want to either outline or fill.

  cdust  = (/"Tunisia", "Libya", "Mauritania", "Mali", \
              "Water", "Land"/)
  ccolors= (/161,161,161,161,3,76/)
  rdust  = (/"Bodele", "Indus Vallye", "Taklimakan Desert", "Lake Eyre", "Salton Sea", "Altiplano", "Patagonia", "Namibia"/)
  latitude   = (/17.92, 24.31, 38.9, -28.37, 33.3, -16, -41.81, -22.57/)
  longitude   = (/19.12, 67.76, 82.2, 137.37, -115.8, -69.65, -68.9, 17.09/)
  mpres                      = True
  mpres@gsnMaximize          = True

; SET UP MAP PROJECTION AND LIMITED REGION
  mpres@mpProjection                = "CylindricalEquidistant"
  mpres@mpCenterRotF                = 0.0
  mpres@mpGridAndLimbOn             = True
  mpres@mpGridLatSpacingF           = 30.0
  mpres@mpGridLonSpacingF           = 30.0
  mpres@mpLimitMode                 = "latlon"
; mpres@mpMinLatF                   = minlat
; mpres@mpMaxLatF                   = maxlat
; mpres@mpMinLonF                   = minlon
; mpres@mpMaxLonF                   = maxlon

; COLOR OF CONTINIENTAL OUTLINES
  mpres@mpOutlineOn                 = True
  mpres@mpGeophysicalLineColor      = "Black"
  mpres@mpNationalLineColor         = "Black"
  mpres@mpUSStateLineColor          = "Black"
  mpres@mpGridLineColor             = "Black"
  mpres@mpLimbLineColor             = "Black"
  mpres@mpPerimLineColor            = "Black"
  mpres@mpGeophysicalLineThicknessF = 2.0
  mpres@mpGridLineThicknessF        = 1.5
  mpres@mpLimbLineThicknessF        = 2.0
  mpres@mpNationalLineThicknessF    = 2.0
  mpres@mpGridLineDashPattern       = 2
  mpres@mpOutlineBoundarySets       = "Geophysical"
  mpres@mpFillOn                    = True
  mpres@mpFillAreaSpecifiers        = cdust
  mpres@mpSpecifiedFillColors       = ccolors
  mpres@mpOutlineOn                 = True
  mpres@mpOutlineSpecifiers         = cdust
  mpres@tiMainString                = "Dust Source Regions"
  mpres@gsnDraw                     = False
  mpres@gsnFrame                    = False

  mpplot = gsn_csm_map(wks,mpres)

; DO # OF POINTS LOOP
  nlat     = dimsizes(latitude)
  nlon     = dimsizes(longitude)
  dum      = new(nlat, graphic)
  pmres                  = True
  pmres@gsMarkerIndex    = 12
  pmres@gsMarkerSizeF    = 0.02
  pmres@gsMarkerColor    = "Red"
  txres                  = True
  txres@txFontHeightF    = 0.015
  txres@txFontColor      = "Blue"
  if (nlat .eq. nlon) then
   do i = 0, nlat-1
    add_markers(wks, mpplot , longitude(i), latitude(i), "Red", 16, 10.0, 1.0)
    dum(i) = gsn_add_text(wks, mpplot, rdust(i), longitude(i), latitude(i), txres)
   end do
  else if (nlat .ne. nlon) then
   print("# of Latitude and Longitude do not match !!! Please double-check")
  end if
  end if
  draw(mpplot)
  frame(wks)
end
