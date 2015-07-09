; $Id: all_stations_ships_geos.pro,v 1.2 2003/12/08 19:34:53 bmy Exp $
pro all_stations_ships_geos, species1, species, max_sta, pref, indyear,ptop,ext


filest='/users/trop/iam/netCDF/'+species1+'.ships'
;PRINT, filest
openr, usta, filest, /get_lun
iname_sta=''
ititle_sta=''

name_sta = strarr(max_sta)
month    = strarr(max_sta)
lol      = fltarr(max_sta)
lor      = fltarr(max_sta)
lad      = fltarr(max_sta)
lau      = fltarr(max_sta)
H        = fltarr(max_sta)
year     = intarr(max_sta)

for i=0,max_sta-1 do begin
    readf,usta, iname_sta,                  $
                ilol, ilor, ilad, ilau,          $
                imonth , iH, iyear, ititle_sta,         $
                format='(a36,1x,i4,1x,i4,1x,i4,1x,i4,1x,i4,1x,i4,1x,i2,1x,a20)'
    ;print,      iname_sta,                  $
    ;            ilol, ilor, ilad, ilau,     $
    ;            imonth , iH, iyear, ititle_sta,    $
    ;            format='(a36,1x,i4,1x,i4,1x,i4,1x,i4,1x,i4,1x,i4,1x,i2,1x,a20)'
    name_sta(i) = iname_sta
    month(i)    = imonth
    lol(i)      = ilol
    lor(i)      = ilor
    lad(i)      = ilad
    lau(i)      = ilau
    H(i)        = iH
    year(i)     = iyear  
endfor
 
;   Now extract proper profile for the stations
;   proper name will be given later, now we read from just one file

for i=0,max_sta-1 do begin

for j=1,12 do begin

   mn=strtrim(j,2)

   ;print, "************************"
   ;print, mn

if (strlen(mn) eq 1) then begin

      mn='0'+mn
   endif
   name=pref+mn+'01.nc'

   ;=================================================================
   ; Read 3-D O3 from netCDF file
   ; return LAT & lon from the file
   ;=================================================================
   O3 = Get_Species_Geos( name, Date=Date, $
                       Species=Species, Lat=Lat, Lon=Lon )

   ;print, 'MIN and MAX of O3: ', Min( O3, Max=M ), M

   ; Compute 3-D pressure from file
   ; return LAT & LON from the file
   Pressure = Get_Pressure_Geos( Name, PTOP=PTOP, Lat=Lat, Lon=Lon )
   ;print, 'MIN and MAX of pressure: ', Min( Pressure, Max=M ), M

   ; Shift O3
;   N_Lon = N_Elements( Lon )
;   O3  = Shift( O3, N_Lon/2L, 0, 0 )
;   Lon   = Shift( Lon,  N_Lon/2L )
;   Pressure = Shift( Pressure,N_Lon/2L )

   ; Put LON into the range [-180,180]
   Ind = Where( Lon gt 180 )
;   Lon[Ind] = Lon[Ind] - 360.0

;   ;print, O3[*,0,0]

;   if lol[i] lt 0 then lol[i]=lol[i]+360
;   if lor[i] lt 0 then lor[i]=lor[i]+360

; Now select boxes we want; use information read from input file
   Indlat = Where( Lat ge lad[i] and Lat le lau[i] )
   Indlon = Where( Lon ge lol[i] and Lon le lor[i] )
   if lol[i] gt lor[i] then Indlon = Where( ( Lon ge lol[i] and Lon lt 360)$
                                         or ( Lon ge 0 and Lon le lor[i] ))

;print, indlon
;print, indlat
   O3_box = O3[Indlon,Indlat,*]
   Pressure_box = Pressure[Indlon,Indlat,*]

Ozone=mean(O3_box[*,*,0])

  fileout = strtrim(name_sta(i),2)+ext

  ; Now save FILEOUT to 'temp/' directory (bmy, 8/13/03)
  fileout = 'temp/' + fileout
  ;print, fileout


  ;print, i
  iunit = i+50
if j eq 1 then begin  openw,iunit,fileout
endif

     printf, iunit, Ozone

endfor
  close, iunit
endfor


close,/all

close_device

end
