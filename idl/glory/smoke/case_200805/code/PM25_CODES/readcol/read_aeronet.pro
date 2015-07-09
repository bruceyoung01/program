@~/idl_lib/myclrtable.pro
@~/idl_lib/ps_color.pro
@~/idl_lib/sym.pro
@~/idl_lib/set_legend_diff.pro

  ; plot mapping
  ps_color, filename = 'AOT_watervapor.ps'
  myclrtable, red = red, green=green, blue=blue
  
  ; color used for difference
  n_levels = 12
  barvalue = fltarr(n_levels+2)
  barvalue = [-1.0, -0.9, -0.74, -0.58, -0.42, -0.26, -0.1, $
                  0.0,  0.1, $
                 0.26, 0.42, 0.58, 0.74, 0.9, 1.0]  

  colors = [ 0,   4,   7,  11, 14,  17,  20, -16, -16, 25,  30,  32, 35, 38, 42, 45]+16
  ccolors = colors(1:n_levels+2)
  tvlct, red, green, blue  
  
  ; plot global map
  map_set,   0, 0,  /continent, $
    color=16,  $
   /mer,/noerase, position = [0.1, 0.25, 0.9, 0.8]
  map_continents, /countries, /coasts, /continents, color=16

; legend coordinate     
      xa = 0.125       &   ya = 0.9
      dx = 0.05      &   dy = 0.00
      ddx = 0.0      &   ddy = 0.015 
      dddx = 0.05    &   dddy = -0.035
      dirinx = 0     &   extrachar=' '
barticks = barvalue(1:n_levels+1)
set_legend_diff, barticks, n_levels , ccolors, $
                xa, dx, ddx, dddx, $
                ya, dy, ddy, dddy, dirinx, extrachar
  
; infile name
  filedir = '/data/AERONET/AOT/all_processed/' 
  infile = 'aeronet_sitename.txt'
  readcol, infile, sitename, lon, lat, elv, $
           format = 'A, F, F, F'
  nf = n_elements(sitename)

  ; start to calculate correlation
  nouse = ' '
  oneline= fltarr(29)
for i = 0, nf-1 do begin
  A = fltarr(29, 120000L)
  k = 0L
  filename =  filedir + 'hour_920801_080218_'+sitename(i)+'.lev20'
  if (file_test(filename)) then begin  
  openr, 1, filename 
  readf, 1, nouse
  while(not eof (1) ) do begin
  readf, 1, oneline 
  A(*, k) = oneline(*)
  k = k + 1L
  endwhile
  close, 1

  AOT = reform(A(9,*))
  WATER = reform(A(22, *))
  ANG = reform(A(26, *))

  ;result = where (AOT gt 0 and WATER GT 0 and ANG ne -99.0, count)
  result = where (AOT gt 0 and WATER GT 0 , count)
  if ( count gt 2 ) then begin
;  corr = correlate( AOT(result)*ANG(result), WATER(result)) 
  corr = correlate( AOT(result), WATER(result)) 
  result = where(barvalue gt corr)
  clrinx = result(0)-1.0
  print, sitename(i),  count, corr
  plots, lon(i), lat(i), psym = sym(1), color = ccolors(clrinx)
  
  if (corr gt -0.1 and corr le 0.1 ) then $
   plots, lon(i), lat(i), psym = sym(6), color=16

  endif
  endif
endfor

device, /close
  END

    
