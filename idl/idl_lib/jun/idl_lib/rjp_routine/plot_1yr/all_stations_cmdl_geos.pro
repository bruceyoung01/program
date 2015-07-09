; $Id: all_stations_cmdl_geos.pro,v 1.2 2003/12/08 19:34:51 bmy Exp $
pro all_stations_cmdl_geos, species1, species, max_sta, pref,$
                            ptop, dlat, dlon, ext


filest='/users/trop/iam/netCDF/Sites.ground.CO.1'
;PRINT, filest
openr, usta, filest, /get_lun
iname_sta=''
ititle_sta=''
ipref_sta=''

name_sta = strarr(max_sta)
lon_sta      = fltarr(max_sta)
lat_sta      = fltarr(max_sta)
lon_sta_1      = fltarr(max_sta)
lat_sta_1      = fltarr(max_sta)
title_sta = strarr(max_sta)
pref_sta = strarr(max_sta)

for i=0,max_sta-1 do begin
    readf,usta, iname_sta,ititle_sta,  ilat, ilon, ipref_sta,        $
                format='(2x,a3,7x,a15,2x,f6.2,3x,f6.2,4x,a3)'
    ;print,      iname_sta, ititle_sta, ilat, ilon, ipref_sta,    $
                format='(2x,a3,7x,a15,2x,f6.2,3x,f6.2,4x,a3)'
    name_sta(i) = iname_sta
    lon_sta_1(i)      = round(ilon)
    lat_sta_1(i)      = round(ilat)
    lon_sta(i)      = ilon
    lat_sta(i)      = ilat
    title_sta(i) = ititle_sta
    pref_sta[i] = ipref_sta
endfor


;   Now extract proper profile for the stations
;   proper name will be given later, now we read from just one file

for i=0,max_sta-1 do begin

; Put longitude in (-180,180) range

if lon_sta_1(i) gt 180 then lon_sta_1(i)=lon_sta_1(i)-360
if lon_sta(i) gt 180 then lon_sta(i)=lon_sta(i)-360


for j=1,12 do begin

   mn=strtrim(j,2)

   ;print, "************************"
   ;print, mn

if (strlen(mn) eq 1) then begin

      mn='0'+mn
   endif
   name=pref+mn+'01.nc'

   ;=================================================================
   ; Read 3-D CO
   ; return LAT & lon from the file
   ;=================================================================
   CO = Get_Species_Geos( name, Date=Date, $
                       Species='IJ-AVG-$::CO', Lat=Lat, Lon=Lon )
   Pressure = Get_Pressure_Geos( Name, PTOP=PTOP, Lat=Lat, Lon=Lon )

;   Now select proper box

   Indlat = Where( Lat ge lat_sta(i)-dlat/2 and Lat le lat_sta(i)+dlat/2 )
   Indlon = Where( Lon ge lon_sta(i)-dlon/2 and Lon le lon_sta(i)+dlon/2 )

;;print, lon_sta(i)
;;print, lon
;;print, indlon
;;print, indlat

   CO_box = CO[Indlon,Indlat,0]
   Pressure_box = Pressure[Indlon,Indlat,0]


;;print, CO_box
;;print, Pressure_box

;;print, i , CO_box
out=CO_box

if (pref_sta(i) eq 'nwr') then begin
out=interpol(CO[Indlon,Indlat,0:18],-alog10(Pressure[Indlon,Indlat,0:18]),-alog10(700.))
endif

if (pref_sta(i) eq 'izo') then begin
out=interpol(CO[Indlon,Indlat,0:18],-alog10(Pressure[Indlon,Indlat,0:18]),-alog10(800.))
endif

if (pref_sta(i) eq 'mlo') then begin
out=interpol(CO[Indlon,Indlat,0:18],-alog10(Pressure[Indlon,Indlat,0:18]),-alog10(700.))
endif

if (pref_sta(i) eq 'spo') then begin
out=interpol(CO[Indlon,Indlat,0:18],-alog10(Pressure[Indlon,Indlat,0:18]),-alog10(900.))
endif

if (pref_sta(i) eq 'lef') then begin
out=interpol(CO[Indlon,Indlat,0:18],-alog10(Pressure[Indlon,Indlat,0:18]),-alog10(900.))
endif

if (pref_sta(i) eq 'uum') then begin
out=interpol(CO[Indlon,Indlat,0:18],-alog10(Pressure[Indlon,Indlat,0:18]),-alog10(900.))
endif

if (pref_sta(i) eq 'uta') then begin
out=interpol(CO[Indlon,Indlat,0:18],-alog10(Pressure[Indlon,Indlat,0:18]),-alog10(900.))
endif

if (pref_sta(i) eq 'cui') then begin
out=interpol(CO[Indlon,Indlat,0:18],-alog10(Pressure[Indlon,Indlat,0:18]),-alog10(900.))
endif

if (pref_sta(i) eq 'wlg') then begin
out=interpol(CO[Indlon,Indlat,0:18],-alog10(Pressure[Indlon,Indlat,0:18]),-alog10(600.))
endif

  fileout = strtrim(name_sta(i),2)+ext

  ; Now save FILEOUT to /temp directory (bmy, 8/13/03)
  fileout = 'temp/' + fileout
  ;print, fileout


  ;print, i
  iunit = i+50
if j eq 1 then begin  openw,iunit,fileout
endif

     printf, iunit, out

endfor
  close, iunit
endfor


close,/all

close_device

end
