

 ; 10-year (1990-1999) average of temperature in each month in Lincoln, NE:
 T = [23.61, 31.54, 39.39, 49.93, 61.28, 72.08, 76.37, 74.51, $
      65.96, 53.54, 37.93, 28.56] 
 m = findgen(12) + 1
 meanT = mean(T)

 ; find A1 and B1 using equation 8.60
 n = 12
 A1 = 2/12. * total(T * cos(!pi * 2 * m / n))
 B1 = 2/12. * total(T * sin(!pi * 2 * m / n))

; if (A1 eq 0 ) then begin
;  ph1 = !pi/2.
; endif else begin
;  if (A1 gt 0 ) then ph1 = atan(B1/A1)
;  if (A1 lt 0 ) then ph1 = atan(B1/A1) + !pi
; endelse

 ; using least-squares regresssion
 termA = cos(!pi * 2 * m / n)  ; equation 8.57
 termB = sin(!pi * 2 * m / n) 
 X = transpose([[termA], [termB]]) 
 result = regress(X, T)
 A1R = result(0)
 B1R = result(1) 
 
 
 Device, Decomposed=0
 set_plot, 'x'
 !p.background = 255
 !p.charsize=2
 
 plot,[0.5, 13.5], [20, 80], xtitle = 'mon', $
       ytitle = 'T (F)', color=0, xrange = [0.5, 13.5], $
       yrange = [20, 80], xstyle=1, ystyle=1, /nodata, $
       title='Average montly T for Lincoln, NE in 1990 - 1999'
 plots, m, t, psym = 4, color=0, symsize=2
 oplot, m,  meanT+ A1*cos(!pi * 2 * m / n)+B1*sin(!pi * 2 * m / n), linestyle=2, color=0
 oplot, m,  meanT+ A1R*cos(!pi * 2 * m / n)+B1R*sin(!pi * 2 * m / n), color=0

; oplot, m, meanT + meanT/2. * cos(!pi * 2 / 12. * m), linestyle=4, color=0
 oplot, m, meanT + meanT/2. * cos(!pi * 2 / 12. * m - 7*!pi/6), linestyle=3, color=0
 img = tvrd()
 write_png, 'Lincoln_T_Fig813_regression.png', img
 end
