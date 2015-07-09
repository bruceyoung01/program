; $ID: plot_merge_wrf_calipso.ncl V01 02/09/2012 11:16 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_merge_wrf_calipso IS TO MERGE PLOT OF WRF AND CALIPSO.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks    (graphic): WORK STATION                                   [---]
;  (2 ) plot1  (graphic): CALIPSO PLOT                                   [---]
;  (3 ) plot2  (graphic): PM2.5 VERTICAL CONTOUR PLOT                    [---]
;  (4 ) plot3  (graphic): TEMPERATURE VERTICAL CONTOUR PLOT              [---]
;  (5 ) mpplot (graphic): MAP OVERLAID WITH CALIPSO GROUND TRACK         [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/09/2012)
;******************************************************************************

undef("plot_merge_wrf_calipso")
procedure plot_merge_wrf_calipso(wks     :graphic, plot1   :graphic, \ ; INPUT
                                 plot2   :graphic, plot3   :graphic, \ ; INPUT
                                 mpplot  :graphic)                     ; INPUT


begin

; MERGE WRF AND CALIPSO PLOTS INTO ONE PANEL
  plot    = new(3, graphic)
  plot    = (/plot1, plot2, plot3/)
  pres                       = True
  pres@gsnMaximize           = True
  pres@gsnFrame              = False
  pres@gsnDraw               = False
  pplots  = gsn_panel_return(wks, plot, (/3,1/), pres)
  bb      = NhlGetBB(pplots)
  pheight = 0.3
  pres@gsnDraw               = True
  pres@gsnPanelTop           = 0.95
  pres@gsnPanelBottom        = pres@gsnPanelTop-pheight
  colormaps = (/"BlAqGrYeOrReVi200", "BlAqGrYeOrReVi200", "GaAqGrYeOrReVi200"/)
  do iplot = 0, 2
   gsn_define_colormap(wks, colormaps(iplot))
   gsn_panel(wks, plot(iplot), (/1,1/), pres)
   pres@gsnPanelTop          = pres@gsnPanelBottom
   pres@gsnPanelBottom       = pres@gsnPanelTop-pheight
  end do
; SET UP TEXT RESOURCES
  tres                       = True
  tres@txPerimOn             = False
  tres@txFontHeightF         = 0.006 
  tres@txBackgroundFillColor = 0
  tres@gsnframe              = True
  gsn_text_ndc(wks," Cloud ", 0.705, 0.105, tres)
  draw(mpplot)
  frame(wks)
  delete([/pplots, pres, tres/])

return
end
