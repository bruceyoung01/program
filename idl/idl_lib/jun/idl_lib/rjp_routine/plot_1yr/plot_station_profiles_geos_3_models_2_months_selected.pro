pro plot_station_profiles_geos_3_models_2_months_selected, mon1, mon2, mon3, mon4,$
                                pref1, ptop1, dlat1, dlon1, nalt1, $
                                pref2, ptop2, dlat2, dlon2, nalt2, $
                                pref3, ptop3, dlat3, dlon3, nalt3, $
                                title, psname, max_station, filest
set_plot,'x'
set_plot,'ps'

; Open postscript file
open_device, olddevice,/ps,/color,filename=psname,/portrait

!X.OMARGIN=[12,8] 
!Y.OMARGIN=[35,8]
!X.MARGIN=[0,0]
!Y.MARGIN=[0,0]
!P.CHARTHICK=3
!P.THICK=3.5
!X.THICK=4
!Y.THICK=4
; now set up plotting parameters
nrow=4
ncol=2
!P.Multi = [0,nrow,ncol,0,1]

name_sta=''
num_sta=''
pref_sta=''

num_station=strarr(max_station)
name_station=strarr(max_station)
pref_station=strarr(max_station)
lat_station=strarr(max_station)
lon_station=strarr(max_station)
lat_station_1=strarr(max_station)
lon_station_1=strarr(max_station)

; Now read in information about stations

; Define input file

;filest='/users/trop/iam/netCDF/Sites.O3.prof.1'
;filest='Sites.O3.prof.res.kag.sam'
PRINT, filest

; Read in input station abbriviation, name, latitude, longitude and number

openr, usta, filest, /get_lun
for i=0,max_station-1 do begin
    readf,usta, pref_sta,                  $
                name_sta, lat_sta,         $
                lon_sta,num_sta,         $
                format='(2x,a3,9x,a16,1x,f6.2,3x,f6.2,3x,a3)'
;    print,      pref_sta,                  $
;                name_sta,lat_sta,     $
;                lon_sta,num_sta,    $
;                format='(2x,a3,9x,a16,1x,f6.2,3x,f6.2,3x,a3)'
    pref_station(i) = pref_sta
    name_station(i) = name_sta
    lat_station(i) = lat_sta
    lon_station(i) = lon_sta
    lat_station_1(i) = round(lat_sta)
    lon_station_1(i) = round(lon_sta)

    num_station(i) = num_sta

endfor

; for test purpouses only, should be input parameters
;mon1=1
;mon2=4
;mon3=7
;mon4=10

month=strarr(12)
month=["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"]


   pressure_sonde=fltarr(35)
   pressure_sonde=[926.12,794.33,681.29,584.34,501.19,429.87,368.69,$
                   316.22,271.23,232.63,199.52,171.13,146.78,125.89,$
                   107.98,92.61,79.43,68.13,58.44,50.12,42.99,36.87,$
                   31.63,27.12,23.26,19.95,17.11,14.68,12.59,10.80,$
                   9.26,7.95,6.81,5.84,5.01]

; Describe arrays for model results

mod1=fltarr(20)
mod2=fltarr(20)
mod3=fltarr(20)
mod4=fltarr(20)


ncount=0

; Main loop over stations

for i=0,max_station-1 do begin

ncount=ncount+1

; Put longitude in (-180,180) range

if lon_station_1(i) gt 180 then lon_station_1(i)=lon_station_1(i)-360
if lon_station(i) gt 180 then lon_station(i)=lon_station(i)-360

; Get names of sonde and models files

name_sonde='/users/trop/iam/sondes.for.gmi/sonde'+num_station(i)

   mn1=strtrim(String(fix(mon1)),2)
   if (strlen(mn1) eq 1) then begin
      mn1='0'+mn1
   endif
   name1=pref1+mn1+'01.nc'
   name1_2=pref2+mn1+'01.nc'
   name1_3=pref3+mn1+'01.nc'

   mn2=strtrim(String(fix(mon2)),2)
   if (strlen(mn2) eq 1) then begin
      mn2='0'+mn2
   endif
   name2=pref1+mn2+'01.nc'
   name2_2=pref2+mn2+'01.nc'
   name2_3=pref3+mn2+'01.nc'

   mn3=strtrim(String(fix(mon3)),2)
   if (strlen(mn3) eq 1) then begin
      mn3='0'+mn3
   endif
   name3=pref1+mn3+'01.nc'
   name3_2=pref2+mn3+'01.nc'
   name3_3=pref3+mn3+'01.nc'

   mn4=strtrim(String(fix(mon4)),2)
   if (strlen(mn4) eq 1) then begin
      mn4='0'+mn4
   endif
   name4=pref1+mn4+'01.nc'
   name4_2=pref2+mn4+'01.nc'
   name4_3=pref3+mn4+'01.nc'

; Now read sonde means and standard deviations

print, name_sonde
print, name1
print, name2
print, name3
print, name4

read_sondes,name_sonde, mon1, mon2, mon3, mon4,sonde1, std1, sonde2, std2,$
                 sonde3, std3, sonde4,std4

   if (lon_station(i) eq 178 and dlon1 eq 5) then lon_station(i)=-182
   O3 = Get_Species_Geos( name1, Date=Date, $
                       Species='IJ-AVG-$::Ox', Lat=Lat, Lon=Lon )
   Pressure = Get_Pressure_Geos( Name1, PTOP=PTOP1, Lat=Lat, Lon=Lon )

;   Now select proper box

   Indlat = Where( Lat ge lat_station(i)-dlat1/2 and Lat le lat_station(i)+dlat1/2 )
   Indlon = Where( Lon ge lon_station(i)-dlon1/2 and Lon le lon_station(i)+dlon1/2 )


print,Indlon
print,Indlat 

   O3_box = O3[Indlon,Indlat,*]
   Pressure_box = Pressure[Indlon,Indlat,*]

Nalt=nalt1 
Ozone=fltarr(Nalt)
pres=fltarr(Nalt)
for j=0,Nalt-1 do begin
   Ozone[j]=mean(O3_box[*,*,j])
   Pres[j]=mean( Pressure_box [*,*,j]) 
endfor

mod1 = Ozone
pressure1 = Pres
print, mod1
print, pressure1

   O3 = Get_Species_Geos( name4, Date=Date, $
                       Species='IJ-AVG-$::Ox', Lat=Lat, Lon=Lon )
   Pressure = Get_Pressure_Geos( Name4, PTOP=PTOP1, Lat=Lat, Lon=Lon )


;   Now select proper box

   Indlat = Where( Lat ge lat_station(i)-dlat1/2 and Lat le lat_station(i)+dlat1/2 )
   Indlon = Where( Lon ge lon_station(i)-dlon1/2 and Lon le lon_station(i)+dlon1/2)

   O3_box = O3[Indlon,Indlat,*]
   Pressure_box = Pressure[Indlon,Indlat,*]

Ozone=fltarr(Nalt)
pres=fltarr(Nalt)
for j=0,Nalt-1 do begin
   Ozone[j]=mean(O3_box[*,*,j])
   Pres[j]=mean( Pressure_box [*,*,j]) 
endfor

mod4 = Ozone
pressure4 = Pres

   O3 = Get_Species_Geos( name2, Date=Date, $
                       Species='IJ-AVG-$::Ox', Lat=Lat, Lon=Lon )
   Pressure = Get_Pressure_Geos( Name2, PTOP=PTOP1, Lat=Lat, Lon=Lon )

;   Now select proper box

   Indlat = Where( Lat ge lat_station(i)-dlat1/2 and Lat le lat_station(i)+dlat1/2 )
   Indlon = Where( Lon ge lon_station(i)-dlon1/2 and Lon le lon_station(i)+dlon1/2 )


   O3_box = O3[Indlon,Indlat,*]
   Pressure_box = Pressure[Indlon,Indlat,*]

Ozone=fltarr(Nalt)
pres=fltarr(Nalt)
for j=0,Nalt-1 do begin
   Ozone[j]=mean(O3_box[*,*,j])
   Pres[j]=mean( Pressure_box [*,*,j]) 
endfor

mod2 = Ozone
pressure2 = Pres


   O3 = Get_Species_Geos( name3, Date=Date, $
                       Species='IJ-AVG-$::Ox', Lat=Lat, Lon=Lon )
   Pressure = Get_Pressure_Geos( Name3, PTOP=PTOP1, Lat=Lat, Lon=Lon )

;   Now select proper box

   Indlat = Where( Lat ge lat_station(i)-dlat1/2 and Lat le lat_station(i)+dlat1/2 )
   Indlon = Where( Lon ge lon_station(i)-dlon1/2 and Lon le lon_station(i)+dlon1/2 )


   O3_box = O3[Indlon,Indlat,*]
   Pressure_box = Pressure[Indlon,Indlat,*]

Ozone=fltarr(Nalt)
pres=fltarr(Nalt)
for j=0,Nalt-1 do begin
   Ozone[j]=mean(O3_box[*,*,j])
   Pres[j]=mean( Pressure_box [*,*,j]) 
endfor

mod3 = Ozone
pressure3 = Pres
   if (lon_station(i) eq -182) then lon_station(i)=178
; Now do the plot

ind1 = Where(pressure1 ge 200)
ind2 = Where(pressure2 ge 200)
ind3 = Where(pressure3 ge 200)
ind4 = Where(pressure4 ge 200)

inds1 = Where(pressure_sonde ge 200 and sonde1 gt 0)
inds2 = Where(pressure_sonde ge 200 and sonde2 gt 0)
inds3 = Where(pressure_sonde ge 200 and sonde3 gt 0)
inds4 = Where(pressure_sonde ge 200 and sonde4 gt 0)

; Select data below 200 mbar


pressure1_p=pressure1[ind1]
pressure2_p=pressure2[ind2]
pressure3_p=pressure3[ind3]
pressure4_p=pressure4[ind4]
pressure_sonde1_p=pressure_sonde[inds1]
pressure_sonde2_p=pressure_sonde[inds2]
pressure_sonde3_p=pressure_sonde[inds3]
pressure_sonde4_p=pressure_sonde[inds4]


mod1_p=mod1[ind1]
mod2_p=mod2[ind2]
mod3_p=mod3[ind3]
mod4_p=mod4[ind4]

   if (lon_station(i) eq 178 and  dlon3 eq 5) then lon_station(i)=-182

   O3 = Get_Species_Geos( name1_3, Date=Date, $
                       Species='IJ-AVG-$::Ox', Lat=Lat, Lon=Lon )
   Pressure = Get_Pressure_Geos( Name1_3, PTOP=PTOP3, Lat=Lat, Lon=Lon )

;   Now select proper box

   Indlat = Where( Lat ge lat_station(i)-dlat3/2 and Lat le lat_station(i)+dlat3/2 )
   Indlon = Where( Lon ge lon_station(i)-dlon3/2 and Lon le lon_station(i)+dlon3/2 )


print,Indlon
print,Indlat 
   O3_box = O3[Indlon,Indlat,*]
   Pressure_box = Pressure[Indlon,Indlat,*]

Nalt=nalt3 
Ozone=fltarr(Nalt)
pres=fltarr(Nalt)
for j=0,Nalt-1 do begin
   Ozone[j]=mean(O3_box[*,*,j])
   Pres[j]=mean( Pressure_box [*,*,j]) 
endfor

mod1_3 = Ozone
pressure1_3 = Pres
print, mod1_3
print, pressure1_3

   O3 = Get_Species_Geos( name4_3, Date=Date, $
                       Species='IJ-AVG-$::Ox', Lat=Lat, Lon=Lon )
   Pressure = Get_Pressure_Geos( Name4_3, PTOP=PTOP3, Lat=Lat, Lon=Lon )


;   Now select proper box

   Indlat = Where( Lat ge lat_station(i)-dlat3/2 and Lat le lat_station(i)+dlat3/2 )
   Indlon = Where( Lon ge lon_station(i)-dlon3/2 and Lon le lon_station(i)+dlon3/2)

   O3_box = O3[Indlon,Indlat,*]
   Pressure_box = Pressure[Indlon,Indlat,*]

Ozone=fltarr(Nalt)
pres=fltarr(Nalt)
for j=0,Nalt-1 do begin
   Ozone[j]=mean(O3_box[*,*,j])
   Pres[j]=mean( Pressure_box [*,*,j]) 
endfor

mod4_3 = Ozone
pressure4_3 = Pres

   O3 = Get_Species_Geos( name2_3, Date=Date, $
                       Species='IJ-AVG-$::Ox', Lat=Lat, Lon=Lon )
   Pressure = Get_Pressure_Geos( Name2_3, PTOP=PTOP3, Lat=Lat, Lon=Lon )

;   Now select proper box

   Indlat = Where( Lat ge lat_station(i)-dlat3/2 and Lat le lat_station(i)+dlat3/2 )
   Indlon = Where( Lon ge lon_station(i)-dlon3/2 and Lon le lon_station(i)+dlon3/2 )


   O3_box = O3[Indlon,Indlat,*]
   Pressure_box = Pressure[Indlon,Indlat,*]

Ozone=fltarr(Nalt)
pres=fltarr(Nalt)
for j=0,Nalt-1 do begin
   Ozone[j]=mean(O3_box[*,*,j])
   Pres[j]=mean( Pressure_box [*,*,j]) 
endfor

mod2_3 = Ozone
pressure2_3 = Pres


   O3 = Get_Species_Geos( name3_3, Date=Date, $
                       Species='IJ-AVG-$::Ox', Lat=Lat, Lon=Lon )
   Pressure = Get_Pressure_Geos( Name3_3, PTOP=PTOP3, Lat=Lat, Lon=Lon )

;   Now select proper box

   Indlat = Where( Lat ge lat_station(i)-dlat3/2 and Lat le lat_station(i)+dlat3/2 )
   Indlon = Where( Lon ge lon_station(i)-dlon3/2 and Lon le lon_station(i)+dlon3/2 )


   O3_box = O3[Indlon,Indlat,*]
   Pressure_box = Pressure[Indlon,Indlat,*]

Ozone=fltarr(Nalt)
pres=fltarr(Nalt)
for j=0,Nalt-1 do begin
   Ozone[j]=mean(O3_box[*,*,j])
   Pres[j]=mean( Pressure_box [*,*,j]) 
endfor

mod3_3 = Ozone
pressure3_3 = Pres

; Now do the plot

ind1 = Where(pressure1_3 ge 200)
ind2 = Where(pressure2_3 ge 200)
ind3 = Where(pressure3_3 ge 200)
ind4 = Where(pressure4_3 ge 200)

inds = Where(pressure_sonde ge 200)

; Select data below 200 mbar


pressure1_3_p=pressure1_3[ind1]
pressure2_3_p=pressure2_3[ind2]
pressure3_3_p=pressure3_3[ind3]
pressure4_3_p=pressure4_3[ind4]
pressure_sonde_p=pressure_sonde[inds]

mod1_3_p=mod1_3[ind1]
mod2_3_p=mod2_3[ind2]
mod3_3_p=mod3_3[ind3]
mod4_3_p=mod4_3[ind4]

   if (lon_station(i) eq -182) then lon_station(i)=178
   if (lon_station(i) eq 178 and dlon2 eq 5) then lon_station(i)=-182

   O3 = Get_Species_Geos( name1_2, Date=Date, $
                       Species='IJ-AVG-$::Ox', Lat=Lat, Lon=Lon )
   Pressure = Get_Pressure_Geos( Name1_2,  PTOP=PTOP2, Lat=Lat, Lon=Lon )

;   Now select proper box

   Indlat = Where( Lat ge lat_station(i)-dlat2/2 and Lat le lat_station(i)+dlat2/2 )
   Indlon = Where( Lon ge lon_station(i)-dlon2/2 and Lon le lon_station(i)+dlon2/2 )


print,Indlon
print,Indlat
print,  lon_station(i)
print, Lon 

   O3_box = O3[Indlon,Indlat,*]
   Pressure_box = Pressure[Indlon,Indlat,*]

Nalt=nalt2

print, nalt
for j=0,Nalt-1 do begin
   Ozone[j]=mean(O3_box[*,*,j])
   Pres[j]=mean( Pressure_box [*,*,j]) 
endfor

mod1_2 = Ozone
pressure1_2 = Pres

   O3 = Get_Species_Geos( name4_2, Date=Date, $
                       Species='IJ-AVG-$::Ox', Lat=Lat, Lon=Lon )
   Pressure = Get_Pressure_Geos( Name4_2, PTOP=PTOP2, Lat=Lat, Lon=Lon )


;   Now select proper box

   Indlat = Where( Lat ge lat_station(i)-dlat2/2 and Lat le lat_station(i)+dlat2/2 )
   Indlon = Where( Lon ge lon_station(i)-dlon2/2 and Lon le lon_station(i)+dlon2/2)

   O3_box = O3[Indlon,Indlat,*]
   Pressure_box = Pressure[Indlon,Indlat,*]

for j=0,Nalt-1 do begin
   Ozone[j]=mean(O3_box[*,*,j])
   Pres[j]=mean( Pressure_box [*,*,j]) 
endfor

mod4_2 = Ozone
pressure4_2 = Pres

   O3 = Get_Species_Geos( name2_2, Date=Date, $
                       Species='IJ-AVG-$::Ox', Lat=Lat, Lon=Lon )
   Pressure = Get_Pressure_Geos( Name2_2, PTOP=PTOP2, Lat=Lat, Lon=Lon )

;   Now select proper box

   Indlat = Where( Lat ge lat_station(i)-dlat2/2 and Lat le lat_station(i)+dlat2/2 )
   Indlon = Where( Lon ge lon_station(i)-dlon2/2 and Lon le lon_station(i)+dlon2/2 )


   O3_box = O3[Indlon,Indlat,*]
   Pressure_box = Pressure[Indlon,Indlat,*]

for j=0,Nalt-1 do begin
   Ozone[j]=mean(O3_box[*,*,j])
   Pres[j]=mean( Pressure_box [*,*,j]) 
endfor

mod2_2 = Ozone
pressure2_2 = Pres


   O3 = Get_Species_Geos( name3_2, Date=Date, $
                       Species='IJ-AVG-$::Ox', Lat=Lat, Lon=Lon )
   Pressure = Get_Pressure_Geos( Name3_2, PTOP=PTOP2, Lat=Lat, Lon=Lon )

;   Now select proper box

   Indlat = Where( Lat ge lat_station(i)-dlat2/2 and Lat le lat_station(i)+dlat2/2 )
   Indlon = Where( Lon ge lon_station(i)-dlon2/2 and Lon le lon_station(i)+dlon2/2 )


   O3_box = O3[Indlon,Indlat,*]
   Pressure_box = Pressure[Indlon,Indlat,*]

for j=0,Nalt-1 do begin
   Ozone[j]=mean(O3_box[*,*,j])
   Pres[j]=mean( Pressure_box [*,*,j]) 
endfor

mod3_2 = Ozone
pressure3_2 = Pres

; Now do the plot

ind1 = Where(pressure1 ge 200)
ind2 = Where(pressure2 ge 200)
ind3 = Where(pressure3 ge 200)
ind4 = Where(pressure4 ge 200)

inds1 = Where(pressure_sonde ge 200 and sonde1>0)
inds2 = Where(pressure_sonde ge 200 and sonde2>0)
inds3 = Where(pressure_sonde ge 200 and sonde3>0)
inds4 = Where(pressure_sonde ge 200 and sonde4>0)

; Select data below 200 mbar


pressure1_p=pressure1[ind1]
pressure2_p=pressure2[ind2]
pressure3_p=pressure3[ind3]
pressure4_p=pressure4[ind4]
pressure1_2_p=pressure1_2[ind1]
pressure2_2_p=pressure2_2[ind2]
pressure3_2_p=pressure3_2[ind3]
pressure4_2_p=pressure4_2[ind4]

pressure_sonde1_p=pressure_sonde[inds1]
pressure_sonde2_p=pressure_sonde[inds2]
pressure_sonde3_p=pressure_sonde[inds3]
pressure_sonde4_p=pressure_sonde[inds4]


mod1_p=mod1[ind1]
mod2_p=mod2[ind2]
mod3_p=mod3[ind3]
mod4_p=mod4[ind4]

mod1_2_p=mod1_2[ind1]
mod2_2_p=mod2_2[ind2]
mod3_2_p=mod3_2[ind3]
mod4_2_p=mod4_2[ind4]

sonde1_p=sonde1[inds1]
sonde2_p=sonde2[inds2]
sonde3_p=sonde3[inds3]
sonde4_p=sonde4[inds4]
std1_p=std1[inds1]
std2_p=std2[inds2]
std3_p=std3[inds3]
std4_p=std4[inds4]

loval=0

highval1=160
highval2=160
highval3=160
highval4=160

; Now start plotting

print, lat_station(i)

; Create station title

    ltitle=''
    ltitle = strtrim(name_station(i),2)+'('+strtrim(string(fix(lat_station_1(i))),1)+')'

; Plot sonde data

  plot, sonde1_p, -alog10(pressure_sonde1_p), xstyle=1,ystyle=5,$
    title=ltitle,linestyle=0,psym=-5,symsize=0.6,color=1,$ 
    xticks=8, min_val=-900, yrange=[-3,-alog10(200)], xrange=[loval,highval1],$
    charsize=1.8, xtickname=[' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' ]

  oplot,sonde1_p,-alog10(pressure_sonde1_p),linestyle=0,psym=6,symsize=0.6,$
          color=1 

; Add model results

  oplot, mod1_p,-alog10(pressure1_p),linestyle=0,psym=4,symsize=0.3,color=2 
  oplot, mod1_p,-alog10(pressure1_p),linestyle=0,color=2 
  oplot, mod1_2_p,-alog10(pressure1_2_p),linestyle=0,psym=4,symsize=0.3,color=3
  oplot, mod1_2_p,-alog10(pressure1_2_p),linestyle=0,color=3 
  oplot, mod1_3_p,-alog10(pressure1_3_p),linestyle=0,psym=4,symsize=0.3,color=4
  oplot, mod1_3_p,-alog10(pressure1_3_p),linestyle=0,color=4 

; Get pressure labels

pres=[1000,800,600,400,200]
logpres=-alog10(pres)
pres1=strtrim(string(pres),2)
pres1[1]=" "
pres2 = replicate(' ',n_elements(pres1))

pres1=strtrim(string(pres),2)
if ncount eq 1 or ncount eq 5 or ncount eq 9 or ncount eq 13 or ncount eq 17 or ncount eq 21 or ncount eq 25 or ncount eq 29 then begin  
  axis, loval, yaxis=0, yticks=12, yrange=[-3,-alog10(200)],$
      ytickv=logpres, ytickname=pres1,charsize=1.8,/ystyle,color=1
endif
if ncount ne 1 and ncount ne 5 and ncount and 9 or ncount and 13 and ncount ne 17 then begin  
  axis, loval, yaxis=1, yticks=12, yrange=[-3,-alog10(200)],$
      ytickv=logpres, ytickname=pres2, /ystyle ,color=1
endif
  axis, highval1, yaxis=1, yticks=12, yrange=[-3,-alog10(200)],$
      ytickv=logpres, ytickname=pres2, /ystyle ,color=1


; Put error bars (one standard deviation) for sonde data

      levs=n_elements(sonde1_p)
      for w = 0, levs-1 do begin
                 errbar = [sonde1_p(w)-std1(w), sonde1_p(w)+std1(w)]
          if  std1(w) gt 0 then begin
          oplot, errbar, [-alog10(pressure_sonde_p(w)),-alog10(pressure_sonde_p(w))],$
                 linestyle=0,color=1
       endif
       endfor

; Write the month on the plot

          xyouts,120,-alog10(240), month[mon1-1], charsize = 1, /data, color=1

; Second plot
  ltitle='' 

; Plot sonde data

  plot, sonde3_p, -alog10(pressure_sonde3_p), xstyle=1,ystyle=5,$
    title=ltitle,linestyle=0,psym=-5,symsize=0.6, color=1,$
    xticks=8, min_val=-900, yrange=[-3,-alog10(200)], xrange=[loval,highval3],$
    charsize=1.8, xtickname=[ ' ', ' ', '40', ' ','80', ' ', '120', ' ', '160']

  oplot,sonde3_p,-alog10(pressure_sonde3_p),linestyle=0,psym=6,symsize=0.6,$
  color=1 

; Add models results

  oplot, mod3_p,-alog10(pressure3_p),linestyle=0,psym=4,symsize=0.3,color=2 
  oplot, mod3_p,-alog10(pressure3_p),linestyle=0,color=2
  oplot, mod3_2_p,-alog10(pressure3_2_p),linestyle=0,psym=4,symsize=0.3,color=3
  oplot, mod3_2_p,-alog10(pressure3_2_p),linestyle=0,color=3
  oplot, mod3_3_p,-alog10(pressure3_3_p),linestyle=0,psym=4,symsize=0.3,color=4
  oplot, mod3_3_p,-alog10(pressure3_3_p),linestyle=0,color=4

; Add axes

if ncount eq 1 or ncount eq 5 or ncount eq 9 or ncount eq 13 or ncount eq 17 or ncount eq 21 or ncount eq 25 or ncount eq 29 then begin  
  axis, loval, yaxis=0, yticks=12, yrange=[-3,-alog10(200)],$
      ytickv=logpres, ytickname=pres1,charsize=1.8,/ystyle,color=1
endif
if ncount ne 1 and ncount ne 5 and ncount and 9 or ncount and 13 and ncount ne 17 then begin  
  axis, loval, yaxis=1, yticks=12, yrange=[-3,-alog10(200)],$
      ytickv=logpres, ytickname=pres2, /ystyle,color=1 
endif

  axis, highval3, yaxis=1, yticks=12, yrange=[-3,-alog10(200)],$
      ytickv=logpres, ytickname=pres2, /ystyle,color=1 


; Put error bars (one standard deviation) sonde data

      levs=n_elements(sonde3_p)
      for w = 0, levs-1 do begin
          errbar = [sonde3_p(w)-std3(w), sonde3_p(w)+std3(w)]
          if  std3(w) gt 0 then begin
          oplot, errbar, [-alog10(pressure_sonde_p(w)),-alog10(pressure_sonde_p(w))],$
                 linestyle=0,color=1
       endif
       endfor
          xyouts,120,-alog10(240), month[mon3-1], charsize = 1, /data, color=1
xyouts, 0.06, 0.70, 'Pressure (hPa)', /normal, align=0.5, orientation=90, charsize=1.2,color=1
;xyouts, 0.5, 0.05, 'O3 (ppb)', /normal, align=0.5, charsize=1.,color=1
xyouts, 0.5, 0.40, 'O3 (ppb)', /normal, align=0.5, charsize=1.,color=1
xyouts, 0.5, 0.96,title, /normal, align=0.5, charsize=1.2,color=1

endfor

close_device, /TIMESTAMP
close,/all
end
