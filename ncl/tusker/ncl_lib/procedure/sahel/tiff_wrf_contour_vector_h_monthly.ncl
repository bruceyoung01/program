; $ID: tiff_wrf_contour_vector_h_monthly.ncl V01 02/09/2012 10:43 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE tiff_wrf_contour_vector_h_monthly IS TO PLOT WRFCHEM VERTICAL 
;  CONTOUR DEPENDING ON CALIPSO TRACK PATH.
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
;  (9 ) dateh  (string) : CALIPSO DATE (FORMAT : YEAR-MONTH-DAY, 
;                         i.e. 2008-02-26)                               [---]
;  (10) timeh  (string) : CALIPSO TIME (FORMAT : TIME, 01)               [---]
;  (11) sspm25h(float)  : NEW SELECTED WRFCHEM PM2.5 DATA                [um/m3]
;  (12) sspth  (float)  : NEW SELECTED WRFCHEM TEMPERATURE               [C  ]
;  (13) plot2  (graphic): PM2.5 VERTICAL CONTOUR PLOT                    [---]
;  (14) plot3  (graphic): TEMPERATURE VERTICAL CONTOUR PLOT              [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/09/2012)
;******************************************************************************

undef("tiff_wrf_contour_vector_h_monthly")
procedure tiff_wrf_contour_vector_h_monthly \
                            (wks       :graphic,wrf2gtiff  :logical,\ ; INPUT
                             inpt      :file,                       \ ; INPUT
                             height    :float,  maxh      :float,   \ ; INPUT
                             minh      :float,  in        :integer, \ ; INPUT
                             npts      :integer,slatn     :float,   \ ; INPUT
                             aslonn1   :float,                      \ ; INPUT
                             yyyymm    :string,                     \ ; INPUT
                             sspm25h   :float,  sspth     :float,   \ ; INPUT
                             plot2     :graphic,plot3     :graphic  ) ; OUTPUT

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
  cres@pmLabelBarWidthF       = 0.1
  cres@pmLabelBarHeightF      = 0.5
  cres@lbLabelFontHeightF     = 0.02
  cres@lbLabelStride          = 1
  cres@lbBoxLinesOn           = False
  cres@lbOrientation          = "Vertical"
  cres@lbLabelPosition        = "Right"

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
  cresn@cnMinLevelValF        = 2.
  cresn@cnMaxLevelValF        = 22.
  cresn@cnLevelSpacingF       = 2.
  cresn@tiXAxisString         = "Latitude~C~Longitude"
  cresn@tiYAxisString         = "Altitude (km)"
  cresn@tiMainString          = "WRF-Chem    " + yyyymm
  sspm25h@units               = "~F33~m~F21~g/m~S~3~N~"
  sspm25h@description         = "Aerosol Concentration Profile"
  sspth@units                 = "K"
  sspth@description           = "Perturbation Potential Temperature (theta-t0)"
  plot2 = gsn_csm_contour(wks, sspm25h, cresn)
  wrf2geotiff_write(wrf2gtiff, inpt, timen, wks, plot2, False)
  draw(plot2)
  frame(wks)
  delete(cresn)
  wrf2geotiff_close(wrf2gtiff, wks)
return
end
