;  $ID: plot_contour_pres_hgt_vector_pl.ncl V01 08/09/2015 20:39 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_contour_pres_hgt_vector_pl.ncl PLOTS VERTICAL CONTOUR ALONG 
;  PRESSURE AND HEIGHT, WITH PLANETARY BOUNDARY LAYER HEIGHT.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/09/2015)
;******************************************************************************
undef("plot_contour_pres_hgt_vector_pl")
procedure plot_contour_pres_hgt_vector_pl \
          (wks      :graphic,      stime    :string, \;INPUT
           in       :integer,      npts     :integer,\;INPUT
           p        :numeric,      hpbl     :numeric,\;INPUT
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
   cresn@cnMinLevelValF        = -50
   cresn@cnMaxLevelValF        = 50
   cresn@cnLevelSpacingF       = 0.5
;  cresn@tiXAxisString         = "Longitude"
   cresn@tiXAxisString         = "Latitude"
   cresn@tiYAxisString         = "Pressure (hPa)"
   cresn@tiMainString          = "NCEP FNL  " + stime

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
   plot = gsn_csm_pres_hgt_vector(wks, data({1000:10}, :), u({1000:10}, :), w({1000:10}, :), cresvn)

;  ADD POLYLINE TO THE CONTOUR PLOT
   plres                  = True
   plres@gsLineColor      = "maroon1"
   plres@gsLineThicknessF = 10.0
   if (.not.all(ismissing(hpbl))) then
      dum = gsn_add_polyline(wks, plot, lon, hpbl, plres)
   end if

   draw(plot)

return
end
