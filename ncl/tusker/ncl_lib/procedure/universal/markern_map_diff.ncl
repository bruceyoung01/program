; $ID: markern_map_diff.ncl V01 03/15/2013, 15:04 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE markern_map_diff PLOTS MARKERS WITH THE DIFFERENT COLOR AND MARKER 
;  ON THE MAP.
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
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/10/2012)
;  (2 ) ADD REGION LIMIT BY BRUCE. (05/23/2012)
;  (3 ) MODIFIED FROM marker_map.ncl. (03/15/2013)
;******************************************************************************

undef("markern_map_diff")
procedure markern_map_diff \
         (wks       :graphic,                   \ ; INPUT
          minlat    :float,   maxlat   :float,  \ ; INPUT
          minlon    :float,   maxlon   :float,  \ ; INPUT
          longitude :float,   latitude :float,  \ ; INPUT
          mpplot    :graphic)                     ; OUTPUT


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
  mpres@mpFillOn                    = False
  mpres@mpOutlineOn                 = True
  mpres@mpOutlineBoundarySets       = "AllBoundaries"
  mpres@mpDataSetName               = "Earth..4"
  mpres@mpDataBaseVersion           = "MediumRes"


; TURN ON MAP TICKNARKS
  mpres@pmTickMarkDisplayMode       = "always"
; SET UP THE POSITION OF THE MAP             NORMAL ; WIDER
  mpres@vpWidthF                    = 0.18 ; 0.20   ; 0.15
  mpres@vpHeightF                   = 0.18 ; 0.20   ; 0.15
  mpres@vpXF                        = 0.66 ; 0.57   ; 0.67
  mpres@vpYF                        = 0.83 ; 0.80   ; 0.85
  mpres@mpFillDrawOrder             = "PreDraw"
  mpres@gsnDraw                     = False
  mpres@gsnFrame                    = False

; PLOT MAP BUT NOT DRAW  
  mpplot = gsn_csm_map_ce(wks, mpres)

; DO # OF POINTS LOOP
  oned_lat = ndtooned(latitude)
  oned_lon = ndtooned(longitude)
  nlat     = dimsizes(oned_lat)
  nlon     = dimsizes(oned_lon)
; FOR TWO POINTS
  color    = (/"Red", "Blue"/)
  ncolor   = dimsizes(color)
  marker   = (/16, 12/)
  nmarker  = dimsizes(marker)
  size     = (/10.0, 10.0/)
  nsize    = dimsizes(size)
  thick    = (/1.0, 3.0/)
  nthick   = dimsizes(thick)
  if (nlat .eq. nlon) then
   if (nlat .eq. ncolor  .and. \
       nlat .eq. nmarker .and. \
       nlat .eq. nsize   .and. \
       nlat .eq. nthick) then
    do i = 0, nlat-1
     add_markers(wks, mpplot, longitude(i), latitude(i), \
                 color(i), marker(i), size(i), thick(i))
    end do
   else
    print("Please reset # of color, marker, size and thick in SUBROUTINE markern_map_diff.ncl!!!")
   end if
  else if (nlat .ne. nlon) then
   print("Latitude and Longitude do not match !!! Please double-check")
  end if
  end if
return
end
