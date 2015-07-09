

 ; 10-year (1990-1999) average of temperature in each month in Lincoln, NE:
 T = [23.61, 31.54, 39.39, 49.93, 61.28, 72.08, 76.37, 74.51, $
      65.96, 53.54, 37.93, 28.56, 51.24] 
 m = findgen(12) + 1
 meanT = mean(T)
 
 Device, Decomposed=0
 set_plot, 'x'
 !p.background = 255
 !p.charsize=2
 
 plot,[0.5, 13.5], [20, 80], xtitle = 'mon', $
       ytitle = 'T (F)', color=0, xrange = [0.5, 13.5], $
       yrange = [20, 80], xstyle=1, ystyle=1, /nodata, $
       title='Average montly T for Lincoln, NE in 1990 - 1999'
 plots, m, t, psym = 4, color=0, symsize=2
; oplot, m, meanT + meanT/2. * cos(!pi * 2 / 12. * m), linestyle=2, color=0
; oplot, m, meanT + meanT/2. * cos(!pi * 2 / 12. * m - 7*!pi/6), color=0
 img = tvrd()
 write_png, 'Lincoln_T_Fig813.png', img
 end
