; $ID: marker_map.ncl V01 01/10/2012, 11:58 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE marker_map IS USED TO PLOT MARKERS ON THE MAP.
;
;  VARIABALES:
;  ============================================================================
;  (1 ) wks       (graphic) : WORK STATION                             [---]
;  (2 ) minlat    (float)   : MINIMUM LATITUDE OF STUDY REGION         [deg]
;  (3 ) maxlat    (float)   : MAXIMUM LATITUDE OF STUDY REGION         [deg]
;  (4 ) minlon    (float)   : MINIMUM LONGITUDE OF STUDY REGION        [deg]
;  (5 ) maxlon    (float)   : MAXIMUM LONGITUDE OF STUDY REGION        [deg]
;  (6 ) longitude (float)   : AERONET SITE LONGITUDE                   [deg]
;  (7 ) latitude  (float)   : AERONET SITE LATITUDE                    [deg]
;  (8 ) mpplot    (graphic) : MAP PLOT                                 [---]
;  (9 ) plot      (garphic) : MAP PLOT WITH SITE POINT                 [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/10/2012)
;  (2 ) ADD REGION LIMIT BY BRUCE. (05/23/2012)
;******************************************************************************

undef("marker_map")
procedure marker_map(wks      :graphic,                  \ ; INPUT
                     minlat   :float,   maxlat  :float,  \ ; INPUT
                     minlon   :float,   maxlon  :float,  \ ; INPUT
                     longitude:float,   latitude:float,  \ ; INPUT
                     mpplot   :graphic, plot    :graphic)  ; OUTPUT


begin
; SET UP MAP RESOURCES
  mpres                             = True
  mpres@mpFillOn                    = False ; TURN OFF GRAY FILL

; SET UP MAP PROJECTION AND LIMITED REGION
  mpres@mpProjection                = "CylindricalEquidistant"
  mpres@mpCenterRotF                = 0.0
  mpres@mpGridAndLimbOn             = False
  mpres@mpGridLatSpacingF           = 10.0
  mpres@mpGridLonSpacingF           = 10.0
  mpres@mpLimitMode                 = "latlon"
  mpres@mpMinLatF                   = minlat
  mpres@mpMaxLatF                   = maxlat
  mpres@mpMinLonF                   = minlon
  mpres@mpMaxLonF                   = maxlon
  
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
  mpres@mpOutlineBoundarySets       = "GeophysicalAndUSStates"

; TURN ON MAP TICKNARKS
  mpres@pmTickMarkDisplayMode       = "always"
; SET UP THE POSITION OF THE MAP             NORMAL ; WIDER
  mpres@vpWidthF                    = 0.15 ; 0.20   ; 0.15
  mpres@vpHeightF                   = 0.15 ; 0.20   ; 0.15
  mpres@vpXF                        = 0.67 ; 0.57   ; 0.67
  mpres@vpYF                        = 0.85 ; 0.80   ; 0.85
  mpres@mpFillDrawOrder             = "PreDraw"
  mpres@gsnDraw                     = False
  mpres@gsnFrame                    = False

; PLOT MAP BUT NOT DRAW  
  mpplot = gsn_csm_map_ce(wks, mpres)

; SET UP POLY MARKERS
  polyres               = True
  polyres@gsMarkerColor = "Red"
  polyres@gsMarkerIndex = 16
  polyres@gsMarkerSizeF = 10.
  plot = gsn_add_polymarker(wks, mpplot, longitude, latitude, polyres)
return
end
