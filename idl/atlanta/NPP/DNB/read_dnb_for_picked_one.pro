
; read npp dataset routine
PRO read_npp, filename, sdsname, path, data
   fid = h5f_open (filename)
   gid = h5g_open(fid, path)
   data = h5_parse(gid, sdsname, /read_data)
   h5g_close, gid
   h5f_close, fid
END 




PRO Site_Picked, filenames, SiteNum
readcol, './picked/' + filenames, YY, Mon, DD, HH, MM, SS, npul, nlul, nouse, $
   format = '(A, A, A, A, A, A, I4, I4,  I4,  I4, A)'

nf = n_elements(YY)
DIR = '/Volumes/TOSHIBA_3B/iproject/atlanta/viirs/night/'
 for i = 0, nf-1 do begin
;for i = 0, 92-1 do begin
 gdnbof = file_search(DIR, 'GDNBO_npp_d'+YY(i) + Mon(i) + DD(i)+'_t'+HH(i)+MM(i)+SS(i)+'*')
 sdnbof = file_search(DIR, 'SVDNB_npp_d'+YY(i) + Mon(i) + DD(i)+'_t'+HH(i)+MM(i)+SS(i)+'*') 

path = '/All_Data/VIIRS-DNB-SDR_All/'
sdsname = 'Radiance'  ; case sensitive
read_npp, sdnbof, sdsname, path, dnbrad
path = '/All_Data/VIIRS-DNB-GEO_All/'
sdsname = 'LunarZenithAngle'
read_npp,  gdnbof, sdsname, path, MoonVZA 
sdsname = 'LunarAzimuthAngle'
read_npp,  gdnbof, sdsname, path, LunarAZM 
sdsname = 'SatelliteZenithAngle'
read_npp,  gdnbof, sdsname, path, SATVZA
sdsname = 'SatelliteAzimuthAngle'
read_npp,  gdnbof, sdsname, path, SatAZM 
sdsname = 'SolarZenithAngle'
read_npp,  gdnbof, sdsname, path, SolarSZA
sdsname = 'SolarAzimuthAngle'
read_npp,  gdnbof, sdsname, path, SolarAZM 
sdsname = 'MoonPhaseAngle'
read_npp,  gdnbof, sdsname, path, MoonPhase 
sdsname = 'MoonIllumFraction'
read_npp,  gdnbof, sdsname, path, MoonFrac 

; to make sure the radiances
rad = dnbrad._data(npul(i):npul(i)+3, nlul(i)) *1.e7

; data for VIIRS angles
mvza   = moonvza._data(npul(i), nlul(i))
mazm   = lunarazm._data(npul(i), nlul(i))
satvza = satvza._data(npul(i), nlul(i))
satazm = satazm._data(npul(i), nlul(i))
ssza   = solarsza._data(npul(i), nlul(i))
sazm   = solarazm._data(npul(i), nlul(i))
mphase = moonphase._data
mfrac  = moonfrac._data

;mvza = moonvza._data(npul(i):npul(i)+3, nlul(i))
;mazm = lunarazm._data(npul(i):npul(i)+3, nlul(i))
;vza = satvza._data(npul(i):npul(i)+3, nlul(i))
;azm = satazm._data(npul(i):npul(i)+3, nlul(i))
;mphase = moonphase._data
;mfrac = moonfrac._data

print, YY(i), Mon(i), DD(i), HH(i), MM(i), SS(i), mvza, $
       mazm, satvza, satazm, ssza, sazm, mphase, mfrac, $
format= '(6(A, 1X),   8(F10.3, 1X))'

np0 = npul(i)
nl0 = nlul(i)

if (SiteNum eq 0 ) then begin
printf, 10,  YY(i), Mon(i), DD(i), HH(i), MM(i), SS(i), mvza, $
             mazm, satvza, satazm, ssza, sazm, mphase, mfrac, $
format= '(6(A, 1X),   8(F10.3, 1X))'
endif

if (SiteNum eq 1 ) then begin
printf, 11,  YY(i), Mon(i), DD(i), HH(i), MM(i), SS(i), mvza, $
             mazm, satvza, satazm, ssza, sazm, mphase, mfrac, $
format= '(6(A, 1X),   8(F10.3, 1X))'
endif

if (SiteNum eq 2 ) then begin
printf, 12,  YY(i), Mon(i), DD(i), HH(i), MM(i), SS(i), mvza, $
             mazm, satvza, satazm, ssza, sazm, mphase, mfrac, $
format= '(6(A, 1X),   8(F10.3, 1X))'
endif

if (SiteNum eq 3 ) then begin
printf, 13,  YY(i), Mon(i), DD(i), HH(i), MM(i), SS(i), mvza, $
             mazm, satvza, satazm, ssza, sazm, mphase, mfrac, $
format= '(6(A, 1X),   8(F10.3, 1X))'
endif

if (SiteNum eq 4 ) then begin
printf, 14,  YY(i), Mon(i), DD(i), HH(i), MM(i), SS(i), mvza, $
             mazm, satvza, satazm, ssza, sazm, mphase, mfrac, $
format= '(6(A, 1X),   8(F10.3, 1X))'
endif

if (siteNum eq 5) then begin
printf, 15,  YY(i), Mon(i), DD(i), HH(i), MM(i), SS(i), mvza, $
             mazm, satvza, satazm, ssza, sazm, mphase, mfrac, $
format= '(6(A, 1X),   8(F10.3, 1X))'
endif

endfor

END


; Main code starts
;              N. Atlanta    SW            SE           CTR         CTR      
 FileNames = ['131350002', '130770002', '131510002', '131210055', '130890002', 'CTR', 'YANG']
 CLATS = [  33.9631,  33.4040,  33.4336,  33.7206,  33.6881,  33.745,  33.7975] 
 CLONS = [ -84.0692, -84.7460, -84.1617, -84.3574, -84.2902, -84.390, -84.3239]
 siteID = [ 'A', 'B', 'C', 'D', 'E', 'CTR', 'YANG']


openw, 10, 'SiteA_Angle_one_201208_10.txt'
openw, 11, 'SiteB_Angle_one_201208_10.txt'
openw, 12, 'SiteC_Angle_one_201208_10.txt'
openw, 13, 'SiteD_Angle_one_201208_10.txt'
openw, 14, 'SiteE_Angle_one_201208_10.txt'
openw, 15, 'SiteCTR_Angle_one_201208_10.txt'

 
 for i = 0, n_elements(CLATS)-2 do begin 
 ; domainsize = 0.015
  Site_Picked, 'Site' + SiteID(i) + '_pickup_201208_10.txt', i 
 endfor

close, 10
close, 11
close, 12
close, 13
close, 14
close, 15

 END















