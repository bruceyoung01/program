
@../../../idl_lib/procedure/universal/overlay1band_img.pro
@../../../idl_lib/procedure/universal/mysym.pro

; read npp dataset routine
PRO read_npp, filename, sdsname, path, data
   fid = h5f_open (filename)
   gid = h5g_open(fid, path)
   data = h5_parse(gid, sdsname, /read_data)
   h5g_close, gid
   h5f_close, fid
END 

 PRO  VFileNamedecode, svdnbfnames, YY, Mon, DD, HH, MM, SS
  ;readcol, 'svdnbfiles.txt', svdnbfnames, format='(a)'
  nf = n_elements(svdnbfnames)
  YY = strmid(svdnbfnames, 11, 4)
  Mon = strmid(svdnbfnames, 15, 2)
  DD = strmid(svdnbfnames, 17, 2)

  ; in UTC
  HH = strmid(svdnbfnames, 21, 2)
  MM = strmid(svdnbfnames, 23, 2)
  SS = strmid(svdnbfnames, 25, 3)
;  print, YY, MM, DD, HH, MM, SS
;  ORbit, long(YY), long(Mon), long(DD), orbitnum
 END


PRO plot_sites, lat, lon, np, nl, npstart, nlstart, data, YY, Mon, DD, HH, MM, SS
SLATS = [  33.9631,  33.4040,  33.4336,  33.7206,  33.6881,  33.7544,  33.7975]
SLONS = [ -84.0692, -84.7460, -84.1617, -84.3574, -84.2902, -84.3944, -84.3239]
siteID = [ 'A', 'B', 'C', 'D', 'E', 'CTR', 'YANG']
nsite  = N_ELEMENTS(siteid)
nx = [0, 0, 0, 0, 0, 0]
ny = [0, 0, 2, 0, 0, 0]

for i = 0, nsite - 1 do begin
;for i = 0, 0 do begin
  ; location of the site
  plots, slons(i), slats(i), psym=mysym(6, 1), symsize = 2, /data, color=120

difflat = abs(lat - slats(i))
difflon = abs(lon - slons(i))
result = where(difflat^2+difflon^2 eq min(difflat^2+difflon^2), count)
if ( sqrt(difflat(result)^2+difflon(result)^2) le 0.03 ) then begin 

nl0 = fix(result(0)/np)
np0 = result(0) - np*1L*nl0
 ; pixel closest to the location
plots, lon(np0, nl0), lat(np0, nl0), psym=mysym(11, 1), symsize = 2, /data
;print, i, lon(np0, nl0) - slons(i), lat(np0, nl0)-slats(i)

 ; pixel i, j, that has constant light sources
;for site 2.

if ( i eq 0) then begin
if (np0+3 lt np and nl0+2 le nl-1  ) then begin
plots, lon(np0+1, nl0+1), lat(np0+1, nl0+1), psym=mysym(6, 1), symsize = 2, /data
xyouts, lon(np0, nl0), lat(np0, nl0), 'A', charsize = 3.0, charthick = 2.0, color = 3
xyouts, lon(np0:np0+3, nl0), lat(np0:np0+3, nl0), string([1, 2, 3, 4]), charsize = 3.0, charthick = 2.0, color = 2
xyouts, lon(np0+1:np0+3, nl0+1), lat(np0+1:np0+3, nl0+1), string([5, 6, 7]), charsize = 3.0, charthick = 2.0, color = 2
xyouts, lon(np0+1:np0+3, nl0+2), lat(np0+1:np0+3, nl0+2), string([8, 9, 10]), charsize = 3.0, charthick = 2.0, color = 2
printf, 10,  YY(0), Mon(0), DD(0), HH(0), MM(0), SS(0), npstart+fix(np0), nlstart+nl0, np0, nl0,  data(np0:np0+3, nl0), $
data(np0+1:np0+3, nl0+1),  data(np0+1:np0+3, nl0+2),  $
format= '(6(A, 1X),  I4, 1X, I4, 1X, I4, 1X, I4, 12(F10.7, 1X))'
print,  YY(0), Mon(0), DD(0), HH(0), MM(0), SS(0), npstart+fix(np0), nlstart+nl0, np0, nl0,  data(np0:np0+3, nl0), $
data(np0+1:np0+3, nl0+1),  data(np0+1:np0+3, nl0+2),  $
format= '(6(A, 1X),  I4, 1X, I4, 1X, I4, 1X, I4, 12(F10.7, 1X))'
endif
endif

if ( i eq 1) then begin
if (np0-3 ge 0 and nl0+3 le nl-1  ) then begin
plots, lon(np0-3, nl0+1), lat(np0-3, nl0+1), psym=mysym(6, 1), symsize = 2, /data
xyouts, lon(np0, nl0), lat(np0, nl0), 'B', charsize = 3.0, charthick = 2.0, color = 3
xyouts, lon(np0-3:np0-1, nl0+1), lat(np0-3:np0-1, nl0+1), string([1, 2, 3]), charsize = 3.0, charthick = 2.0, color = 2
xyouts, lon(np0-3:np0-1, nl0+2), lat(np0-3:np0-1, nl0+2), string([4, 5, 6]), charsize = 3.0, charthick = 2.0, color = 2
xyouts, lon(np0-3:np0-1, nl0+3), lat(np0-3:np0-1, nl0+3), string([7, 8, 9]), charsize = 3.0, charthick = 2.0, color = 2
printf, 11,  YY(0), Mon(0), DD(0), HH(0), MM(0), SS(0), npstart+fix(np0), nlstart+nl0, np0, nl0,  data(np0-3:np0-1, nl0+1), $
data(np0-3:np0-1, nl0+2),  data(np0-3:np0-1, nl0+3),  $
format= '(6(A, 1X),  I4, 1X, I4, 1X, I4, 1X, I4, 12(F10.7, 1X))'
;print,  YY(0), Mon(0), DD(0), HH(0), MM(0), SS(0), npstart+fix(np0), nlstart+nl0, np0, nl0,  data(np0-3:np0-1, nl0+1), $
;data(np0-3:np0-1, nl0+2),  data(np0-3:np0-1, nl0+3),  $
;format= '(6(A, 1X),  I4, 1X, I4, 1X, I4, 1X, I4, 12(F10.7, 1X))'
endif
endif

;for site 2.
if ( i eq 2) then begin
if (np0-4 ge 0 and nl0+2 le nl-1) then begin
plots, lon(np0-4, nl0+2), lat(np0-3, nl0+2), psym=mysym(6, 1), symsize = 2, /data
xyouts, lon(np0, nl0), lat(np0, nl0), 'C', charsize = 3.0, charthick = 2.0, color = 3
xyouts, lon(np0-4, nl0+1), lat(np0-4, nl0+1), string([1]), charsize = 3.0, charthick = 2.0, color = 2
xyouts, lon(np0-3, nl0+1), lat(np0-3, nl0+1), string([2]), charsize = 3.0, charthick = 2.0, color = 2
xyouts, lon(np0-2, nl0+1), lat(np0-2, nl0+1), string([3]), charsize = 3.0, charthick = 2.0, color = 2
xyouts, lon(np0-4:np0-1, nl0+2), lat(np0-4:np0-1, nl0+2), string([4, 5, 6, 7, 8]), charsize = 1.0, color = 2
printf, 12, YY(0), Mon(0), DD(0), HH(0), MM(0), SS(0), npstart+fix(np0), nlstart+nl0, np0, nl0,  data(np0-4, nl0+1), $
data(np0-3, nl0+1),  data(np0-2, nl0+1),  data(np0-4:np0-1, nl0+2), $
format= '(6(A, 1X),  I4, 1X, I4, 1X, I4, 1X, I4, 7(F10.7, 1X))'
;print,  YY(0), Mon(0), DD(0), HH(0), MM(0), SS(0), npstart+fix(np0), nlstart+nl0, np0, nl0,  data(np0-4, nl0+1), $
;data(np0-3, nl0+1),  data(np0-2, nl0+1),  data(np0-4:np0-1, nl0+2), $
;format= '(6(A, 1X),  I4, 1X, I4, 1X, I4, 1X, I4, 7(F10.7, 1X))'
endif
endif

;for site 3.
if ( i eq 3) then begin
if (nl0+3 lt nl and np0-2 ge 0 ) then begin
plots, lon(np0, nl0+3), lat(np0, nl0+3), psym=mysym(6, 1), symsize = 2, /data
xyouts, lon(np0, nl0+3), lat(np0, nl0+3), 'D', charsize = 3, charthick = 2.0, color = 3
xyouts, lon(np0, nl0+2), lat(np0, nl0+2), string([1]),     charsize = 3.0, charthick = 2.0, color = 2
xyouts, lon(np0-1, nl0+2), lat(np0-1, nl0+2), string([2]), charsize = 3.0, charthick = 2.0, color = 2
xyouts, lon(np0, nl0+3), lat(np0, nl0+3), string([3]),     charsize = 3.0, charthick = 2.0, color = 2
xyouts, lon(np0-1, nl0+3), lat(np0-1, nl0+3), string([4]), charsize = 3.0, charthick = 2.0, color = 2
xyouts, lon(np0-2, nl0+2), lat(np0-2, nl0+2), string([5]), charsize = 3.0, charthick = 2.0, color = 2
printf, 13, YY(0), Mon(0), DD(0), HH(0), MM(0), SS(0), npstart+fix(np0), nlstart+nl0, np0, nl0,  data(np0, nl0+2), $
data(np0-1, nl0+2),  data(np0, nl0+3), data(np0-1, nl0+3), data(np0-2, nl0+2), $
format= '(6(A, 1X),  I4, 1X, I4, 1X, I4, 1X, I4, 5(F10.7, 1X))'
endif
endif

;for site 4
if ( i eq 4) then begin
if (np0+1 lt np and nl0-4 ge 0) then begin
plots, lon(np0, nl0-4), lat(np0, nl0-4), psym=mysym(6, 1), symsize = 2, /data
xyouts, lon(np0, nl0), lat(np0, nl0), 'E', charsize = 3.0, charthick = 2.0, color = 3
xyouts, lon(np0-1, nl0-4:nl0), lat(np0-1, nl0-4:nl0), string([1, 2, 3, 4, 5]), charsize = 3.0, charthick = 2.0, color = 2
xyouts, lon(np0, nl0-4:nl0), lat(np0, nl0-4:nl0), string([6, 7, 8, 9, 10]), charsize = 3.0, charthick = 2.0, color = 2
xyouts, lon(np0+1, nl0-4:nl0), lat(np0+1, nl0-4:nl0), string([11, 12, 13, 14, 15]), charsize = 3.0, charthick = 2.0, color = 2
printf, 14, YY(0), Mon(0), DD(0), HH(0), MM(0), SS(0), npstart+fix(np0+1), nlstart+nl0, np0, nl0,  data(np0-1, nl0-4:nl0), $
data(np0, nl0-4:nl0) , data(np0+1, nl0-4:nl0), format='(6(A, 1X),  I4, 1X, I4, 1X, I4, 1X, I4, 15(F10.7, 1X))'
;print, YY(0), Mon(0), DD(0), HH(0), MM(0), SS(0), npstart+fix(np0+1), nlstart+nl0-4, np0+1, nl0-4,  data(np0-1, nl0-4:nl0), $
;data(np0, nl0-4:nl0) , data(np0+1, nl0-4:nl0), format='(6(A, 1X),  I4, 1X, I4, 1X, I4, 1X, I4, 15(F10.7, 1X))'
endif
endif

; for site 5
if ( i eq 5) then begin
if (np0-2 ge 0 and np0+2 le  np and nl0-2 ge 0 and nl0+2 le nl ) then begin
plots, lon(np0, nl0), lat(np0, nl0), psym=mysym(6, 1), symsize = 2, /data, color=120
xyouts, lon(np0, nl0), lat(np0, nl0), 'CTR', charsize = 3.0, charthick = 2.0, color = 3
xyouts, lon(np0-2, nl0-2:nl0+2), lat(np0-2, nl0-2:nl0+2), string([1, 2, 3, 4, 5]),      charsize = 3.0, charthick = 2.0, color = 2
xyouts, lon(np0-1, nl0-2:nl0+2), lat(np0-1, nl0-2:nl0+2), string([6, 7, 8, 9, 10]),     charsize = 3.0, charthick = 2.0, color = 2
xyouts, lon(np0,   nl0-2:nl0+2), lat(np0,   nl0-2:nl0+2), string([11, 12, 13, 14, 15]), charsize = 3.0, charthick = 2.0, color = 2
xyouts, lon(np0+1, nl0-2:nl0+2), lat(np0+1, nl0-2:nl0+2), string([16, 17, 18, 19, 20]), charsize = 3.0, charthick = 2.0, color = 2
xyouts, lon(np0+2, nl0-2:nl0+2), lat(np0+2, nl0-2:nl0+2), string([21, 22, 23, 24, 25]), charsize = 3.0, charthick = 2.0, color = 2
printf, 15, YY(0), Mon(0), DD(0), HH(0), MM(0), SS(0), npstart+fix(np0), nlstart+nl0, np0, nl0,  data(np0-2, nl0-2:nl0+2), $
data(np0-1, nl0-2:nl0+2) , data(np0, nl0-2:nl0+2), data(np0+1, nl0-2:nl0+2), data(np0+2, nl0-2:nl0+2),  format='(6(A, 1X),  I4, 1X, I4, 1X, I4, 1X, I4, 25(F10.7, 1X))'
;print, YY(0), Mon(0), DD(0), HH(0), MM(0), SS(0), npstart+fix(np0), nlstart+nl0, np0, nl0,  data(np0-2, nl0-2:nl0+2), $
;data(np0-1, nl0-2:nl0+2) , data(np0, nl0-2:nl0+2), data(np0+1, nl0-2:nl0+2), data(np0+2, nl0-2:nl0+2),  format='(6(A, 1X),  I4, 1X, I4, 1X, I4, 1X, I4, 25(F10.7, 1X))'
endif
endif

endif
endfor

end


readcol, 'svdnbfiles_201208_10.txt', svdnbfnames, format='(a)'
readcol, 'Group_201208_10.txt', Validfilenames, format='(a)'

;for i = 0, n_elements(Validfilenames)-1 do begin
;  print, svdnbfnames[where(strmatch(svdnbfnames, '*'+strmid(Validfilenames(i), 0, 30 )+'*'))]
;endfor
 
nf = n_elements(Validfilenames)
DIR = '/Volumes/TOSHIBA_3B/iproject/atlanta/viirs/night/'
;DIR = '' 
openw, 10, 'SiteA_pickup_201208_10.txt'
openw, 11, 'SiteB_pickup_201208_10.txt'
openw, 12, 'SiteC_pickup_201208_10.txt'
openw, 13, 'SiteD_pickup_201208_10.txt'
openw, 14, 'SiteE_pickup_201208_10.txt'
openw, 15, 'SiteCTR_pickup_201208_10.txt'

;for i = 0, 92-1 do begin
 for i = 25, nf-1  do begin
; read radaince 
;svdnbf = 'SVDNB_npp_d20120907_t0727018_e0728260_b04468_c20120907135348935344_noaa_ops.h5'
;svdnbf = svdnbfnames(i)

groupnum = STRMID(Validfilenames(i), 0, 3 )
print, "# of Group : ", groupnum
svdnbf = svdnbfnames[where(strmatch(svdnbfnames, '*'+strmid(Validfilenames(i), 3, 27 )+'*'))]
print, "NOW PROCESSING : ", svdnbf
VFileNamedecode, svdnbf, YY, Mon, DD, HH, MM, SS
sdsname = 'Radiance'  ; case sensitive
path = '/All_Data/VIIRS-DNB-SDR_All/'
read_npp, DIR + svdnbf, sdsname, path, dnbrad

; read lat and lon
;gdnbof = 'GDNBO_npp_d20120907_t0727018_e0728260_b04468_c20120907134830316872_noaa_ops.h5'
;result = findfiles (DIR + 'GDNBO_'+ strmid(svdnbf, 6, 31) +'*.h5')
result = file_search (DIR , 'GDNBO_'+ strmid(svdnbf, 6, 31) +'*.h5')

gdnbof = strmid (result, strpos(result, '_npp') -5)
sdsname = 'Latitude'
path = '/All_Data/VIIRS-DNB-GEO_All/'
read_npp, DIR+ gdnbof, sdsname, path, dnblat
sdsname = 'Longitude'
read_npp, DIR+ gdnbof, sdsname, path, dnblon
;sdsname = 'LunarZenithAngle'
;read_npp, gdnbof, sdsname, path, MoonVZA 
;sdsname = 'LunarAzimuthAngle'
;read_npp, gdnbof, sdsname, path, LunarAZM 
sdsname = 'MoonPhaseAngle'
read_npp, DIR+gdnbof, sdsname, path, MoonPhase 
;sdsname = 'SatelliteZenithAngle'
;read_npp, gdnbof, sdsname, path, SATVZA
;sdsname = 'SatelliteAzimuthAngle'
;read_npp, gdnbof, sdsname, path, SatAZM 
;sdsname = 'MoonIllumFraction'
;read_npp, gdnbof, sdsname, path, MoonFrac 
;
;sdsname = 'SolarAzimuthAngle'
;read_npp, gdnbof, sdsname, path, SolarAZM 
;sdsname = 'SolarZenithAngle'
;read_npp, gdnbof, sdsname, path, SolarAng 


;
;data = dnbrad._data*1.e12
;data1 = bytscl(data, min=5000, max=10000)
;cgIMAGE, data1, /KEEP_ASPECT_RATIO

; start to plot
np = dnbrad._DIMENSIONS(0)
nl = dnbrad._DIMENSIONS(1)

; lunar information
; atlanta
;latmax = 38
;latmin = 28
;lonmax = -79
;lonmin = -89

;SLATS = [  33.9631,  33.4040,  33.4336,  33.7206,  33.6881,  33.7544,  33.7975]
;SLONS = [ -84.0692, -84.7460, -84.1617, -84.3574, -84.2902, -84.3944, -84.3239]
;siteID = [ 'A', 'B', 'C', 'D', 'E', 'CTR', 'YANG']
; lincoln and omaha area
ctrlat = 33.9631
ctrlon = -84.0692
;ctrlat = 33.96
;ctrlon = -84.06
latmax = ctrlat + 0.05
latmin = ctrlat - 0.05
lonmin = ctrlon - 0.05
lonmax = ctrlon + 0.05

region_limit = [latmin, lonmin, latmax, lonmax]
result = where(dnblat._data ge latmin and $
               dnblat._data le latmax and $
               dnblon._data ge lonmin and $
               dnblon._data le lonmax, count)
if (count gt 0 ) then begin  

; locate the center point
difflat = abs(dnblat._data - ctrlat)
difflon = abs(dnblon._data - ctrlon)
result = where(difflat+difflon eq min(difflat+difflon))
nl0 = result(0)/np
np0 = result(0) - np*1L*nl0

; pixel sizes
nx = 250
ny = 250


; if the image edge is at the center
if  nl0 +ny gt nl-1 then ny = nl-nl0-1
; get 250 by 250 pixels
nlstart = nl0*1.0-ny
if nlstart lt 0 then nlstart=0.
nll = nl0+ny - nlstart+1 

; must have two lines or more.
if (nll gt 2) then begin
; do the same for np
npstart = np0*1.0-nx
if npstart lt 0 then npstart = 0
if np0+nx gt np-1 then nx = np-np0-1
npp = np0 + nx - npstart + 1 

data = dnbrad._data(npstart:np0+nx, nlstart:nl0+ny)*1.e7
lat = dnblat._data(npstart:np0+nx, nlstart:nl0+ny) 
lon = dnblon._data(npstart:np0+nx, nlstart:nl0+ny) 

mag=80L
mindata = min(data)
maxdata = max(data)

tmpdata = congrid(data, npp*mag, nll*mag )
;data1 = bytscl(alog(tmpdata), min=alog(mindata), max=alog(maxdata))
;
;data1 = bytscl(tmpdata, min=mindata, max=maxdata)

data1 = bytscl(tmpdata, min=0.0, max=0.5, top = 180)
result = where (tmpdata gt 0.5, count)
if (count gt 0 ) then $
data1(result) = 181 + bytscl(tmpdata(result), min=0.5, max = 1.2, top=255-181)

;data1 = bytscl(tmpdata, min=0.5, max=0.8, top = 180)
;result = where (tmpdata gt 0.8, count)
;if (count gt 0 ) then $
;data1(result) = 181 + bytscl(tmpdata(result), min=0.8, max = 3, top=255-181)

;result1 = where(tmpdata lt 0.1)
;data1(result1) = (0.1 - tmpdata(result1))/

tmplat = congrid(lat, npp*mag, nll*mag, /interp)
tmplon = congrid(lon, npp*mag, nll*mag, /interp)
;  LOAD COLOR TABLE
MYCT, 0, ncolors = 100, /NO_STD
overlay1band_img, 1000, 1000, data1, tmplat,$
        tmplon,$
        npp*mag, nll*mag, ' ', strmid(svdnbf, 6, 31) + ', moonphase: ' + $
        string(moonphase._data, format='(f7.2)'), $
        region_limit = region_limit

;ADD HORIZONTAL AND VERTICAL LINE 
;MYCT, 20, ncolors = 100, /NO_STD
;xconth = [-84.12, -84.02]
;yconth = [ 33.96,  33.96]
;xcontv = [-84.06, -84.06]
;ycontv = [ 33.91,  34.10]
;oplot, xconth, yconth, linestyle = 1, thick = 2, color = 4
;oplot, xcontv, ycontv, linestyle = 1, thick = 2, color = 4
;color_imagemap, tmplat,$
;        tmplon, hist_equal(tmpdata), $
;        title =  strmid(svdnbf, 6, 31) + ', moonphase: ' + $
;        string(moonphase._data, format='(f5.2)'), $
;        limit = region_limit


MYCT, 0
plot_sites, lat, lon, npp, nll, npstart, nlstart, data, YY, Mon, DD, HH, MM, SS
image = tvrd(true=1, order=1)
write_png, groupnum + strmid(svdnbf, 6, 31) + '_A.png', image, /order

endif
endif

endfor
close, 10
close, 11
close, 12
close, 13
close, 14
close, 15
;LUNARAZIMUTHANGLE
;LUNARZENITHANGLE
;SATELLITEAZIMUTHANGLE
;SATELLITERANGE
;SATELLITEZENITHANGLE
;SOLARAZIMUTHANGLE
;SOLARZENITHANGLE

; LunarZenithAngle
; LunarAzimuthAngle


END



