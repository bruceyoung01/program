;  $ID plot_histogram_terra_aqua_cot_ctp_hist_aca_diff.ncl V01 05/19/2015 10:12 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot_histogram_terra_aqua_cot_ctp_hist_aca_diff PLOTS 2-D HISTOGRAM 
;  WITH UNEQUAL BINS FOR X AND Y AXISES. THIS PROGRAM IS REFERRED FROM 
;  raster_6.ncl FROM 
;  NCL WEBSITE (http://www.ncl.ucar.edu/Applications/Scripts/raster_6.ncl)
;   - Generating dummy data which have irregular X and Y coordinates
;   - Drawing raster contours 
;   - Forcing full-sized raster cells at the X,Y axis boundaries
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY NCL WEBSITE. MODIFIED BY BRUCE. (05/19/2015)
;******************************************************************************

undef("plot_histogram_terra_aqua_cot_ctp_hist_aca_diff")
procedure plot_histogram_terra_aqua_cot_ctp_hist_aca_diff \
          (wks          :graphic,                     \ ;INPUT
           xbnd         :float,     ybnd      :float, \ ;INPUT
           data         :integer,   times     :string)  ;INPUT

begin
  nxbnd = dimsizes(xbnd)                              ; # of x bin boundaries   
  nybnd = dimsizes(ybnd)                              ; # of y bin boundaries 

  nx    = nxbnd
  ny    = nybnd

;=================================================;
; PLOT
;=================================================;

  res                      = True
  res@gsnMaximize          = True
  res@gsnSpreadColors      = True

  res@cnFillOn             = True
  res@cnFillMode           = "RasterFill"
  res@cnMissingValFillColor= "White"
  res@cnLinesOn            = False
  res@cnLineLabelsOn       = False

  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       =  -100
  res@cnMaxLevelValF       =  100
  res@cnLevelSpacingF      =  1

  res@trYReverse           = True

  res@lbLabelBarOn         = True
  res@lbOrientation        = "vertical"
  res@lbLabelStride        = 20
  res@lbLabelFontThicknessF= 0.3
  res@lbBoxLinesOn         = False
; res@lbTitleString        = "Terra_cot_ctp_hist"
; res@lbTitlePosition      = "Right"

  res@trXMinF              = -0.5
  res@trXMaxF              =  nx-0.5
  res@trYMinF              = -0.5
  res@trYMaxF              =  ny-0.5

  res@tmXBMode             = "Explicit"
  res@tmXBValues           = fspan(res@trXMinF,res@trXMaxF, nxbnd) 
  res@tmXBLabels           = xbnd           
  res@sfXArray             = res@tmXBValues    

  res@tmYLMode             = "Explicit"
  res@tmYLValues           = fspan(res@trYMinF,res@trYMaxF, nybnd) 
  res@tmYLLabels           = ybnd          
  res@sfYArray             = res@tmYLValues

  res@tiXAxisString        = "COT"
  res@tiYAxisString        = "CTP [hPa]"

  res@tiMainString         = times + " cot_ctp_hist" + " ACA" + " Aqua(13:30)-Terra(10:30)"
  plot = gsn_csm_contour(wks,data,res)

return
end
