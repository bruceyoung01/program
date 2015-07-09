; $ID: plot_calipso_l2.ncl V01 02/09/2012 10:02 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_calipso_l2 IS TO PLOT CALIPSO LEVEL 2 PROFILE CONTOUR.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks    (graphic): WORK STATION                                   [---]
;  (2 ) height (float)  : HEIGHT ARRAY FROM 0-15km WITH NEW # OF LEVELS  [km ]
;  (3 ) maxh   (float)  : MAXIMUM HEIGHT VALUE                           [km ]
;  (4 ) minh   (float)  : MINIMUM HEIGHT VALUE                           [km ]
;  (5 ) in     (integer): TOTAL # OF SELECTED WRFCHEM GRIDS              [---]
;  (6 ) npts   (integer): # OF X AXIS LABELS                             [---]
;  (7 ) slatn  (float)  : SELECTED CALIPSO LATITUDE IN LIMITED REGION    [deg]
;  (8 ) aslonn1(float)  : SELECTED CALIPSO LONGITUDE IN LIMITED REGION   [deg]
;  (9 ) timeall(string) : CALIPSO TIME STRING (FORMAT : HOUR-MINUTE-SECOND,
;                         i.e. 01-01-01)                                 [---]
;  (10) dateh  (string) : CALIPSO DATE (FORMAT : YEAR-MONTH-DAY, 
;                         i.e. 2008-02-26)                               [---]
;  (11) timeh  (string) : CALIPSO TIME (FORMAT : TIME, 01)               [---]
;  (12) ndimh  (integer): # OF SELECTED CALIPSO DATA INDEX IN LIMITED 
;                         REGION                                         [---]
;  (13) rsech  (float)  : SELECTED AEROSOL EXTINCTION COEFFICIENT        [km-1]
;  (14) rsclfh (float)  : SELECTED CLOUD FRACTION                        [---]
;  (15) rssfch (float)  : SELECTED SURFACE ELEVATION STATISTICS          [---]
;  (16) plot1  (graphic): CALIPSO PLOT                                   [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/09/2012)
;
;******************************************************************************

undef("plot_calipso_l2")
procedure plot_calipso_l2(wks       :graphic,                \ ; INPUT
                          height    :float,  maxh   :float,  \ ; INPUT
                          minh      :float,  in     :integer,\ ; INPUT
                          npts      :integer,slatn  :float,  \ ; INPUT
                          aslonn1   :float,  timeall:string, \ ; INPUT
                          dateh     :string, timeh  :string, \ ; INPUT
                          ndimh     :integer,rsech  :float,  \ ; INPUT
                          rsclfh    :float,  rssfch :float,  \ ; INPUT
                          plot1     :graphic)                  ; OUTPUT

begin

; PLOT THE VERTICAL PROFILE OF WRFCHEM BASED ON CALIPSO
; SET UP RESOURCES
  cres                        = True
  cres@cnFillOn               = True
; TURN OFF CONTOUR LINES
  cres@cnLinesOn              = False
; TURN OFF CONTOUR LABELS
  cres@cnLineLabelsOn         = False
  cres@gsnSpreadColors        = True
  cres@sfYArray               = height
  cres@trYMaxF                = maxh
  cres@trYMinF                = minh
  cres@tmXBMajorLengthF       = 0.005
  cres@tmYRMajorLengthF       = 0.005
  cres@tmYLMajorLengthF       = 0.005
  cres@tmYRMinorLengthF       = 0.002
  cres@tmYLMinorLengthF       = 0.002
  
; SET UP LABEL BAR
  cres@pmLabelBarWidthF       = 0.05
  cres@pmLabelBarHeightF      = 0.3
  cres@lbLabelFontHeightF     = 0.01
  cres@lbLabelStride          = 1
  cres@lbBoxLinesOn           = False
  cres@lbOrientation          = "Vertical"
  cres@lbLabelPosition        = "Right"
  
; SET UP THE POSITION OF THE CONTOUR PLOT
  cres@vpWidthF               = 0.4
  cres@vpHeightF              = 0.25
  cres@vpXF                   = 0.3
  cres@vpYF                   = 0.7
  cres@gsnDraw                = False
  cres@gsnFrame               = False

; SET UP AXIS LABEL FOR CONTOUR PLOT OF CALIPSO
  cresh                       = True
  cresh                       = cres
  cresh@tmXBMode              = "Explicit"
  cresh@tmXBValues            = fspan(0.,(ndimh-1),npts)
  stride                      = floattoint(in/npts)+1
  cresh@tmXBLabels            = sprintf("%5.2f", (slatn(0:(in-2):stride))) + "~C~" + \
                                sprintf("%5.2f", (aslonn1(0:(in-2):stride)))
  cresh@tiXAxisString         = "Latitude~C~Longitude"
  cresh@tiYAxisString         = "Altitude (km)"
  cresh@tiMainString          = "CALISPO    " + dateh + "_" + timeall
  cresh@cnLevelSelectionMode  = "ManualLevels"
  cresh@cnMinLevelValF        = 0.0
  cresh@cnMaxLevelValF        = 0.5
  cresh@cnLevelSpacingF       = 0.05

  rsech@units                 = "km~S~-1"
  rsech@description           = "Aerosol Extinction Coefficient 532nm"
  gsn_define_colormap(wks,"GaAqGrYeOrReVi200")
  plot1 = gsn_csm_contour(wks, rsech, cresh)
  rsclfh@units                = " "
  rsclfh@description          = " "
  plot2 = gsn_csm_contour(wks, rsclfh, cresh)
  plres                       = True
  plres@gsLineColor           = "black"
  plres@gsLineThicknessF      = 2.0
  dum = gsn_add_polyline(wks, plot2, fspan(0.,(ndimh-1),ndimh), rssfch, plres)
  overlay(plot1, plot2)
  draw(plot1)
  frame(wks)
  delete(plres)

return
end
