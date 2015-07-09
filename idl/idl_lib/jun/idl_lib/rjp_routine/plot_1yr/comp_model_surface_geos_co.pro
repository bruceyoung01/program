; $Id: comp_model_surface_geos_co.pro,v 1.2 2003/12/08 19:34:53 bmy Exp $
pro comp_model_surface_geos_co,dir, pref,ptop,dlat,dlon,ext

Species='CO'

filest=''
filest='Sites.ground.'+Species+'.1' ;input data about stations

;PRINT, filest
openr, usta, filest, /get_lun
iname_sta=''
ititle_sta=''
ipref_sta=''

mmonth = strarr(12)
mmonth=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']


; Specify directory with surface data 

            pre = '/users/trop/iam/cmdl/newdata/'

; --- read station & indice ---

; Set max_sta parameter
max_sta=39 ;real

; Read in information about stations to be plotted -
; 3-letter name(capital), station name, latitude and longitude

name_sta = strarr(max_sta)
lon_sta      = fltarr(max_sta)
lat_sta      = fltarr(max_sta)
title_sta = strarr(max_sta)
pref_sta = strarr(max_sta)

for i=0,max_sta-1 do begin
    readf,usta, iname_sta,ititle_sta,  ilat, ilon, ipref_sta,        $
                format='(2x,a3,7x,a15,2x,f6.2,3x,f6.2,4x,a3)'
    ;print,      iname_sta, ititle_sta, ilat, ilon, ipref_sta,    $
                format='(2x,a3,7x,a15,2x,f6.2,3x,f6.2,4x,a3)'
    name_sta(i) = iname_sta
    lon_sta(i)      = ilon
    lat_sta(i)      = ilat
    title_sta(i) = ititle_sta
    pref_sta[i] = ipref_sta
endfor


; ---  open files ---

ncount=0

; Name for output file
   fileout = 'Ground.CO.stations.geos.statistics'+ext
   
   ; Now write FILEOUT to temp/ directory (bmy, 8/13/03)
   fileout = 'temp/' + fileout

   iunit = 50
   openw,iunit,fileout
      printf, iunit, 'sta_name sta_code model mean_bias_pr mean_bias mean_bias_std  mean_abs_bias  stat1 stat2 max_agreement min_agreement amplitude  amplitude_cmdl'

; --- loop for stations ---
for k = 1, max_sta do begin

ncount=ncount+1
 ;print, 'STATION : ', k
    kk = k-1 
    ix = k
    file=''

    file=pre+pref_sta(kk)+'.mn'

    ilun = k+50
    openr,ilun,file

    maxd = 12
    comean   = fltarr(maxd)
    comedian = fltarr(maxd)
    costd    = fltarr(maxd)
    conum    = fltarr(maxd)
    comin    = fltarr(maxd)
    comax    = fltarr(maxd)

 for i=0,11 do begin
       readf,ilun,                                             $
              icomean, icostd,inum, icomin, icomax,icomedian    
       conum(i)    = inum
       comean(i)   = icomean
       comedian(i) = icomedian
       costd(i)    = icostd
       comin(i)    =icomin
       comax(i)    =icomax
 endfor
    close, ilun
;;print, comean

; Put longitude in (-180,180) range

if lon_sta(kk) gt 180 then lon_sta(kk)=lon_sta(kk)-360

; Read data from geos model

   out_geos=fltarr(12)

 for i=0,11 do begin
   mn=strtrim(String(fix(i+1)),2)
   if (strlen(mn) eq 1) then begin

      mn='0'+mn
   endif
   name=dir+pref+mn+'01.nc'


   ;=================================================================
   ; Read 3-D CO
   ; return LAT & lon from the file
   ;=================================================================
   CO = Get_Species_Geos( name, Date=Date, $
                       Species='IJ-AVG-$::CO', Lat=Lat, Lon=Lon )
   Pressure = Get_Pressure_Geos( Name, PTOP=PTOP, Lat=Lat, Lon=Lon )

;   Now select proper box

   Indlat = Where( Lat ge lat_sta(kk)-dlat/2 and Lat le lat_sta(kk)+dlat/2 )
   Indlon = Where( Lon ge lon_sta(kk)-dlon/2 and Lon le lon_sta(kk)+dlon/2 )

;print, lon_sta(kk)
;print, lon
;print, indlon
;print, indlat

   CO_box = CO[Indlon,Indlat,0]
   Pressure_box = Pressure[Indlon,Indlat,0]

;print, CO_box
;print, Pressure_box

;print, i , CO_box
out_geos[i]=CO_box

 endfor

close,/all
  openw,iunit,fileout,/append

; Now calculate mean bias for geos model

bias_geos=out_geos-comean
bias_geos_pr=(out_geos-comean)/comean*100
mean_bias_geos_pr=mean(bias_geos_pr)

std_bias_geos=stddev(bias_geos)/sqrt(12)
mean_bias_geos=mean(bias_geos)
abs_mean_bias_geos=mean(abs(bias_geos))

; Now calculate how close the model is to data stddev
l1=0.0
l2=0.0
for i=0,11 do begin

if (abs(comean[i]-out_geos[i]) gt costd[i] and abs(comean[i]-out_geos[i]) lt 2*costd[i]) then l1=l1+0.25    
if (abs(comean[i]-out_geos[i]) le costd[i]) then l1=l1+1    	

if (abs((comean[i]-out_geos[i])/comean[i]*100) gt 20 and abs((comean[i]-out_geos[i])/comean[i]*100) le 40) then l2=l2+0.25 
if (abs((comean[i]-out_geos[i])/comean[i]*100) gt 10 and abs((comean[i]-out_geos[i])/comean[i]*100) le 20) then l2=l2+0.5 
if (abs((comean[i]-out_geos[i])/comean[i]*100) le 10) then l2=l2+1 

endfor

l1=l1/12
l2=l2/12

; Calculate maximum and minimum for the model and data, measure how far
; apart they are, also amplitude (max-min)

max_geos=max(out_geos)
min_geos=min(out_geos)
max_comean=max(comean)
min_comean=min(comean)

amp_geos=max_geos-min_geos
amp_comean=max_comean-min_comean

; Find months for minimum and maximum for both model and data

for i=0,11 do begin
if (comean[i] eq max_comean) then m1_comean=i+1
if (comean[i] eq min_comean) then m2_comean=i+1
if (out_geos[i] eq max_geos) then m1_geos=i+1
if (out_geos[i] eq min_geos) then m2_geos=i+1
endfor

l3=0
l4=0

if (abs(m1_comean-m1_geos) eq 0 or abs(m1_comean-m1_geos) eq 1 or abs(m1_comean-m1_geos) eq 11) then l3=l3+1
if (abs(m1_comean-m1_geos) eq 2 or abs(m1_comean-m1_geos) eq 10) then l3=l3+0.5

if (abs(m2_comean-m2_geos) eq 0 or abs(m2_comean-m2_geos) eq 1 or abs(m2_comean-m2_geos) eq 11) then l4=l4+1
if (abs(m2_comean-m2_geos) eq 2 or abs(m2_comean-m2_geos) eq 10) then l4=l4+0.5


    printf, iunit, title_sta(kk),name_sta(kk),'geos',mean_bias_geos_pr,mean_bias_geos,std_bias_geos,abs_mean_bias_geos,l1,l2,l3,l4,amp_geos,amp_comean,format='(a15,1x,a3,2x,a6,2x,f6.2,2x,f7.2,2x,f6.2,2x,f6.2,2x,f6.4,2x,f6.4,2x,f3.1,2x,f3.1,2x,f6.2,2x,f7.2)'



endfor


close, /all

end


