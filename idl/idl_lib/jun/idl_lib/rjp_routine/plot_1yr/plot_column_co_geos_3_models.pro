; $Id: plot_column_co_geos_3_models.pro,v 1.2 2003/12/08 19:34:57 bmy Exp $
pro plot_column_co_geos_3_models, pref1, ptop1, dlat1, dlon1, nalt1,$
                                   pref2, ptop2, dlat2, dlon2, nalt2,$
                                   pref3, ptop3, dlat3, dlon3, nalt3,$
                                   title, psname

; Plots annual CO column data (12 monthly means) vs. results of 3 model
; runs. Column data is black solid line, maccm3 model - red line, dao
; model -green line, giss model - blue line

!X.OMARGIN=[8,6] 
!Y.OMARGIN=[6,6]
!X.THICK=4
!Y.THICK=4
!P.CHARTHICK=2.5
!P.THICK=2.5

Species='CO'

; Get input file name

filest=''
filest='/users/trop/iam/netCDF/Sites.column.'+Species
;PRINT, filest
openr, usta, filest, /get_lun
iname_sta=''
ititle_sta=''
ipref_sta=''

mmonth = strarr(12)
mmonth=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']

; Open postscript file

open_device, olddevice,/ps,/color,filename=psname

; Set directory with "real" data

            pre = '/users/trop/iam/co.col.for.gmi/'

; --- read station & indice ---


max_sta=7

name_sta = strarr(max_sta)
lon      = fltarr(max_sta)
lat      = fltarr(max_sta)
pref_sta = strarr(max_sta)

for i=0,max_sta-1 do begin
    readf,usta, ipref_sta,iname_sta,  ilat, ilon,         $
                format='(2x,a3,7x,a12,5x,f6.2,3x,f6.2)'
    ;print,      ipref_sta, iname_sta, ilat, ilon,    $
    ;            format='(2x,a3,7x,a12,5x,f6.2,3x,f6.2)'
    name_sta(i) = iname_sta
    lon(i)      = round(ilon)
    lat(i)      = round(ilat)
    pref_sta[i] = ipref_sta
endfor


nrow=3
ncol=3
!P.Multi = [0,nrow,ncol,1,0]

; ---  open files ---

ncount=0

; Main loop (through stations)

for k = 1, max_sta do begin

ncount=ncount+1
 ;print, 'STATION : ', k
    kk = k-1 
    ix = k
    file=''

; Get filename

    file=pre+'CO.col.'+pref_sta(kk)

    maxd=12	
    ilun = k+50
    openr,ilun,file

    comean   = fltarr(maxd)
    costd   = fltarr(maxd)

 for i=0,11 do begin
       readf,ilun,                                             $
              imon,icomean, icostd    
       comean(i)   = icomean
       costd(i)   = icostd
 endfor
    close, ilun
;print, comean
if lon(kk) gt 180 then lon(kk)=lon(kk)-360
    ltitle=''
    ltitle = strtrim(name_sta(kk),2)+' ('+strtrim(string(fix(lat(kk))),1)+' ,'+strtrim(string(fix(lon(kk))),1)+' )'

; -- plot observed data --

; Get results from the first model model

 for i=0,11 do begin
   mn=strtrim(String(fix(i+1)),2)
   if (strlen(mn) eq 1) then begin

      mn='0'+mn
   endif
   name=pref1+mn+'01.nc'


   ;=================================================================
   ; Read 3-D CO
   ; return LAT & lon from the file
   ;=================================================================
   CO = Get_Species_Geos( name, Date=Date, $
                       Species='IJ-AVG-$::CO', Lat=Lat, Lon=Lon )
   Pressure = Get_Pressure_Geos( Name, PTOP=PTOP1, Lat=Lat, Lon=Lon )

;   Now select proper box

   Indlat = Where( Lat ge lat(kk)-dlat1/2 and Lat le lat(kk)+dlat1/2 )
   Indlon = Where( Lon ge lon(kk)-dlon1/2 and Lon le lon(kk)+dlon1/2 )


out1= fltarr(nalt1)
pressure1 = fltarr(nalt1)

   out1 = CO[Indlon,Indlat,*]
   pressure1 = Pressure[Indlon,Indlat,0:(nalt1-1)]
;if i eq 0 then begin print,out1
;endif
;if i eq 0 then begin print,pressure1
endif

endfor

; Get results from the second model

 for i=0,11 do begin
   mn=strtrim(String(fix(i+1)),2)
   if (strlen(mn) eq 1) then begin

      mn='0'+mn
   endif
   name=pref2+mn+'01.nc'


   ;=================================================================
   ; Read 3-D CO
   ; return LAT & lon from the file
   ;=================================================================
   CO = Get_Species_Geos( name, Date=Date, $
                       Species='IJ-AVG-$::CO', Lat=Lat, Lon=Lon )
   Pressure = Get_Pressure_Geos( Name, PTOP=PTOP2, Lat=Lat, Lon=Lon )

;   Now select proper box

   Indlat = Where( Lat ge lat(kk)-dlat2/2 and Lat le lat(kk)+dlat2/2 )
   Indlon = Where( Lon ge lon(kk)-dlon2/2 and Lon le lon(kk)+dlon2/2 )


out2= fltarr(nalt2)
pressure2 = fltarr(nalt2)

   out2 = CO[Indlon,Indlat,*]
   pressure2 = Pressure[Indlon,Indlat,0:(nalt2-1)]
;if i eq 0 then begin print,out2
;endif
;if i eq 0 then begin print,pressure2
endif

endfor

; Get results from the third model

 for i=0,11 do begin
   mn=strtrim(String(fix(i+1)),2)
   if (strlen(mn) eq 1) then begin

      mn='0'+mn
   endif
   name=pref3+mn+'01.nc'


   ;=================================================================
   ; Read 3-D CO
   ; return LAT & lon from the file
   ;=================================================================
   CO = Get_Species_Geos( name, Date=Date, $
                       Species='IJ-AVG-$::CO', Lat=Lat, Lon=Lon )
   Pressure = Get_Pressure_Geos( Name, PTOP=PTOP3, Lat=Lat, Lon=Lon )

;   Now select proper box

   Indlat = Where( Lat ge lat(kk)-dlat3/2 and Lat le lat(kk)+dlat3/2 )
   Indlon = Where( Lon ge lon(kk)-dlon3/2 and Lon le lon(kk)+dlon3/2 )


out3= fltarr(nalt3)
pressure3 = fltarr(nalt3)

   out3 = CO[Indlon,Indlat,*]
   pressure3 = Pressure[Indlon,Indlat,0:(nalt3-1)]
;if i eq 0 then begin print,out3
;endif
;if i eq 0 then begin print,pressure3
endif

endfor

; Now do the integration, remember, for different stations is should
; be done differently
; sum(co*deltap*2.12*10^16

; for now I integrate from the bottom to the top (for a test)

   pressure=fltarr(25) ; for final model?
   pressure=[1000,900,800,700,600,500,400,350,300,250,200,175,150,$
             125,100,90,80,70,60,50,40,30,20,15,10]
delta=[50,100,100,100,100,100,75,50,50,50,37.5,25,25,25,17.5,$
       10,10,10,10,10,10,10,7.5,5,2.5]


;print, delta
midpoint=fltarr(24)

for i=0,23 do begin
midpoint(i)=exp(1.0/2*(alog(pressure(i))+alog(pressure(i+1))))
endfor

delta(0)=1000-midpoint(0)
delta(24)=midpoint(23)-10

for i=1,23 do begin
delta(i)=midpoint(i-1)-midpoint(i)
endfor
;print, delta

co_data=fltarr(12)
std_data=fltarr(12)

co_data_dao=fltarr(12)
std_dat_daoa=fltarr(12)

co_data_giss=fltarr(12)
std_data_giss=fltarr(12)

; For diffent stations integration is done to provede the closest
; match to the data; for different stations column is measured differently

if pref_sta[kk] eq 'RIK' or pref_sta[kk] eq 'MOS' then begin 
for i=0,11 do begin
for j=0,10 do begin
co_data[i]=co_data[i]+out[i,j]*delta[j]*2.12*10.0^22
co_data_dao[i]=co_data_dao[i]+out_dao[i,j]*delta[j]*2.12*10.0^22
co_data_giss[i]=co_data_giss[i]+out_giss[i,j]*delta[j]*2.12*10.0^22
endfor
endfor
endif

if pref_sta[kk] eq 'JUN' then begin 
for i=0,11 do begin
for j=4,24 do begin
co_data[i]=co_data[i]+out[i,j]*delta[j]*2.12*10.0^22
co_data_dao[i]=co_data_dao[i]+out_dao[i,j]*delta[j]*2.12*10.0^22
co_data_giss[i]=co_data_giss[i]+out_giss[i,j]*delta[j]*2.12*10.0^22
endfor
endfor
endif

if pref_sta[kk] eq 'KPA' then begin 
for i=0,11 do begin
for j=2,12 do begin
co_data[i]=co_data[i]+out[i,j]*delta[j]*2.12*10.0^22
co_data_dao[i]=co_data_dao[i]+out_dao[i,j]*delta[j]*2.12*10.0^22
co_data_giss[i]=co_data_giss[i]+out_giss[i,j]*delta[j]*2.12*10.0^22
endfor
endfor
endif

if pref_sta[kk] eq 'LAU' then begin 
for i=0,11 do begin
for j=0,10 do begin
co_data[i]=co_data[i]+out[i,j]*delta[j]*2.12*10.0^22
co_data_dao[i]=co_data_dao[i]+out_dao[i,j]*delta[j]*2.12*10.0^22
co_data_giss[i]=co_data_giss[i]+out_giss[i,j]*delta[j]*2.12*10.0^22
endfor
endfor
endif

if pref_sta[kk] eq 'MLO' then begin 
for i=0,11 do begin
for j=3,14 do begin
co_data[i]=co_data[i]+out[i,j]*delta[j]*2.12*10.0^22
co_data_dao[i]=co_data_dao[i]+out_dao[i,j]*delta[j]*2.12*10.0^22
co_data_giss[i]=co_data_giss[i]+out_giss[i,j]*delta[j]*2.12*10.0^22
endfor
endfor
endif

if pref_sta[kk] eq 'ZVE' then begin 
for i=0,11 do begin
for j=0,24 do begin
co_data[i]=co_data[i]+out[i,j]*delta[j]*2.12*10.0^22
co_data_dao[i]=co_data_dao[i]+out_dao[i,j]*delta[j]*2.12*10.0^22
co_data_giss[i]=co_data_giss[i]+out_giss[i,j]*delta[j]*2.12*10.0^22
endfor
endfor
endif
;print, co_data
;print,comean

; Define ranges for plotting

loval=10.0^17 
highval=4*10.0^18
;if  min([comean,out[0:3]]) gt 70 then begin loval=50
;endif
;if  min([comean,out[0:3]]) gt 120 then begin loval=100
;endif
;if  min([comean,out[0:3]]) gt 170 then begin loval=150
;endif
;if  min([comean,out[0:3]]) gt 220 then begin loval=200
;endif

;highval=100
;if  max([comean,out[0:3]]) gt 80 then begin highval=150
;endif
;if  max([comean,out[0:3]]) gt 130 then begin highval=200
;endif
;if  max([comean,out[0:3]]) gt 180 then begin highval=250
;endif
;if  max([comean,out[0:3]]) gt 230 then begin highval=300
;endif
;if  max([comean,out[0:3]]) gt 280 then begin highval=350
;endif
;if  max([comean,out[0:3]]) gt 330 then begin highval=400
;endif

     plot, findgen(12)+1, comean, xstyle=1,ystyle=1,$
        title=ltitle,linestyle=0,psym=-5,symsize=0.6, $
        xticks=13, min_val=-900, xrange=[0,13],yrange=[loval,highval],$
        charsize=1.5, xmargin=[3,2], ymargin=[3,1],$
         xtickname=[' ','J','F','M','A','M','J','J','A','S','O','N','D',' '],$
         ytickname=['1','2','3','4'],color=1

; Now plot standard deviations
 
      for w = 0, 11 do begin
           errbar = [comean[w]-costd[w], comean[w]+costd[w]]
          oplot,  [w+1,w+1],errbar,$
                 linestyle=0,color=1
       endfor

; Add results for maccm3 model

   oplot, findgen(12)+1,co_data,linestyle=1,color=2
   oplot, findgen(12)+1,co_data,linestyle=1,psym=6,symsize=0.3,color=2
  
; Add results for dao model

   oplot, findgen(12)+1,co_data_dao,linestyle=2,color=3
   oplot, findgen(12)+1,co_data_dao,linestyle=2,psym=6,symsize=0.3,color=3
   
; Add results for giss model

   oplot, findgen(12)+1,co_data_giss,linestyle=3,color=4
   oplot, findgen(12)+1,co_data_giss,linestyle=3,psym=6,symsize=0.3,color=4   


; Now plot standard deviations
 
;      for w = 0, 3 do begin
;           errbar = [co_data[w]-std[w], co_data[w]+std[w]]
;          oplot,  [w+5,w+5],errbar,$
;                 linestyle=1,color=2
;       endfor


xyouts, 0.04, 0.5, 'CO column (*10^18)', /normal, align=0.5,$
orientation=90, charsize=1.2, color=1
xyouts, 0.5, 0.96,title, /normal, align=0.5, charsize=1.2,color=1
endfor

close_device,/TIMESTAMP

close, /all

end


