; $ID plot_wrfchem_map_contour_diff.ncl V01 01/18/2012 15:53 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_wrfchem_map_contour_diff IS USED TO PLOT CONTOUR USING WRFCHEM 
;  OUTPUT FILES. ITS COLOR MAP IS DIFFERENT FROM plot_wrfchem_map_contour.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks    (graphic) : WORK STATION                               [---]
;  (2 ) data   (integer) : WRFCHEM FILE DATE INCLUDING YEAR, MONTH, DAY, AND 
;                          HOUR.                                      [---]
;  (3 ) i      (integer) : THE ORDER OF HOURS FROM 00 TO 23           [---]
;  (4 ) wlat   (float)   : WRFCHEM OUTPUT LATITUDE                    [deg]
;  (5 ) wlon   (float)   : WRFCHEM OUTPUT LONGITUDE                   [deg]
;  (6 ) data   (float)   : WRFCHEM OUTPUT DATA TO BE PLOTTED          [---]
;  (7 ) plot   (graphic) : CONTOUR PLOT                               [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/18/2012)
;******************************************************************************

undef("plot_wrfchem_map_contour_diff")
procedure plot_wrfchem_map_contour_diff(wks       :graphic, \ ; INPUT
                                        date      :integer, \ ; INPUT
                                        i         :integer, \ ; INPUT
                                        wlat      :float,   \ ; INPUT
                                        wlon      :float,   \ ; INPUT
                                        data      :float,   \ ; INPUT
                                        plot      :graphic)   ; OUTPUT

begin
; REDEFINE COLOR MAP
  gsn_define_colormap(wks,"BlWhRe")

; ASSIGN LATITUDE AND LONGITUDE TO DATA
  data@lat2d                        = wlat
  data@lon2d                        = wlon

; SET UP THE DESIRED MODS FOR THE MAP AND PLOT
  mpres                             = True
; SET UP MAP PROJECTION AND LIMITED REGION
  mpres@mpProjection                = "CylindricalEquidistant"
  mpres@mpCenterRotF                = 0.0
  mpres@mpGridAndLimbOn             = True    
  mpres@mpGridLatSpacingF           = 5.0     
  mpres@mpGridLonSpacingF           = 5.0
  mpres@mpLimitMode                 = "latlon"
  mpres@mpMinLatF                   =-15.0
  mpres@mpMaxLatF                   = 35.0
  mpres@mpMinLonF                   =-25.0
  mpres@mpMaxLonF                   = 45.0

; COLOR OF CONTINIENTAL OUTLINES
  mpres@mpOutlineOn                 = True
  mpres@mpGeophysicalLineColor      = "Black"
  mpres@mpNationalLineColor         = "Black"
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

  res                               = True
  res                               = mpres
; MAXIMIZE PLOT IN FRAME
  res@gsnMaximize                   = True
; THE DATA IS NOT GLOBAL
  res@gsnAddCyclic                  = False
; SET UP THE FEATRUED TITLE
  res@gsnLeftString                 = "2m Temperature"
  res@gsnStringFontHeightF          = 0.02
  res@gsnLeftStringOrthogonalPosF   = 0.02

; COLOR PLOT DEDIRED
  res@cnFillOn                      = True
; TURN OFF CONTOUR LINES
  res@cnLinesOn                     = False
; TURN OFF CONTOUR LABELS
  res@cnLineLabelsOn                = False

; SET UP COLOR MAP AND LABEL
  res@gsnSpreadColors               = True
  res@cnInfoLabelOn                 = True
  res@cnInfoLabelFontHeightF        = 0.01
  res@cnLevelSelectionMode          = "ManualLevels"
  res@cnMinLevelValF                = -0.5
  res@cnMaxLevelValF                =  0.5
  res@cnLevelSpacingF               =  0.05

; SET UP LABEL BAR
  res@pmLabelBarWidthF              = 0.6
  res@pmLabelBarHeightF             = 0.08
  res@lbLabelFontHeightF            = 0.013
  res@lbLabelStride                 = 2
  res@lbBoxLinesOn                  = False
  res@tiMainString                  = "WRFCHEM  2008 Feb Feedback-NoFeedback " + date(i*24, 2)
  res@tiMainFontHeightF             = 0.02
  res@lbTitleString                 = "2m Temperature (K)"
  res@lbTitleFontHeightF            = 0.015
  res@lbTitlePosition               = "Bottom"
  plot = gsn_csm_contour_map(wks, data(i, :, :), res)
  delete(mpres)
  delete(res)
return
end


