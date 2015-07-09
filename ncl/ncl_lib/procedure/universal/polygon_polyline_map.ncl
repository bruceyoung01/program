; $ID: polygon_polyline_map.ncl V01 05/23/2015, 14:19 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE polygon_polyline_map PLOTS POLYGONS AND POLYLINES ON THE MAP.
;
;  VARIABALES:
;  ============================================================================
;  (1 ) wks       (graphic) : WORK STATION                             [---]
;  (2 ) minlat    (float)   : MINIMUM LATITUDE OF BACKGROUND REGION    [DEG]
;  (3 ) maxlat    (float)   : MAXIMUM LATITUDE OF BACKGROUND REGION    [DEG]
;  (4 ) minlon    (float)   : MINIMUM LONGITUDE OF BACKGROUND REGION   [DEG]
;  (5 ) maxlon    (float)   : MAXIMUM LONGITUDE OF BACKGROUND REGION   [DEG]
;  (6 ) lat_pl    (float)   : LATITUDE OF CALIPSO GROUND TRACK         [DEG]
;  (7 ) lon_pl    (float)   : LONGITUDE OF CALIPSO GROUND TRACK        [DEG]
;  (6 ) lat_pg    (float)   : LATITUDE OF STUDY REGION                 [DEG]
;  (7 ) lon_pg    (float)   : LONGITUDE OF STUDY REGION                [DEG]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/10/2012)
;  (2 ) ADD REGION LIMIT BY BRUCE. (05/23/2012)
;  (3 ) MODIFIED FROM marker_map.ncl. (03/15/2013)
;  (4 ) MODIFIED FROM marker_map.ncl. (05/23/2015)
;******************************************************************************

undef("polygon_polyline_map")
procedure polygon_polyline_map \
         (wks       :graphic,                   \ ; INPUT
          minlat    :float,   maxlat   :float,  \ ; INPUT
          minlon    :float,   maxlon   :float,  \ ; INPUT
          lat_pl    :float,   lon_pl   :float,  \ ; INPUT
          lat_pg    :float,   lon_pg   :float)    ; INPUT


begin
; SET UP MAP RESOURCES
  mpres                             = True
  mpres@mpFillOn                    = True ; TURN OFF GRAY FILL
  mpres@mpMonoFillColor             = True
  mpres@mpFillColor                 = "White"
  mpres@mpPerimOn                   = False

; SET UP MAP PROJECTION AND LIMITED REGION
  mpres@mpProjection                = "CylindricalEquidistant"
  mpres@mpCenterRotF                = 0.0
  mpres@mpGridAndLimbOn             = False
  mpres@mpGridLatSpacingF           = 10.0
  mpres@mpGridLonSpacingF           = 10.0
  mpres@mpLimitMode                 = "latlon"
; GET THE GLOBAL MAP
  mpres@mpMinLatF                   = -90.0
  mpres@mpMaxLatF                   =  90.0
  mpres@mpMinLonF                   = -180.0
  mpres@mpMaxLonF                   =  180.0
  
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
; mpres@mpOutlineBoundarySets       = "GeophysicalAndUSStates"
  mpres@mpOutlineOn                 = True
; mpres@mpOutlineBoundarySets       = "AllBoundaries"
; mpres@mpDataSetName               = "Earth..4"
; mpres@mpDataBaseVersion           = "MediumRes"


; TURN ON MAP TICKNARKS
  mpres@pmTickMarkDisplayMode       = "always"
; SET UP THE POSITION OF THE MAP             AMSR-E ; CALIPSO/MODIS
  mpres@vpWidthF                    = 0.15 ; 0.20   ; 0.15
  mpres@vpHeightF                   = 0.15 ; 0.20   ; 0.15
  mpres@vpXF                        = 0.71 ; 0.57   ; 0.71
  mpres@vpYF                        = 0.95 ; 0.80   ; 0.95
  mpres@mpFillDrawOrder             = "PreDraw"
  mpres@gsnDraw                     = False
  mpres@gsnFrame                    = False

; PLOT MAP BUT NOT DRAW  
  mpplot = gsn_csm_map_ce(wks, mpres)

  gres                              = True
  gres@gsFillColor                  = "Red"
  dum1 = gsn_add_polygon(wks, mpplot, lon_pg, lat_pg, gres)

;  ADD POLYLINE TO THE CONTOUR PLOT
   plres                  = True
   plres@gsLineColor      = "blue"
   plres@gsLineThicknessF = 2.0
   if (.not.all(ismissing(lat_pl)) .and. \
       .not.all(ismissing(lon_pl))) then
      ndim_lat_pl = dimsizes(lat_pl)
      nctrack     = ndim_lat_pl(1)
      dum         = new((/nctrack/), graphic)
;  DO TRACK LOOP TO PLOT TRACK ONE BY ONE
      do ictrack = 0, nctrack-1
         if (.not.all(ismissing(lat_pl(:, ictrack))) .and. \
             .not.all(ismissing(lon_pl(:, ictrack)))) then
            dum(ictrack) = gsn_add_polyline(wks, mpplot, lon_pl(:, ictrack), lat_pl(:, ictrack), plres)
         end if
      end do
   end if

  draw(mpplot)
  frame(wks)
return
end
