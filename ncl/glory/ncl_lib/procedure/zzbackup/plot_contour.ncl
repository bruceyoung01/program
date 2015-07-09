; $ID: plot_contour.ncl V01 05/07/2012 21:10 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_contour PLOTS CONTOUR WITH KNOWN 2-D ARRAY OF LATITUDE, 
;  LONGITUDE, AND DATA.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/07/2012)
;******************************************************************************

undef("plot_contour")
procedure plot_contour(wks       :graphic, satellite :string, \ ; INPUT
                       lat       :float,   lon       :float,  \ ; INPUT
                       data      :float,                      \ ; INPUT
                       minlat    :float,   maxlat    :float,  \ ; INPUT
                       minlon    :float,   maxlon    :float,  \ ; INPUT
                       year      :integer, month     :integer,\ ; INPUT
                       day       :integer,                    \ ; INPUT
                       cplot     :graphic)                      ; OUTPUT

begin

; SET UP COLOR MAP
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

; SET UP THE DESIRED MODS FOR THE MAP AND PLOT
  res                              = True
  res@vpWidthF                     = 0.6
  res@vpHeightF                    = 0.35
  res@vpXF                         = 0.20
  res@vpYF                         = 0.85

; SET UP MAP PROJECTION AND LIMITED REGION
  res@mpProjection                 = "CylindricalEquidistant"
  res@mpCenterRotF                 = 0.0
  res@mpGridAndLimbOn              = True
  res@mpGridLatSpacingF            = 5.0
  res@mpGridLonSpacingF            = 5.0
  res@mpLimitMode                  = "latlon"
  res@mpMinLatF                    = minlat
  res@mpMaxLatF                    = maxlat
  res@mpMinLonF                    = minlon
  res@mpMaxLonF                    = maxlon
; COLOR AND THICKNESS OF CONTINIENTAL OUTLINES
  res@mpOutlineOn                  = True
  res@mpOutlineBoundarySets        = "GeophysicalAndUSStates"
  res@mpGeophysicalLineColor       = "White"
  res@mpNationalLineColor          = "White"
  res@mpUSStateLineColor           = "Black"
  res@mpGridLineColor              = "White"
  res@mpLimbLineColor              = "White"
  res@mpPerimLineColor             = "White"
  res@mpGeophysicalLineThicknessF  = 2.0
  res@mpGridLineThicknessF         = 1.5
  res@mpLimbLineThicknessF         = 2.0
  res@mpNationalLineThicknessF     = 2.0
  res@mpUSStateLineThicknessF      = 2.0
  res@mpGridLineDashPattern        = 2

; TURN ON MAP TICKMARKS
  res@pmTickMarkDisplayMode        = "always"

; MAXIMIZE PLOT IN FRAME
  res@gsnMaximize                  = True

; THE DATA IS NOT GLOBAL
  res@gsnAddCyclic                 = False

; SET UP THE FEATRUED TITLE
  res@gsnLeftString                = "AOD"
  res@gsnStringFontHeightF         = 0.01
  res@gsnLeftStringOrthogonalPosF  = 0.01

; COLOR PLOT DEDIRED
  res@cnFillOn                     = True

; TURN OFF CONTOUR LINES
  res@cnLinesOn                    = False

; TURN OFF CONTOUR LABELS
  res@cnLineLabelsOn               = False

; SET UP COLOR MAP AND LABEL
  res@gsnSpreadColors              = True
  res@gsnSpreadColorStart          = 0
  res@gsnSpreadColorEnd            = 200
  res@cnInfoLabelOn                = True
  res@cnInfoLabelFontHeightF       = 0.01
  res@cnLevelSelectionMode         = "ManualLevels"
  res@cnMinLevelValF               = 0.0
  res@cnMaxLevelValF               = 1.0
  res@cnLevelSpacingF              = 0.1

; SET UP LABEL BAR
  res@pmLabelBarWidthF             = 0.6
  res@pmLabelBarHeightF            = 0.08
  res@lbLabelFontHeightF           = 0.013
  res@lbLabelStride                = 1
  res@lbBoxLinesOn                 = False

  data@lat2d                       = lat
  data@lon2d                       = lon
  res@tiMainString                 = satellite + "  " + year + "-" + month + "-" + day
  res@tiMainFontHeightF            = 0.02
  res@lbTitleString                = " Aerosol Optical Depth (550 nm)"
  res@lbTitleFontHeightF           = 0.015
  res@lbTitlePosition              = "Bottom"
  cplot                            = gsn_csm_contour_map(wks,data,res)
  delete(res)
return
end
