; $ID: map_calipso.ncl V01 04/16/2012, 14:57 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE map_calipso IS USED TO PLOT THE MAP IN LIMITED REGION OVERLAID 
;  WITH CALIPSO GROUND TRACK.
;
;  VARIABALES:
;  ============================================================================
;  (1 ) wks      (graphic) : WORK STATION                             [---]
;  (2 ) dir      (string)  : CALIPSO LEVEL 2 DATA DIRECTORY           [---]
;  (3 ) filename (string)  : CALIPSO LEVEL 2 DATA FILE NAME           [---]
;  (4 ) minlat   (float)   : MINIMUM LATITUDE OF LIMITED REGION       [deg]
;  (5 ) maxlat   (float)   : MAXIMUM LATITUDE OF LIMITED REGION       [deg]
;  (6 ) minlon   (float)   : MINIMUM LONGITUDE OF LIMITED REGION      [deg]
;  (7 ) maxlon   (float)   : MAXIMUM LONGITUDE OF LIMITED REGION      [deg]
;  (8 ) mpplot   (graphic) : MAP PLOT                                 [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (03/29/2012)
;  (2 ) MODIFIED FROM marker_map.ncl. (03/29/2012)
;  (3 ) MODIFIED FROM map.ncl. (04/16/2012)
;******************************************************************************

undef("map_calipso")
procedure map_calipso(wks      :graphic, dir       :string, \ ; INPUT
                      filename :string,                     \ ; INPUT
                      minlat   :float,   maxlat    :float,  \ ; INPUT
                      minlon   :float,   maxlon    :float,  \ ; INPUT              
                      mpplot   :graphic)  ; OUTPUT


begin
; READ CALIPSO GROUND TRACK LATITUDE AND LONGITUDE FROM CALIPSO LEVEL 2 DATA
  fh     = addfile(dir + filename, "r")
  lath   = fh->Latitude
  lonh   = fh->Longitude
  dimlath= dimsizes(lath)
  dimlonh= dimsizes(lonh)
; ASSIGN NEW 1 DIMENSIONAL ARRAY FOR LATITUDE AND LONGITUDE OF CALIPSO
  lathh  = lath(:,0)
  lonhh  = lonh(:,0)
; SET UP THE RESOURCES FOR LINE PLOT
  pres                              = True
  pres@gsLineThicknessF             = 2.5
  pres@gsLineColor                  = "red"

; SET UP MAP RESOURCES
  mpres                             = True
  mpres@mpFillOn                    = False

; SET UP MAP PROJECTION AND LIMITED REGION
  mpres@mpProjection                = "CylindricalEquidistant"
  mpres@mpCenterRotF                = 0.0
  mpres@mpGridAndLimbOn             = False
; mpres@mpGridLatSpacingF           = 50
; mpres@mpGridLonSpacingF           = 50
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
  mpres@mpGridLineColor             = "White"
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
; SET UP THE POSITION OF THE MAP             NORMAL ; WIDER ; PANEL
  mpres@vpWidthF                    = 0.10 ; 0.20   ; 0.15  ; 0.1
  mpres@vpHeightF                   = 0.10 ; 0.20   ; 0.15  ; 0.1
  mpres@vpXF                        = 0.52 ; 0.57   ; 0.67  ; 0.6
  mpres@vpYF                        = 0.90 ; 0.80   ; 0.85  ; 0.85
  mpres@mpFillDrawOrder             = "PreDraw"
  mpres@gsnDraw                     = False
  mpres@gsnFrame                    = False

; PLOT MAP AND DRAW  
  mpplot = gsn_csm_map_ce(wks, mpres)
  gsn_polyline(wks, mpplot, lonhh, lathh, pres)
  draw(mpplot)
  frame(wks)
  delete([/lath, lonh, lathh, lonhh, pres, mpres/])
return
end
