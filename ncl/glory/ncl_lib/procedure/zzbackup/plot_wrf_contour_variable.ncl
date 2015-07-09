; $ID: plot_wrf_contour_variable.ncl V01 03/29/2012 10:05 BRUCE EXP$
;
;******************************************************************************
;  PURPOSE OF THIS FUNCTION : PLOT THE CONTOUR PLOT USING WRF/CHEM OUTPUT
;  THE STEPS ARE AS FOLLOWING : 
;  1, INPUT WRFCHEM DATA
;  2, PLOT A CONTOUR OVER A MAP
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks   (graphic)  : WORK STATION                                  [---]
;  (2 ) map   (graphic)  : MAP PLOT                                      [---]
;  (3 ) data  (float)    : VARIABLE OF WRFCHEM DATA                      [---]
;  (4 ) times (character): TIME STEP OF PLOT                             [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (03/29/2012)
;******************************************************************************

undef("plot_wrf_contour_variable")
procedure plot_wrf_contour_variable\
                          (wks       :graphic, map   :graphic, \; INPUT
                           data      :float,   times :character); INPUT

begin

  gsn_define_colormap(wks,"WhGrYeOrReVi200")
; SET UP THE DESIRED MODS FOR THE MAP AND PLOT
  res                              = True

; TURN ON MAP TICKMARKS
  res@pmTickMarkDisplayMode        = "always"

; MAXIMIZE PLOT IN FRAME
  res@gsnMaximize                  = True

; THE DATA IS NOT GLOBAL
  res@gsnAddCyclic                 = False

; SET UP THE FEATRUED TITLE
  res@gsnLeftString                = "PM2.5 Column Mass Concentration"
  res@gsnStringFontHeightF         = 0.02
  res@gsnRightStringOrthogonalPosF = 0.02
  res@gsnLeftStringOrthogonalPosF  = 0.02

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
  res@cnConstFLabelFormat          = "#+^se"
  res@cnMinLevelValF               = 1*10^4
  res@cnMaxLevelValF               = 1.1*10^5
  res@cnLevelSpacingF              = 1*10^4

; SET UP LABEL BAR
  res@pmLabelBarWidthF             = 0.6
  res@pmLabelBarHeightF            = 0.08
  res@lbLabelFontHeightF           = 0.013
  res@lbLabelStride                = 2
  res@lbBoxLinesOn                 = False

; PLOT THE CONTOUR OVER THE CE MAP
  res@tiMainString                 = "WRF/Chem "+times
  res@tiMainFontHeightF            = 0.02
  data@description                 = "PM2.5 Column Mass Concentration"
  data@units                       = "~F33~m~F0~g/m~S~2~N~"
  res@lbTitleString                = data@description + "  " + "(" + data@units + ")"
  res@lbTitleFontHeightF           = 0.015
  res@lbTitlePosition              = "Bottom"
  plot                             = gsn_csm_contour_map(wks, data, map, res)
  return(plot)
  delete(res)

end
