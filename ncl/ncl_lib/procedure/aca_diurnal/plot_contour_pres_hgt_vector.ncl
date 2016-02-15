;  $ID: plot_contour_pres_hgt_vector.ncl V01 08/09/2015 20:39 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_contour_pres_hgt_vector.ncl PLOTS VERTICAL CONTOUR ALONG 
;  PRESSURE AND HEIGHT.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks         (graphic):WORK STATION                               [   ]
;  (2 ) stime      (a string):PLOT TITLE                                 [   ]
;  (3 ) in         (a scalar):# OF POINTS OF X AXIS                      [   ]
;  (4 ) npts       (a scalar):# OF TICKS                                 [   ]
;  (5 ) p               (1-D):PRESSURE                                   [hPa]
;  (6 ) lon             (1-D):X AXIS TICK NAMES                          [DEG]
;  (7 ) data            (2-D):DATA TO BE PLOTTED                         [   ]
;  (8 ) u               (2-D):U-WIND COMPONENT                           [m/s]
;  (9 ) v               (2-D):V-WIND COMPONENT                           [m/s]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/09/2015)
;******************************************************************************
undef("plot_contour_pres_hgt_vector")
procedure plot_contour_pres_hgt_vector \
          (wks      :graphic,      stime    :string, \;INPUT
           in       :integer,      npts     :integer,\;INPUT
           p        :numeric,                        \;INPUT
           lon      :float,        data     :numeric,\;INPUT
           u        :numeric,      w        :numeric) ;INPUT

begin

   p@units                     = "hPa"
   data!0                      = "lev"
   data&lev                    = p
   data@units                  = "~F34~0~F21~C"
   u!0                         = "lev"
   u&lev                       = p
   w!0                         = "lev"
   w&lev                       = p
;  SET UP RESOURCES
   cres                        = True
   cres@cnFillOn               = True
;  TURN OFF CONTOUR LINES
   cres@cnLinesOn              = False
;  TURN OFF CONTOUR LABELS
   cres@cnLineLabelsOn         = False
   cres@gsnSpreadColors        = True
   cres@tmXBMajorLengthF       = 0.005
   cres@tmYRMajorLengthF       = 0.005
   cres@tmYLMajorLengthF       = 0.005
   cres@tmYRMinorLengthF       = 0.002
   cres@tmYLMinorLengthF       = 0.002

;  SET UP LABEL BAR
   cres@pmLabelBarWidthF       = 0.1
   cres@pmLabelBarHeightF      = 0.5
   cres@lbLabelFontHeightF     = 0.02
   cres@lbLabelStride          = 40
   cres@lbBoxLinesOn           = False
   cres@lbOrientation          = "Vertical"
   cres@lbLabelPosition        = "Right"
   cres@lbTitleString          = data@units
   
;  SET UP THE POSITION OF THE CONTOUR PLOT
   cres@vpWidthF               = 0.6
   cres@vpHeightF              = 0.45
   cres@vpXF                   = 0.2
   cres@vpYF                   = 0.8
   cres@gsnDraw                = False
   cres@gsnFrame               = False

;  SET UP AXIS LABEL FOR CONTOUR PLOT OF WRFCHEM
   cresn                       = True
   cresn                       = cres
   stride                      = floattoint(in/npts)+2
   cresn@tmXBMode              = "Explicit"
   cresn@tmXBValues            = fspan(0.,(in-1),npts)
   cresn@tmXBLabels            = sprintf("%5.2f", (lon(0:(in-1):stride)))
   cresn@cnLevelSelectionMode  = "ManualLevels"
   cresn@cnMinLevelValF        = -30
   cresn@cnMaxLevelValF        = 20
   cresn@cnLevelSpacingF       = 0.25
   cresn@tiXAxisString         = "Longitude"
;  cresn@tiXAxisString         = "Latitude"
   cresn@tiYAxisString         = "Altitude (hPa)"
   cresn@tiMainString          = "NCEP FNL Dew Point Temperature " + stime

;  SET UP VECTOR RESOURCES
   cresvn                          = True
   cresvn                          = cresn
   cresvn@vcRefMagnitudeF          = 10.0
   cresvn@vcRefLengthF             = 0.05
   cresvn@vcRefAnnoParallelPosF    = 0.188
   cresvn@vcRefAnnoOrthogonalPosF  = -1.07
   cresvn@vcRefAnnoArrowLineColor  = "black"
   cresvn@vcRefAnnoArrowUseVecColor= False
   cresvn@vcGlyphStyle             = "LineArrow"
   cresvn@vcLineArrowColor         = "white"
   cresvn@vcLineArrowThicknessF    = 1.5
   cresvn@vcVectorDrawOrder        = "PostDraw"
   cresvn@vcMinDistanceF           = 0.04
   cresvn@vcMapDirection           = False
   plot = gsn_csm_pres_hgt_vector(wks, data({1000:100}, :), u({1000:100}, :), w({1000:100}, :), cresvn)

   draw(plot)

return
end
