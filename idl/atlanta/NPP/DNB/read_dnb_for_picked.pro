
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
DIR = '/data/NPP/'
for i = 0, nf-1 do begin
;for i = 0, 2 do begin
 gdnbof = file_search(DIR, 'GDNBO_npp_d'+YY(i) + Mon(i) + DD(i)+'_t'+HH(i)+MM(i)+SS(i)+'*')
 sdnbof = file_search(DIR, 'SVDNB_npp_d'+YY(i) + Mon(i) + DD(i)+'_t'+HH(i)+MM(i)+SS(i)+'*') 

sdsname = 'Radiance'  ; case sensitive
path = '/All_Data/VIIRS-DNB-SDR_All/'
read_npp, sdnbof, sdsname, path, dnbrad

path = '/All_Data/VIIRS-DNB-GEO_All/'
sdsname = 'LunarZenithAngle'
read_npp,  gdnbof, sdsname, path, MoonVZA 
sdsname = 'LunarAzimuthAngle'
read_npp,  gdnbof, sdsname, path, LunarAZM 
sdsname = 'MoonPhaseAngle'
read_npp,  gdnbof, sdsname, path, MoonPhase 
sdsname = 'SatelliteZenithAngle'
read_npp,  gdnbof, sdsname, path, SATVZA
sdsname = 'SatelliteAzimuthAngle'
read_npp,  gdnbof, sdsname, path, SatAZM 
sdsname = 'MoonIllumFraction'
read_npp,  gdnbof, sdsname, path, MoonFrac 
sdsname = 'SolarAzimuthAngle'
read_npp,  gdnbof, sdsname, path, SolarAZM 
sdsname = 'SolarZenithAngle'
read_npp,  gdnbof, sdsname, path, SolarAng 

; to make sure the radiances
rad = dnbrad._data(npul(i):npul(i)+3, nlul(i)) *1.e7

; data for VZAs
data = satvza._data

;azm = satazm._data(npul(i):npul(i)+3, nlul(i))
;mazm = lunarazm._data(npul(i):npul(i)+3, nlul(i))
;mvza = moonvza._data(npul(i):npul(i)+3, nlul(i))
mphase = moonphase._data
mfrac = moonfrac._data

;vza = satvza._data(npul(i):npul(i)+3, nlul(i))
;azm = satazm._data(npul(i):npul(i)+3, nlul(i))
;mazm = lunarazm._data(npul(i):npul(i)+3, nlul(i))
;mvza = moonvza._data(npul(i):npul(i)+3, nlul(i))
;mphase = moonphase._data
;mfrac = moonfrac._data

print,  YY(i), Mon(i), DD(i), HH(i), MM(i), SS(i),   $
        mphase(0), mfrac(0), format='(6(A, 1X), 2(F7.3, 1X))' 

np0 = npul(i)
nl0 = nlul(i)

if (SiteNum eq 1 ) then begin
printf, 14,  YY(i), Mon(i), DD(i), HH(i), MM(i), SS(i), data(np0-3:np0-1, nl0+1), $
data(np0-3:np0-1, nl0+2),  data(np0-3:np0-1, nl0+3), mphase(0), mfrac(0),  $
format= '(6(A, 1X),   14(F7.3, 1X))'
endif

if (SiteNum eq 0 ) then begin
printf, 15,  YY(i), Mon(i), DD(i), HH(i), MM(i), SS(i), data(np0:np0+3, nl0), $
data(np0+1:np0+3, nl0+1),  data(np0+1:np0+3, nl0+2), mphase(0), mfrac(0), $
format= '(6(A, 1X),   14(F7.3, 1X))'
endif

if (SiteNum eq 2 ) then begin
printf, 13, YY(i), Mon(i), DD(i), HH(i), MM(i), SS(i),  data(np0-4, nl0+1), $
data(np0-3, nl0+1),  data(np0-2, nl0+1),  data(np0-4:np0-1, nl0+2),mphase(0), mfrac(0), $
format= '(6(A, 1X),  9(F7.3, 1X))'
endif

if (SiteNum eq 3 ) then begin
printf, 10, YY(i), Mon(i), DD(i), HH(i), MM(i), SS(i),  data(np0, nl0+2), $
data(np0-1, nl0+2),  data(np0, nl0+3), data(np0-1, nl0+3), data(np0-2, nl0+2), mphase(0), mfrac(0), $
format= '(6(A, 1X),   7(F7.3, 1X))'
endif

if (SiteNum eq 4 ) then begin
printf, 11, YY(i), Mon(i), DD(i), HH(i), MM(i), SS(i), data(np0-1, nl0-4:nl0), $
data(np0, nl0-4:nl0) , data(np0+1, nl0-4:nl0), mphase(0), mfrac(0), format='(6(A, 1X),  17(F7.3, 1X))'
endif

if (siteNum eq 5) then begin
printf, 12, YY(i), Mon(i), DD(i), HH(i), MM(i), SS(i), data(np0-2, nl0-2:nl0+2), $
data(np0-1, nl0-2:nl0+2) , data(np0, nl0-2:nl0+2), data(np0+1, nl0-2:nl0+2), $
data(np0+2, nl0-2:nl0+2), mphase(0), mfrac(0),  $
 format='(6(A, 1X),  27(F7.3, 1X))'
endif

endfor

END


; Main code starts
;              N. Atlanta    SW            SE           CTR         CTR      
 FileNames = ['131350002', '130770002', '131510002', '131210055', '130890002', 'CTR', 'YANG']
 CLATS = [  33.9631,  33.4040,  33.4336,  33.7206,  33.6881,  33.745,  33.7975] 
 CLONS = [ -84.0692, -84.7460, -84.1617, -84.3574, -84.2902, -84.390, -84.3239]
 siteID = [ 'A', 'B', 'C', 'D', 'E', 'CTR', 'YANG']


openw, 10, 'SiteD_Angle.txt'
openw, 11, 'SiteE_Angle.txt'
openw, 12, 'SiteCTR_Angle.txt'
openw, 13, 'SiteC_Angle.txt'
openw, 14, 'SiteB_Angle.txt'
openw, 15, 'SiteA_Angle.txt'

 
 for i = 0, n_elements(CLATS)-2 do begin 
 ; domainsize = 0.015
  Site_Picked, 'Site' + SiteID(i) + '_pickup.txt', i 
 endfor

close, 10
close, 11
close, 12
close, 13
close, 14
close, 15

 END















