; $Id: all_stations_geos_interp.pro,v 1.2 2003/12/08 19:34:52 bmy Exp $
pro all_stations_geos_interp, species1, species, max_sta, dir, pref, indyear,ptop,ext,nalt

filest=species1+'.stations'
;PRINT, filest
openr, usta, filest, /get_lun
iname_sta=''
ititle_sta=''

std_press=fltarr(18)
std_ozone=fltarr(18)
std_press=[954.37,845.34,746.62,657.46,577.11,504.91,440.2,382.38,330.87,285.12,244.64,208.94,177.58,150.14,126.25,105.53,87.65,72.31]

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
                ilol, ilor, ilad, ilau,     $
                imonth , iH, iyear, ititle_sta,    $
                format='(a36,1x,i4,1x,i4,1x,i4,1x,i4,1x,i4,1x,i4,1x,i2,1x,a20)'
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

   mn=strtrim(String(month[i]),2)
   mn=strtrim(String(fix(month[i])),2)

   ;print, mn
   ;print, year[i]
   if (strlen(mn) eq 1) then begin

      mn='0'+mn
   endif
   name=dir+pref+mn+'01.nc'

   if (indyear eq 1)  then begin
   yr=Strtrim(String(fix(year[i]+1900)),1)
      if (year[i] lt 50) then begin
         yr=Strtrim(String(fix(year[i]+2000)),1)
      endif
   name=dir+pref+yr+mn+'01.nc'
   endif

;print,  name


;   ;print,month[i]


   ;print, "************************"
   ;print, mn


   ;=================================================================
   ; Read 3-D O3 from gmit_maccm3_fj_mjja.const.nc'
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


;;print, lon
;;print, indlat
;;print, indlon

   O3_box = O3[Indlon,Indlat,*]
   Pressure_box = Pressure[Indlon,Indlat,*]
   ;;print, O3_box[*,*,0]
   ;;print, Pressure_box[*,*,0]
   ;;print, lad[i]
   ;;print, lau[i]
   ;;print, lol[i]
   ;;print, lor[i]

;Nalt=N_Elements(Pressure_box[0,0,*])
   ;;print, nalt
Ozone=fltarr(Nalt)
Col=fltarr(Nalt)

for j=0,Nalt-1 do begin
   Ozone[j]=mean(O3_box[*,*,j])
   Col[j]=mean( Pressure_box [*,*,j]) 
if (species1 eq 'H2O2') then begin
Ozone[j]=mean(O3_box[*,*,j])*1000.0
endif
endfor


std_ozone=interpol(Ozone,alog10(Col),alog10(std_press))
if (species1 eq 'C2H6') then begin
	std_ozone=interpol(Ozone,alog10(Col),alog10(std_press))/2
endif

if (species1 eq 'C3H8') then begin
	std_ozone=interpol(Ozone,alog10(Col),alog10(std_press))/3
endif

if (species1 eq 'ISOP') then begin
	std_ozone=interpol(Ozone,alog10(Col),alog10(std_press))/5
endif

   ;print, Ozone
;   ;print, Col

  fileout = strtrim(name_sta(i),2)+ext
  
  ; Now save FILEOUT to temp/ directory (bmy, 8/13/03)
  fileout = 'temp/' + fileout
  ;print, fileout

  ;print, i
  iunit = i+50
  openw,iunit,fileout

  for n = 0, 17 do begin
     printf, iunit, std_press[n] , std_ozone[n]
  endfor
  close, iunit
endfor


close,/all

close_device

end
