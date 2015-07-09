
; read npp dataset routine
PRO read_npp, filename, sdsname, path, data
   fid = h5f_open (filename)
   gid = h5g_open(fid, path)
   data = h5_parse(gid, sdsname, /read_data)
   h5g_close, gid
   h5f_close, fid
END 



PRO PM_DNBCOLLOCATE, clat, clon, siteidname 

;clat = 33.4
;clon = -84.75
DIR = '/home/jwang/PRWORK/all_data/night/'

readcol, 'svdnbfiles.txt', svdnbfnames, format='(a)'
nf = n_elements(svdnbfnames)

readcol, 'gdnbofiles.txt', gdnbofnames, format='(a)'
ndgf = n_elements(gdnbofnames)


;for i = 0, nf-1 do begin
for i = 380, nf-1 do begin
; read radaince 
;svdnbf = 'SVDNB_npp_d20120907_t0727018_e0728260_b04468_c20120907135348935344_noaa_ops.h5'
svdnbf =  svdnbfnames(i)
sdsname = 'Radiance'  ; case sensitive
path = '/All_Data/VIIRS-DNB-SDR_All/'
read_npp, DIR + svdnbf, sdsname, path, dnbrad

; read lat and lon, not searching current directory
;gdnbof = 'GDNBO_npp_d20120907_t0727018_e0728260_b04468_c20120907134830316872_noaa_ops.h5'
;result = file_search (DIR,  'GDNBO_'+ strmid(svdnbf, 6, 31) +'*.h5')
;gdnbof = strmid (result, strpos(result, '_') -5)

result = gdnbofnames[where (strmatch ( gdnbofnames, 'GDNBO_' + strmid(svdnbf, 6, 31)  + '*.h5' )) ]
gdnbof = result(0)

sdsname = 'Latitude'
path = '/All_Data/VIIRS-DNB-GEO_All/'
read_npp, DIR+ gdnbof, sdsname, path, dnblat
sdsname = 'Longitude'
read_npp, DIR+ gdnbof, sdsname, path, dnblon

; find PM2.5 at 33.40 and -84.75
result = where ( abs(dnblat._data - clat) le 0.03 and $
                 abs(dnblon._data - clon) le 0.03, count)

if (count gt 0 ) then begin
sdsname = 'LunarZenithAngle'
read_npp, DIR+ gdnbof, sdsname, path, MoonVZA 
sdsname = 'LunarAzimuthAngle'
read_npp, DIR+ gdnbof, sdsname, path, LunarAZM 
sdsname = 'MoonPhaseAngle'
read_npp, DIR + gdnbof, sdsname, path, MoonPhase 
sdsname = 'SatelliteZenithAngle'
read_npp, DIR+ gdnbof, sdsname, path, SATVZA
sdsname = 'SatelliteAzimuthAngle'
read_npp, DIR+ gdnbof, sdsname, path, SatAZM 
sdsname = 'MoonIllumFraction'
read_npp, DIR+ gdnbof, sdsname, path, MoonFrac 
sdsname = 'SolarAzimuthAngle'
read_npp, DIR+ gdnbof, sdsname, path, SolarAZM 
sdsname = 'SolarZenithAngle'
read_npp, DIR+ gdnbof, sdsname, path, SolarAng 

rad = dnbrad._data(result)
vza = mean(satvza._data(result))
azm = mean(satazm._data(result))
mazm = mean(lunarazm._data(result))
mvza = mean(moonvza._data(result))
mphase = moonphase._data
mfrac = moonfrac._data
sza = mean(solarang._data(result))
sazm = mean(SolarAZM._data(result))
save, rad, count, vza, azm, mazm, mvza, mphase, mfrac, sza, sazm, $
      filename=strmid(svdnbf, 11, 17) +'_' + siteidname + '.xdr' 
endif

endfor

END


; Main code starts
;              N. Atlanta    SW            SE           CTR         CTR      
 FileNames = ['131350002', '130770002', '131510002', '131210055', '130890002', 'CTR', 'YANG']
 CLATS = [  33.9631,  33.4040,  33.4336,  33.7206,  33.6881,  33.745,  33.7975] 
 CLONS = [ -84.0692, -84.7460, -84.1617, -84.3574, -84.2902, -84.390, -84.3239]
 siteID = [ 'A', 'B', 'C', 'D', 'E', 'CTR', 'YANG']
 
; for i = 0, n_elements(CLATS)-1 do begin 
 for i = 1, 1 do begin 
 ; domainsize = 0.015
  PM_DNBCOLLOCATE, clats(i), clons(i), siteid(i) 
 endfor

 END















