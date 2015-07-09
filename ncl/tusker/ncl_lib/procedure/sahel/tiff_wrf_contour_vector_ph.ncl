; $ID: tiff_wrf_contour_vector_ph.ncl V01 02/09/2012 10:43 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE tiff_wrf_contour_vector_ph IS TO PLOT WRFCHEM VERTICAL CONTOUR 
;  AND WIND VECTOR DEPENDING ON CALIPSO TRACK PATH.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks    (graphic): WORK STATION                                   [---]
;  (2 ) in     (integer): TOTAL # OF SELECTED WRFCHEM GRIDS              [---]
;  (3 ) npts   (integer): # OF X AXIS LABELS                             [---]
;  (4 ) slatn  (float)  : SELECTED CALIPSO LATITUDE IN LIMITED REGION    [deg]
;  (5 ) aslonn1(float)  : SELECTED CALIPSO LONGITUDE IN LIMITED REGION   [deg]
;  (6 ) dateh  (string) : WRFCHEM DATE (FORMAT : YEAR-MONTH-DAY, 
;                         i.e. 2008-02-26)                               [---]
;  (7 ) timeh  (string) : WRFCHEM TIME (FORMAT : TIME, 01)               [---]
;  (8 ) sspm25h(float)  : NEW SELECTED WRFCHEM PM2.5 DATA                [um/m3]
;  (9 ) plot   (graphic): PM2.5 VERTICAL CONTOUR PLOT                    [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/09/2012)
;  (2 ) MODIFIED FROM HEIGHT TO PRESSURE FOR Y AXIS. (09/17/2012)
;******************************************************************************

undef("tiff_wrf_contour_vector_ph")
procedure tiff_wrf_contour_vector_ph \
          (wks       :graphic, wrf2gtiff :logical, \ ; INPUT
           inpt      :file,    in        :integer, \ ; INPUT
           npts      :integer,slatn      :float,   \ ; INPUT
           aslonn1   :float,                       \ ; INPUT
           dateh     :string, timeh      :string,  \ ; INPUT
           u         :float,  w          :float,   \ ; INPUT
           sspm25h   :float,                       \ ; INPUT
           plot      :graphic)                       ; OUTPUT

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
  cres@tmXBMajorLengthF       = 0.005
  cres@tmYRMajorLengthF       = 0.005
  cres@tmYLMajorLengthF       = 0.005
  cres@tmYRMinorLengthF       = 0.002
  cres@tmYLMinorLengthF       = 0.002

; SET UP LABEL BAR
  cres@pmLabelBarWidthF       = 0.1
  cres@pmLabelBarHeightF      = 0.5
  cres@lbLabelFontHeightF     = 0.02
  cres@lbLabelStride          = 4
  cres@lbBoxLinesOn           = False
  cres@lbOrientation          = "Vertical"
  cres@lbLabelPosition        = "Left"

; SET UP THE POSITION OF THE CONTOUR PLOT
  cres@vpWidthF               = 0.6
  cres@vpHeightF              = 0.45
  cres@vpXF                   = 0.2
  cres@vpYF                   = 0.8
  cres@gsnDraw                = False
  cres@gsnFrame               = False

; SET UP AXIS LABEL FOR CONTOUR PLOT OF WRFCHEM
  cresn                       = True
  cresn                       = cres
  stride                      = floattoint(in/npts)+1
  cresn@tmXBMode              = "Explicit"
  cresn@tmXBValues            = fspan(0.,(in-2),npts)
  cresn@tmXBLabels            = sprintf("%5.2f", (slatn(0:(in-2):stride))) + "~C~" + \
                                sprintf("%5.2f", (aslonn1(0:(in-2):stride)))
  cresn@cnLevelSelectionMode  = "ManualLevels"
  cresn@cnMinLevelValF        = 5.
  cresn@cnMaxLevelValF        = 205.
  cresn@cnLevelSpacingF       = 5.
  cresn@tiXAxisString         = "Latitude~C~Longitude"
  cresn@tiYAxisString         = "Altitude (hPa)"
  cresn@tiMainString          = "WRF-Chem    " + dateh + "_" + timeh

; SET UP VECTOR RESOURCES
  cresvn                          = True
  cresvn                          = cresn
  cresvn@vcRefMagnitudeF          = 10.0
  cresvn@vcRefLengthF             = 0.05
  cresvn@vcRefAnnoOrthogonalPosF  = -1.124
  cresvn@vcRefAnnoArrowLineColor  = "purple"
  cresvn@vcRefAnnoArrowUseVecColor= False
  cresvn@vcGlyphStyle             = "LineArrow"
  cresvn@vcLineArrowColor         = "purple"
  cresvn@vcLineArrowThicknessF    = 1.5
  cresvn@vcVectorDrawOrder        = "PostDraw"
  cresvn@vcMinDistanceF           = 0.04
  sspm25h@units                   = "~F33~m~F21~g/(kg-dryair)"
  sspm25h@description             = "Dust Concentration Profile"
  plot = gsn_csm_pres_hgt_vector(wks, sspm25h, u, w, cresvn)
  wrf2geotiff_write(wrf2gtiff, inpt, dateh+timeh, wks, plot, False)
  draw(plot)
  frame(wks)
  delete(cresn)
  wrf2geotiff_close(wrf2gtiff, wks)
return
end
