;
; map plot
;

pro map_plot, region = region, dlat = dlat, dlon=dlon, noerase = noerase
 LonL = region(1)
 LonR = region(3)
 LatB = region(0)
 LatT = region(2)
 dLatN = (LatT-LatB)/dLat
 dLonN = (LonR-LonL)/dLon

 position = [0.1, 0.25, 0.9, 0.8]
 position1 = [0.0775, 0.3075, 0.9035, 0.8725]

if (keyword_set(noerase) )then $
map_set,   0, 0,  /continent, $
 limit = region,  /usa, $
 /mer, position = position, /noerase

if (not keyword_set(noerase) )then $
map_set,   0, 0,  /continent, $
 limit = region,  /usa, $
 /mer, position = position

 lats = findgen(dLatN+1)*dLat+LatB
lons = findgen(dLonN+1)*dLon+LonL
latnames = strtrim(fix(lats), 2)
lonnames= strtrim(fix(-1*lons), 2)

map_grid, label = 1, lats = lats, latnames = latnames, $
londel = dlon, latlab = LonL, lonlab = 0, /noerase, $
latalign=1.5, lonalign=1, lons = lons,lonnames = lonnames,$
position = position1, thick=3, /noborder

xyouts, lons-1.6, intarr(dlonN+1)+LatB-1.8, '!6-'+lonnames ,/data
xyouts,  intarr(dlatN+1)+LonL-2.8,  lats, latnames , /data 
;xyouts, (lonL+LonR)/2, LatB-3.8,  'Longitude (deg)', /data, color=0, align=0.5
;xyouts,  LonL-4.8,  (LatB+LATT)/2, 'Latitude (deg)' , /data, color=0, orientation = 90, align=0.5

;xyouts, (lonL+LonR)/2, LatB-3.8,  'Longitude (deg)', /data, color=0, align=0.5
;xyouts,  LonL-4.8,  (LatB+LATT)/2, 'Latitude (deg)' , /data, color=0, orientation = 90, align=0.5

END

;
; Main Code starts here

region_limit = [10,  -115,   45,   -65]
LonL = region_limit(1)
LonR = region_limit(3)
LatB = region_limit(0)
LatT = region_limit(2)
dLat =0.5 
dLatN = (LatT-LatB)/dLat
dLon = 0.5
dLonN = (LonR-LonL)/dLon

; set color ps
ps_color, filename = 'fire_emission.ps'
myclrtable, red=red, green=green, blue=blue, colors= colors
tvlct, red(colors), green(colors), blue(colors)
n_level = n_elements(colors)-4
map_plot, region = region_limit, dlat = 5, dlon=10.

;
;read NOAA emissions
; 
np = 83 
dir = '/data/NOAAFIRE/'
filenames = 'filename_list.txt'
readcol, dir+filenames, filelist, format='A'

for nf = 0, n_elements(filelist)-2 do begin
emisgrid = fltarr(dLonN, dLatN)

file = filelist(nf) 

readcol, dir+file, lat, format='f'
nl = n_elements(lat)
ems = fltarr(np, nl)
openr, 1, dir+file
readf, 1, ems
close,1
lon = reform(ems(0, *))
lat = reform(ems(1, *))
yr  = reform(ems(2, *))
doy = reform(ems(3, *))

; NEED TO MAKE SURE the data is read correctly
; follow the format XYZ emailed us.
; The column in an actual product file may be shorter than 
; the one listed in the form. In
; this case, ignore the extra columns in the format form.
; Not that, the use the PM2.5 in column 56.
; 0-3,   longitude, latitude, Year, DOY
;  4-52,  half_hourly_fire_size(48 values), total_burned_area(km)
;   53,    GOES_FIRE_ECOSYSTEM_ID 
; 54-55, PM2.5 -- NFDRS_GOES_emission, NFDRS_GOES_VCI_emission 
; 56-57, PM2.5 -- MODIS_GOES_VCI_emission, FCCS_GOES_VCI_emission
; 58-59, PM2.5 -- MODIS_GOES_emission, FCCS_GOES_emission
; 60-61, NFDRS_fuel_model, FCCS_fuel_model
; 62-63, MODIS_LC, US_state_id
; 64-69, CO emission--NFDRS, MODIS, and FCCS fuels 
; 70-75, CH4 emission--NFDRS, MODIS, and FCCS fuels 
; 76-81, CO2 emission--NFDRS, MODIS, and FCCS fuels 
; 82-87, TNMHC emission--NFDRS, MODIS, and FCCS fuels 
; 88-93, NH3 emission--NFDRS, MODIS, and FCCS fuels 
; 94-99, N2O emission--NFDRS, MODIS, and FCCS fuels 
; 100-105, NOX emission--NFDRS, MODIS, and FCCS fuels 
; 106-111, SO2 emission--NFDRS, MODIS, and FCCS fuels 

burnarea = reform(ems(4:51, 0:nl-1))
totbarea = reform(ems(52, 0:nl-1))
totpm = reform(ems(56, 0:nl-1)) 

for j = 0, dLatN-1 do begin
 for i = 0, dLonN-1 do begin
    emisgrid(i,j) = 0.0
  for k = 0, nl-1 do begin
    if ( lat(k) ge LatB+j*dLat and $
         lat(k) le LatB+(j+1)*dLat and $
         lon(k) ge LonL+i*dLon and $
         lon(k) le LonL+(i+1) *dLon ) then begin
       emisgrid(i,j) = totpm(k) + emisgrid(i,j)
     endif
  endfor
 endfor
endfor
 

; start to plot map
maxemis = max(emisgrid) 
minemis = 0.


map_plot, region = region_limit, dlat = 5, dlon=10.

for j = 0, dLatN-1 do begin
  for i = 0, dLonN-1 do begin
    if (emisgrid(i,j) le minemis) then clrinx=1
    if (emisgrid(i,j) ge maxemis) then clrinx=n_level+2   
    if (emisgrid(i,j) gt minemis and $
        emisgrid(i,j) lt maxemis ) then $
        clrinx=2+n_level*(emisgrid(i,j)-minemis)/(maxemis-minemis)   
    polyfill, [LonL+i*dLon, LonL+(i+1) *dLon, LonL+(i+1) *dLon, $
            LonL+i *dLon, LonL+i*dLon], $
           [LatB+j*dLat, LatB+j*dLat,  LatB+(j+1)*dLat, $
            LatB+(j+1)*dLat, LatB+j*dLat], $
          color= clrinx 
  endfor
endfor
map_plot, region = region_limit, dlat = 5, dlon=10., /noerase
xyouts, 0.5, 0.92, strmid(0, 4) + ' ' + strmid(14, 2), color=0
endfor


device, /close
end          




