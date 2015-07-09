; plot china map.
pro plot_china, colorinx, fillinx
 maxnl = 5000
 lat = fltarr(maxnl)
 lon = fltarr(maxnl)
 numstate = 0
 tmp = fltarr(2, maxnl)

 openr, 1, '~/idl_lib/my-lib/xxa.bln.txt'
 while ( not eof (1) ) do begin
   readf, 1, numline
;   print, 'numline = ', numline
   tmp = fltarr(2, numline)
   readf, 1, tmp
   lat(0:numline-1) = tmp(1, 0:numline-1)
   lon(0:numline-1) = tmp(0, 0:numline-1)
   plots, lon(0:numline-1), lat(0:numline-1), Color = colorinx, thick=3
;   print, 'province', numstate
   numstate = numstate+1
 endwhile

 close, 1
 end

