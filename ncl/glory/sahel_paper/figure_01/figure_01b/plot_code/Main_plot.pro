; $ID: plot_flambe_emission.pro V01 02/21/2012 15:18 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot_flambe_emission PLOTS FLAMBE EMISSION WITH COUNTRIES INFO AND 
;  AERONET SITES.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) MODIFIED FROM CUI'S CODE BY BRUCE. (02/21/2012)
;******************************************************************************


set_plot, 'PS'
device, file='Study_area_v03.ps', xsize = 7, ysize= 10, $
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
tvlct, r, g, b

region_limit = [-15,  -25,   35,   45]
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

xyouts, lons-1.6, intarr(dlonN+1)+LatT+1.2, '!6'+lonnames+'E' ,/data, color=16
xyouts, intarr(dlatN+1)+LonL-8.9, lats(0:2)-0.2, latnames(0:2)+'S' , /data, color=16
xyouts, intarr(dlatN+1)+LonL-6.5, lats(3)-0.2, latnames(3), /data, color=16
xyouts, intarr(dlatN+1)+LonL-7.5, lats(4:10)-0.2, latnames(4:10)+'N' , /data, color=16

plot_smoke_emission

  MYCT, 33, /BRIGHT_COLORS
; PLOT THE NEST DOMAIN
  glat = [-10, -10, 15, 15,  15, -10]  
  glon = [-20,  40, 40, 40, -20, -20] 
  oplot, glon, glat, linestyle=2, thick=10, color=4

; PLOT COUNTRY NAME
  sitename = ['Mauritania', 'Mali', 'Niger', 'CAR',   $
              'Chad', 'Sudan', 'Ethiopia', 'Cameroon',$
	      'DR_Congo', 'Kenya', 'Nigeria' ]

  lon = [-10.49, -1.95, 9.61, 19.52, 18.7, $
         29.01, 39.05, 9.03, 23.00, 37.23, 9.15]

  lat = [19.75, 17.55, 17.32, 6.39, 15.28, $
         14.25, 8.05, 4.27, -3.09, 0.35, 8.58]
  dim  = SIZE(sitename)
  ndim = dim(1)
 for i = 0, ndim-1 do begin
  xyouts, lon(i), lat(i)-0.5, sitename(i), $
          color=2, charsize=1.2, charthick=3, align=0.5 
 endfor
 oplot, [-10, -17], [10, 8], color = 1
 xyouts, -20, 7, 'Guinea', $
         color=2, charsize=1.2, charthick=3, align=0.5
 oplot, [-6, -13], [7, 3], color = 1
 xyouts, -15, 2, 'Cote dlvoire', $
         color=2, charsize=1.2, charthick=3, align=0.5
 oplot, [-1, -1], [7, 0], color = 1
 xyouts, -1, 0, 'Ghana', $
         color=2, charsize=1.2, charthick=3, align=0.5

; PLOT AERONET SITES
 alon = [-1.479117, 2.664750, -22.935499,  $
         40.194500, -16.958611, 12.023067, $
         29.502500, 34.200000, -5.933867,  $
         4.340000, -16.499060,             $
         -16.321111, 36.865300, 34.789167, $
         -23.484000, -8.155830, -16.247361,$
         34.782222, 46.397286, 5.530000]
 alat = [15.345400, 13.541167, 16.732500, $
         -2.996000, 14.394167, 13.216717, $
         29.502500, -0.416700, 13.278433, $
         8.320000, 28.309320,             $
         28.481944, -1.338882, 31.922500, $
         14.947000, 31.625830, 28.472528, $
         30.855000, 24.906933, 22.790000]
 FOR j = 0, 17 DO BEGIN
  IF (j EQ 7)  THEN BEGIN
   PLOTS, alon(j), alat(j), psym=sym(1), symsize=2, color=3
   XYOUTS, 36, -3, 'ICIPE_Mbita', $
           color = 3, charsize = 1.2, charthick = 3, align = 0.5
  ENDIF ELSE IF (j EQ 9)  THEN BEGIN
   PLOTS, alon(j), alat(j), psym=sym(1), symsize=2, color=3
   XYOUTS, 4, 6, 'Ilorin', $
           color = 3, charsize = 1.2, charthick = 3, align = 0.5
  ENDIF ELSE IF (j EQ 14) THEN BEGIN
   PLOTS, alon(j), alat(j), psym=sym(1), symsize=2, color=3
   XYOUTS, -22, 13, 'Praia', $
           color = 3, charsize = 1.2, charthick = 3, align = 0.5
  ENDIF ELSE BEGIN
   PLOTS, alon(j), alat(j), psym=sym(1), symsize=1.2, color=3
  ENDELSE
 ENDFOR

; PLOT MAP
map_set,   0, 0,  /continent, $
  limit = [-15, -25, 35, 45], e_cont = {countries:1, coasts:1},$
/mer,/noerase, position = [0.1, 0.25, 0.9, 0.8], color=1
map_grid,  lats = lats, latnames = latnames, $
londel = dlon, latlab = LonL, lonlab = 0, /noerase, $
latalign=1.5, lonalign=1, lons = lons,lonnames = lonnames,$
position = [0.0775, 0.3075, 0.9035, 0.8725], thick=3, color=1

xa = 0.92
dx = 0.02
ya = 0.70
dy = 0.04

device, /close 

end
