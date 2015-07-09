; $ID: map.ncl V01 03/29/2012, 09:37 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE map IS USED TO PLOT THE MAP IN LIMITED REGION.
;
;  VARIABALES:
;  ============================================================================
;  (1 ) wks      (graphic) : WORK STATION                             [---]
;  (2 ) minlat   (float)   : MINIMUM LATITUDE OF LIMITED REGION       [---]
;  (3 ) maxlat   (float)   : MAXIMUM LATITUDE OF LIMITED REGION       [---]
;  (4 ) minlon   (float)   : MINIMUM LONGITUDE OF LIMITED REGION      [---]
;  (5 ) maxlon   (float)   : MAXIMUM LONGITUDE OF LIMITED REGION      [---]
;  (6 ) mpplot   (graphic) : MAP PLOT                                 [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (03/29/2012)
;  (2 ) MODIFIED FROM marker_map.ncl. (03/29/2012)
;******************************************************************************

undef("map")
procedure map(wks      :graphic,\ ; INPUT
              minlat   :float,   maxlat    :float,  \ ; INPUT
              minlon   :float,   maxlon    :float,  \ ; INPUT              
              mpplot   :graphic)  ; OUTPUT


begin
; SET UP MAP RESOURCES
  mpres                             = True
  mpres@mpFillOn                    = False ; TURN OFF GRAY FILL

; SET UP MAP PROJECTION AND LIMITED REGION
  mpres@mpProjection                = "CylindricalEquidistant"
  mpres@mpCenterRotF                = 0.0
  mpres@mpGridAndLimbOn             = True
  mpres@mpGridLatSpacingF           = 5.0
  mpres@mpGridLonSpacingF           = 5.0
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
  delete(mpres)
return
end
