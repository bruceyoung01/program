; $ID: region_map.ncl V01 03/16/2014 13:52 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM region_map PLOTS SITES ON THE MAP.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES: 
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (03/16/2014)
;******************************************************************************

;  LOAD LIBRARIES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/Users/bruce/Documents/A/program/ncl/glory/ncl_lib/function/add_markers.ncl"

begin

; SET UP THE PLOT PLATFORM
; type = "x11"
  type = "pdf"
  wks  = gsn_open_wks(type, "1plt_region_map_v02")
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  NUMBER OF AERONET SITES
   nsites   = 2
;  READ AERONET SITES INFO
   sitename = new(nsites, string)
   longitude= new(nsites, float)
   latitude = new(nsites, float)
   elevation= new(nsites, float)
   sitename = (/"Phoenix", "Los Angeles"/)
   longitude= (/-112.0667, -118.25/)
   latitude = (/33.45, 34.05/)

;  SET UP LIMITED REGION
   minlatn  =  25.0
   maxlatn  =  45.0
   minlonn  = -125.0
   maxlonn  = -95.0

;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   resmp    = True

;  SET UP MAP PROJECTION AND LIMITED REGION
   resmp@mpProjection      = "CylindricalEquidistant"
   resmp@mpCenterRotF      = 0.0
   resmp@mpGridAndLimbOn   = True
   resmp@mpGridLatSpacingF = 5.0
   resmp@mpGridLonSpacingF = 5.0
   resmp@mpLimitMode       = "latlon"
   resmp@mpMinLatF         = minlatn
   resmp@mpMaxLatF         = maxlatn
   resmp@mpMinLonF         = minlonn
   resmp@mpMaxLonF         = maxlonn

;  COLOR AND THICKNESS OF CONTINIENTAL OUTLINES OF MAP
   resmp@mpOutlineOn                 = True
   resmp@mpGeophysicalLineColor      = "Black"
   resmp@mpNationalLineColor         = "Black"
   resmp@mpUSStateLineColor          = "Black"
   resmp@mpGridLineColor             = "Black"
   resmp@mpLimbLineColor             = "Black"
   resmp@mpPerimLineColor            = "Black"
   resmp@mpGeophysicalLineThicknessF = 3.0
   resmp@mpGridLineThicknessF        = 1.5
   resmp@mpLimbLineThicknessF        = 3.0
   resmp@mpNationalLineThicknessF    = 3.0
   resmp@mpUSStateLineThicknessF     = 3.0
   resmp@mpGridLineDashPattern       = 2
   resmp@mpOutlineBoundarySets       = "GeophysicalAndUSStates"
;  resmp@mpFillAreaSpecifiers        = (/"Land", "Arizona:counties","Water"/)
;  resmp@mpSpecifiedFillColors       = (/"white","transparent",     "white"/)
;  resmp@mpOutlineSpecifiers         = (/"Land","Arizona:counties"/)
;  resmp@mpMaskOutlineSpecifiers     = (/"water"/)
;  resmp@tiMainString                = "Arizona Counties"
;  resmp@mpDataBaseVersion           = "Ncarg4_1"
;  resmp@mpDataSetName               = "Earth..2"   ; For counties


;  TURN ON MAP TICKMARKS
   resmp@pmTickMarkDisplayMode       = "always"
   resmp@vpWidthF                    = 0.85
   resmp@vpHeightF                   = 0.55
   resmp@vpXF                        = 0.10
   resmp@vpYF                        = 0.85
   resmp@gsnDraw                     = False
   resmp@gsnFrame                    = False
   resmp@mpFillOn                    = False
   map  = gsn_csm_map(wks,resmp)

;  TEXT RESOURCES
   tres                              = True
   tres@txFontHeightF                = 0.012
   tres@txFontThicknessF             = 15
   tres@txFontColor                  = "Blue"
   do i = 0, nsites-1
    add_markers(wks,map,longitude(i),latitude(i),"Red",16,0.012,2.5)
   end do ; END OF I LOOP
   draw(map)
   do i = 0, nsites-1
    gsn_text(wks, map, sitename(i), longitude(i), latitude(i), tres)
   end do ; END OF I LOOP
   frame(wks)
end
