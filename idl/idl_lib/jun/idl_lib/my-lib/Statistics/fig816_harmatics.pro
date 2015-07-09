

 ; monthly average temperature in 1990 and 1991. 
 T = [18.1, 37.6, 44.2, 54.6, 66.6, 76.6, $
      78.1, 76.2, 67.6, 52.9, 31.7, 33.6, $
      33.8, 31.7, 42.7, 51.1, 59.5, 75.3, $
      76.5, 76.7, 70.5, 55.0, 44.7, 23.4]

 ; array of month       
 n = 24
 m = findgen(n) + 1
 meanT = mean(T)

 ; find A and B using equation 8.64
 n = 24

 ; arry A & B (only need half of n eq. 8.62)
 A = fltarr(n/2)  
 B = fltarr(n/2)
 for k = 1, n/2 do begin
   ; not array index starting from 0., so k-1
  A(k-1) = 2./n * total(T * cos(2*!pi*k * m / n))
  B(k-1) = 2./n * total(T * sin(2*!pi*k * m / n))
 endfor   

 ; compute the forecasted value
 y = fltarr(n)
 for i = 1, n do begin
  for k = 1, n/2 do begin
    y(i-1) = y(i-1) + A(k-1)*cos(!pi * 2 * k * i/n) + $
                B(k-1)*sin(!pi * 2 * k * i/n) 
  endfor
  y(i-1) = y(i-1) + meanT 
 endfor

 ; compute the normalized spectral density
  CK = sqrt(A^2 + B^2)  ; eq. 8.65a
  result = moment(y)
  sysquare  = result(1) 
  normI = n * Ck^2 / (2*(n-1)*sysquare) 

 Device, Decomposed=0
 set_plot, 'x'
 !p.background = 255
 !p.charsize=2
 window, 1 
 plot,[0.5, 13.5], [20, 90], xtitle = 'months from Jan 1991', $
       ytitle = 'T (F)', color=0, xrange = [0.5, 24.5], $
       yrange = [10, 90], xstyle=1, ystyle=1, /nodata, $
       title='Montly T in Lincoln, NE in 1991 - 1991'
 plots, m, t, psym = 4, color=0, symsize=2
 oplot, m,  y, color=0
 img = tvrd()
 write_png, 'Lincoln_T_Fig816a_T.png', img
 
 window, 2 
; plot,[0.5, 13.5], [20, 90], xtitle = 'months from Jan 1991', $
;       ytitle = 'T (F)', color=0, xrange = [0.5, 13.5], $
;       yrange = [0.0001, 1], xstyle=1, ystyle=1, /nodata, $
;       title='Montly T in Lincoln, NE in 1991 - 1991', /ylog 
 !Y.RANGE = [0.001, 1]
 print, !y.type
 !p.color=0
 bar_plot, normI, background=255, $
      ytitle = 'Normalized spectral density', /outline, $
      colors = fltarr(n/2)+155, barnames = $
      string(n/(findgen(n/2)+1), format='(f4.1)'), $
      xtitle = 'Period of Harmotic (mon)' 
  
 img = tvrd()
 write_png, 'Lincoln_T_Fig816a_spectral_intensity.png', img

end
