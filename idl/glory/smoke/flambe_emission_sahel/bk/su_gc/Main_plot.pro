
set_plot, 'PS'
device, file='Study_area.ps', xsize = 7, ysize= 10, $
    xoffset = 0.5, yoffset = 0.5, /inches, /color, bits=8
 
!p.thick = 3
!p.charsize=1.2
!p.charthick=2
!p.multi = [0, 1, 2] 
r=bytarr(64) & g = r & b =r
 r(0:63)=[255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0,0,0,$
           0,0,0,0,0,7,15,23,31,38,46,54,62,86,110,134,158,182,206,$
           230,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,$
       255,255,255,255,255,255,255,255,255,255]

      g(0:63)=[255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0,0,0,$
           0,0,0,0,0,28,56,84,112,140,168,196,224,227,231,235,239,243,247,$
           251,255,249,243,237,232,226,220,214,209,182,156,130,104,78,52,$
           26,0,0,0,0,0,0,0,0,0]

      b(0:63)=[255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0,36,$
           72,109, 130, 150, 218,255,223,191,159,127,95,63,31,0,0,0,0,0,0,0,$
           0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,31,63,95,127,159,191,223,255]

r(0:16) = [255,240,230,160,145,135,120,110,95,85,68,51,38,28,17,0,0]
g = r
b = r
;g(0:16) = [255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0]
;b(0:16) = [255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0]

tvlct, r, g, b

region_limit = [-35,  70,   55,   155]
LonL = region_limit(1)
LonR = region_limit(3) 
LatB = region_limit(0)
LatT = region_limit(2)
dLat = 5
dLatN = (LatT-LatB)/dLat 
dLon = 10 
dLonN = (LonR-LonL)/dLon 

;this map is for plot emission
map_set,   0, 0,  /continent, $
  limit = region_limit,  /usa, $
/mer,/noerase, position = [0.1, 0.25, 0.9, 0.8], color=16

lats = findgen(dLatN+1)*dLat+LatB  
lons = findgen(dLonN+1)*dLon+LonL
latnames = strtrim(fix(lats), 2)
lonnames= strtrim(fix(lons), 2)

;map_grid, label = 1, lats = lats, latnames = latnames, $
;londel = dlon, latlab = LonL, lonlab = 0, /noerase, $
;latalign=1.5, lonalign=1, lons = lons,lonnames = lonnames,$
;position = [0.0775, 0.3075, 0.9035, 0.8725], thick=3, color=16
;position = [0.1, 0.25, 0.9, 0.8], thick=3
;position = [0.0775, 0.3075, 0.9035, 0.8725], thick=3

xyouts, lons-1.6, intarr(dlonN+1)+LatT+1.2, '!6'+lonnames+'E' ,/data, color=16
;xyouts, lons-1.6, intarr(dlonN+1)+LatB-1.8, '!6'+lonnames+'W' ,/data, color=16
;xyouts,  intarr(dlatN+1)+LonL-3.8,  lats, latnames+'N' , /data, color=16
xyouts,  intarr(dlatN+1)+LonL-8.9,  lats-0.2, latnames(0:5)+'S' , /data, color=16
xyouts,  intarr(dlatN+1)+LonL-7.5,  lats(6)-0.2, latnames(6)+'S' , /data, color=16
xyouts,  intarr(dlatN+1)+LonL-6.5,  lats(7)-0.2, latnames(7), /data, color=16
xyouts,  intarr(dlatN+1)+LonL-6.5,  lats(8)-0.2, latnames(8)+'N' , /data, color=16
print,'latnames',latnames
xyouts,  intarr(dlatN+1)+LonL-7.1,  lats(9:18)-0.2, latnames(9:18)+'N' , /data, color=16

plot_smoke_emission

;tvlct, rr, gg, bb
;plot grid 2
  glat = [   -10, -10,   23,  23,   -10]  
  glon = [    95, 130,  130,  95,    95] 
  oplot, glon, glat, linestyle=2, thick=2, color=16

; plot s puteurico, first 7 is AERONET, and next
; 13 are improve website

  sitename = ['Bandung', 'Singapore', 'Songkhla_Met_Sta', $
              'Bac_Lieu', 'Silpakorn_Univ', $
	      'Manila_Observatory', 'Bac_Giang' ]        ; start improve

  lon = [107, 103, 100, 105, $
         100, 121,  106]	

  lat = [-6, 1, 7, 9, $
         13, 14, 21]
;  site=['1','2','3','4',$
;       '5','6','7']
;xyouts, lon, lat, sitename, aeronet site, no aeronet
;  plots, lon(0:6), lat(0:6), psym=sym(6), color=16,symsize =3,thick=10 

    for i = 0, 6 do begin
  plots, lon(i), lat(i), psym=sym(6), symsize = 2.8, color=16
  xyouts, lon(i), lat(i)-0.5, string(i+1, format='(i1)'), $
           color=16, charsize=1.5, charthick=2, align=0.5 
   endfor

;  xyouts, lon(0:6), lat(0:6)-0.45, string(i+1, format='(i1)'), $
;           color=16, charsize=1.5, charthick=5, align=0.5 

;  plots, lon(3:6), lat(3:6), psym=sym(5), color=4,symsize = 1.5
;  plots, lon(2), lat(2), psym=sym(5), color=16, symsize=2
;  plots, lon(7:17), lat(7:17), psym=sym(1), symsize = 1.8, color=1
;  plots, lon(7:15), lat(7:15), psym=sym(1), symsize = 1.8, color=16

;region_limit = [-35,  70,   55,   155]
;plot_epa_station, region_limit(1), region_limit(0), $
;                   region_limit(3), region_limit(2)

map_set,   0, 0,  /continent, $
  limit = [-35, 70, 55, 150],  /usa, $
/mer,/noerase, position = [0.1, 0.25, 0.9, 0.8], color=16
map_grid,  lats = lats, latnames = latnames, $
londel = dlon, latlab = LonL, lonlab = 0, /noerase, $
latalign=1.5, lonalign=1, lons = lons,lonnames = lonnames,$
position = [0.0775, 0.3075, 0.9035, 0.8725], thick=3, color=16,$
;;concolor=16

;map_grid, label = 1, lats = lats, latnames = latnames, $
;londel = dlon, latlab = LonL, lonlab = 0, /noerase, $
;latalign=1.5, lonalign=1, lons = lons,lonnames = lonnames,$
;position = [0.0775, 0.3075, 0.9035, 0.8725], thick=3, color=16
;position = [0.1, 0.25, 0.9, 0.8], thick=3,color=16
;position = [0.0775, 0.3075, 0.9035, 0.8725], thick=3

;  plots, lon(7:15), lat(7:15), psym=sym(1), symsize = 1.8, color=16
  
;  for i = 0, 6 do begin
;  plots, lon(i), lat(i), psym=sym(1, 3), symsize = 2.8, color=0
;  plots, lon(i), lat(i), psym=sym(6, 3), symsize = 2.8, color=16
;  xyouts, lon(i), lat(i)-0.45, string(i+1, format='(i1)'), $
;           color=16, charsize=1.5, charthick=5, align=0.5 
;   endfor

; legends
;  plots, [0.90, 1.12 , 1.12, 0.90], $ 
;         [0.3075, 0.3075, 0.858, 0.858]-0.058, $
;	 color=16, /normal, thick=3
  xa = 0.92
  dx = 0.02
  ya = 0.70
  dy = 0.04
;  for i = 0, 6 do begin
;   plots, xa, ya-i*dy, psym = sym(1,3), symsize = 2.8, color=0, /normal
;   plots, xa, ya-i*dy, psym = sym(6,3), symsize = 2.8, color=16, /normal
;   xyouts, xa, ya-i*dy, '!6' + string(i+1, format = '(i1)') + '. ' + sitename(i), $
;           charsize = 1.4, color=16, /normal, charthick=2
; endfor 
    i=6   
;   plots, xa+dx/2, ya-i*dy, psym = sym(6), symsize=3, color=16,/normal, thick=16 
;   xyouts, xa+2*dx, ya-i*dy-0.005, 'ARM SGP', /normal , $
;          color=16, charthick=2,   charsize=1.4
  

device, /close 

end
