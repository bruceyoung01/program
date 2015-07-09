; $ID: aeronet_map.ncl V01 12/16/2011 10:07 BRUCE EXP$
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  PROGRAM aeronet_map is mainly used to plot AERONET sites on the map.
;
;  NOTES: 
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (12/16/2011)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;  LOAD LIBRARIES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/add_markers.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/universal/read_aeronet_sites.ncl"

begin

; SET UP THE PLOT PLATFORM
  type = "x11"
; type = "pdf"
  wks  = gsn_open_wks(type, "1plt_aeronet_sites_map_ne_v01")
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  DEFINE DIRECTORY AND FILE NAME
   dir      = "/home/bruce/program/ncl/tutorial/test/ne/aeronet_map/"
   filename = "AERONET_SITES_201106"
;  NUMBER OF AERONET SITES
   nsites   = 206
;  READ AERONET SITES INFO
   sitename = new(nsites, string)
   longitude= new(nsites, float)
   latitude = new(nsites, float)
   elevation= new(nsites, float)
   read_aeronet_sites(dir, filename, sitename, longitude, latitude, elevation)

;  SET UP LIMITED REGION
;                       NE     WA       CA     SAHEL 
   minlatn  =  25.0   ; 25.0   ; 30.0    ; 10    ;-15.0
   maxlatn  =  45.0   ; 45.0   ; 45.0    ; 45    ; 35.0
   minlonn  = -115.0  ;-115.0  ;-130.0   ;-115   ;-25.0
   maxlonn  = -90.0   ;-90.0   ;-110.0   ;-65    ; 45.0

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
   resmp@tiMainString                = "AERONET SITES (Jun 2011)"

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
