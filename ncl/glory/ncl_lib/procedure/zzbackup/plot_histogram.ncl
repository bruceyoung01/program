; $ID: plot_histogram.ncl V01 01/18/2012 11:00 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_histogram IS SUED TO PLOT VERTICAL HISTOGRAM.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) data      (float)  : 1-D ARRAY TO BE PLOT HISTOGRAM               [---]
;  (2 ) xlabel    (string) : X AXIS LABEL                                 [---]
;  (3 ) plot      (graphic): OUTPUT PLOT                                  [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/18/2012)
;******************************************************************************

undef("plot_histogram")
procedure plot_histogram(data     :float, \ ; INPUT (1-DIMENSION)
                         xlabel   :string,\ ; INPUT (1-DIMENSION)
                         plot     :graphic) ; OUTPUT

begin

;  DETERMINE # OF ELEMENTS
   npts = dimsizes(data)
;  SET UP HISTOGRAM SOURCES
   bres                       = True
   bres@gsnDraw               = True
   bres@gsnFrame              = True
   bres@gsnXYBarChart         = True
   bres@gsnXYBarChartBarWidth = 0.3
   bres@trXMinF               = 0.0
   bres@trXMaxF               = 8
   bres@trYMinF               = 0.1
   bres@trYMaxF               = 110
   bres@trYAxisType           = "LogAxis"
   bres@tiXAxisString         = "Category"
   bres@tiYAxisString         = "Frequency(%)"
   bres@tiMainString          = "2008 Frequency"
   bres@tmXBMode              = "Explicit"
   bres@tmXBValues            = ispan(1, npts, 1)
   bres@tmXBLabels            = xlabel
   bres@tmXBMajorThicknessF   = 0.5
   bres@tmYLMajorThicknessF   = 0.5
   bres@gsnXYBarChartColors   = (/"black"/)
   bres@gsnXYBarChartPatterns = 6
; SET INITIAL WIDTH AND HEIGHT
   bres@vpHeightF             = 0.4
   bres@vpWidthF              = 0.8
   bres@vpXF                  = 0.15
   bres@vpYF                  = 0.7
   plot = gsn_csm_xy(wks, fspan(0.98, npts-0.02, npts), data, bres)
return
end
