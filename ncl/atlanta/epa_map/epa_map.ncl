; $ID: epa_map.ncl V01 02/23/2013 09:46 BRUCE EXP$
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  PROGRAM epa_map is mainly used to plot EPA sites on the map.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES: 
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/23/2013)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;  LOAD LIBRARIES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/function/add_markers.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_epa_sites.ncl"

begin

; SET UP THE PLOT PLATFORM
; type = "x11"
  type = "pdf"
  wks  = gsn_open_wks(type, "1plt_epa_sites_map_v01")
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  DEFINE DIRECTORY AND FILE NAME
   dir      = "/work/jwang7/bruceyoung01/model/ncl/atlanta/epa_map/"
   filename = "EPA_SITES"
;  NUMBER OF AERONET SITES
   nsites   = 5
;  READ AERONET SITES INFO
   sitename = new(nsites, string)
   longitude= new(nsites, float)
   latitude = new(nsites, float)
   elevation= new(nsites, float)
   read_epa_sites(dir, filename, sitename, longitude, latitude, elevation)

; RANGE OF STUDY AREA
;             SAHEL     WA       CA    
   minlatn  =  33.0    ;30.0    ;-15.0
   maxlatn  =  34.5    ;45.0    ; 35.0
   minlonn  = -85.5    ;-130.0  ;-25.0
   maxlonn  = -83.5    ;-110.0  ; 45.0

;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   resmp    = True

;  SET UP MAP PROJECTION AND LIMITED REGION
   resmp@mpProjection      = "CylindricalEquidistant"
   resmp@mpCenterRotF      = 0.0
   resmp@mpGridAndLimbOn   = True
   resmp@mpGridLatSpacingF = 0.2
   resmp@mpGridLonSpacingF = 0.2
   resmp@mpLimitMode       = "latlon"
   resmp@mpMinLatF         = minlatn
   resmp@mpMaxLatF         = maxlatn
   resmp@mpMinLonF         = minlonn
   resmp@mpMaxLonF         = maxlonn

;  COLOR AND THICKNESS OF CONTINIENTAL OUTLINES OF MAP
   resmp@mpFillOn                    = False
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
   resmp@tiMainString                = "Atlanta EPA Sites"
   resmp@mpOutlineBoundarySets       = "AllBoundaries"
   resmp@mpDataBaseVersion           = "Ncarg4_1"
   resmp@mpDataSetName               = "Earth..2"

;  TURN ON MAP TICKMARKS
   resmp@pmTickMarkDisplayMode       = "always"
   resmp@vpWidthF                    = 0.85
   resmp@vpHeightF                   = 0.55
   resmp@vpXF                        = 0.10
   resmp@vpYF                        = 0.85
   resmp@gsnDraw                     = False
   resmp@gsnFrame                    = False
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
