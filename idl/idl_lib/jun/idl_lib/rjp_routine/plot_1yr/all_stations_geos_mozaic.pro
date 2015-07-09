; $Id: all_stations_geos_mozaic.pro,v 1.2 2005/03/10 15:52:13 bmy Exp $
pro all_stations_geos_mozaic, species1, species, max_sta, pref, $
                              indyear,  ptop,    ext,     nalt

   ; NOTE: Now pass NALT via the arg. Also now uses
   ;       GET_SPECIES_GEOS and GET_PRESSURE_GEOS, which can
   ;       read from either GEOS-3 or GEOS-4 met fields. (bmy, 3/7/05)

   ;=========================================================================
   ; Open MOZAIC file and read information
   ;=========================================================================

   filest='/users/trop/iam/netCDF/'+species1+'.stations.selected.mozaic.1'
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
      name_sta(i) = iname_sta
      month(i)    = imonth
      lol(i)      = ilol
      lor(i)      = ilor
      lad(i)      = ilad
      lau(i)      = ilau
      H(i)        = iH
      year(i)     = iyear  
   endfor
 
   ;========================================================================
   ; Now extract proper profile for the stations
   ; proper name will be given later, now we read from just one file
   ;========================================================================

   for i=0,max_sta-1 do begin

      ; Month name
      mn=strtrim(String(month[i]),2)
      mn=strtrim(String(fix(month[i])),2)

      if (strlen(mn) eq 1) then begin
         mn='0'+mn
      endif
      name=pref+mn+'01.nc'

      ; Year name
      if (indyear eq 1)  then begin
         yr=Strtrim(String(fix(year[i]+1900)),1)
         if (year[i] lt 50) then begin
            yr=Strtrim(String(fix(year[i]+2000)),1)
         endif
         name=pref+yr+mn+'01.nc'
      endif

      ;=================================================================
      ; Read O3 from the file
      ;=================================================================

      ; Get O3
      O3 = Get_Species_Geos( name, Date=Date, $
                             Species=Species, Lat=Lat, Lon=Lon )

      ; Get pressure
      Pressure = Get_Pressure_Geos( Name, PTOP=PTOP, Lat=Lat, Lon=Lon )

      ; Put LON into the range [-180,180]
      Ind = Where( Lon gt 180 )

      ; Now select boxes we want; use information read from input file
      Indlat = Where( Lat ge lad[i] and Lat le lau[i] )
      Indlon = Where( Lon ge lol[i] and Lon le lor[i] )
      if lol[i] gt lor[i] $
         then Indlon = Where( ( Lon ge lol[i] and Lon lt 360)$
                           or ( Lon ge 0 and Lon le lor[i] ))

      O3_box = O3[Indlon,Indlat,*]
      Pressure_box = Pressure[Indlon,Indlat,*]

      Ozone=fltarr(Nalt)
      Col=fltarr(Nalt)

      for j=0,Nalt-1 do begin
         Ozone[j]=mean(O3_box[*,*,j])
         Col[j]=mean( Pressure_box [*,*,j]) 
      endfor

      ;=================================================================
      ; Write to station file in the temp subdirectory
      ;=================================================================

      ; Write to file
      fileout = 'temp/' + strtrim(name_sta(i),2)+ext
      iunit = i+50
      openw,iunit,fileout

      for n = 0, Nalt-1 do begin
         printf, iunit, Col[n] , Ozone[n]
      endfor
      close, iunit
   endfor

   close,/all
   
   close_device

end
