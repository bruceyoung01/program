PRO corr

;filedir = '/home/npothier/Assistanceship/MODIS_AERONET_DATA/AERONET/'
filedir='/home/npothier/Assistanceship/MODIS_AERONET_DATA/MODIS/'
filename='hour_050101_051231_Walker_Branch.lev20'
filename2='Walker_Branchaqua.txt'
filename3='Walker_Branchterra.txt'

;read in aeronet for specified city

 readcol, filename, YY, MM, DD, Time, JulianD, SZA,                $
           AOT_1640, AOT_1020, AOT_870, AOT_675, AOT_667, AOT_555,  $
           AOT_551,  AOT_532,  AOT_531, AOT_500, AOT_490, AOT_443,  $
           AOT_440,  AOT_412,  AOT_380, AOT_340,                    $
           format = 'I, I, I, F, F10.2, F, F, F, F, F, F, F, F, F, F,'+ $
                    'F, F, F, F, F, F, F', skipline = 1

;read in aqua for specified city  
 readcol, filedir + filename2, YY2, MM2, DD2, Dayfrac2,                 $
           AOT05502,                    $
           format = 'I, I, I, F, F', skipline = 1
  
;read in terra for specified city  
  readcol, filedir + filename3, YY3, MM3, DD3, Dayfrac3,                 $
           AOT05503,                    $
           format = 'I, I, I, F, F', skipline = 1
	   
;convert aqua and terra YY MM DD into julian days (julian day + dayfrac)

firstday=JULDAY(1,1,2005)
year2=YY2+2000.
year3=YY3+2000.
aqua= JULDAY(MM2, DD2, year2)-firstday
terra=JULDAY(MM3, DD3, year3)-firstday
aquaday=aqua+Dayfrac2
terraday=terra+Dayfrac3

aquacount=n_elements(aquaday)
terracount=n_elements(terraday)
juliandcount=n_elements(JulianD)

aqua_month_aot=fltarr(12)
terra_month_aot=fltarr(12)
aero_aqua_month_aot=fltarr(12)
aero_terra_month_aot=fltarr(12)

aqua_index=where(AOT05502 gt 0, aqua_count)
if (aqua_count gt 0) then begin
    new_aqua_aot=AOT05502[aqua_index]
    new_aqua_time=aquaday[aqua_index]
    new_aqua_year=YY2[aqua_index]
    new_aqua_month=MM2[aqua_index]
    new_aqua_day=DD2[aqua_index]
endif

terra_index=where(AOT05503 gt 0, terra_count)
if (terra_count gt 0) then begin
    new_terra_aot=AOT05503[terra_index]
    new_terra_time=terraday[terra_index]
    new_terra_year=YY3[terra_index]
    new_terra_month=MM3[terra_index]
    new_terra_day=DD3[terra_index]
endif

;interpolate for aeronet 550 um

lamda1=.000675
lamda2=.000440
    
alpha=(-1.)*((alog(AOT_675)/alog(AOT_440))/(alog(lamda1)/alog(lamda2)))
    
AOT_550=((.000550/lamda2)^(-alpha))*(AOT_440)

;find the matching pairs between aeronet and aqua, and aeronet and terra

month_aqua=fltarr(aqua_count)
aero_aqua=fltarr(aqua_count)
month_terra=fltarr(terra_count)
aero_terra=fltarr(terra_count)

for i=0, aqua_count-1 do begin

aquapair=where(JulianD gt (new_aqua_time[i]-(.5/24.)) and JulianD lt (new_aqua_time[i]+(.5/24.)), $
aquapair_count)

if (aquapair[0] ne -1) then begin

    aero_aqua[i]=mean(AOT_550[aquapair])

endif else begin

    aero_aqua[i]=!VALUES.F_NAN
    
endelse

endfor

for j=0, terra_count-1 do begin

terrapair=where(JulianD gt (new_terra_time[j]-(.5/24.)) and JulianD lt (new_terra_time[j]+(.5/24.)), $
terrapair_count)

if (terrapair[0] ne -1) then begin

    aero_terra[j]=mean(AOT_550[terrapair])
    
endif else begin

    aero_terra[j]=!VALUES.F_NAN
    
endelse

ENDFOR

;pull out all pairs for all data sets

aqua_index=where(aero_aqua gt 0., ct)
terra_index=where(aero_terra gt 0., ct2)

new_aqua_pair=new_aqua_aot[aqua_index]
new_terra_pair=new_terra_aot[terra_index]
new_aero_aqua_pair=aero_aqua[aqua_index]
new_aero_terra_pair=aero_terra[terra_index]

set_plot, 'ps'
device, filename='aquavaeronet.ps'

plot, new_aqua_pair, new_aero_aqua_pair, TITLE='Aqua AOT Data vs Aeronet AOT Data', XTITLE='Aqua', $
XRANGE=[0, .7], YTITLE='Aeronet', psym=3

device, /close

print, "new_aqua_aot_count= ", n_elements(new_aqua_aot)
print, "aero_aqua_count= ", n_elements(aero_aqua)


set_plot, 'ps'
device, filename='terravaeronet.ps'

plot, new_terra_pair, new_aero_terra_pair, TITLE='Terra AOT Data vs Aeronet AOT Data', XTITLE='Terra', $
XRANGE=[0, .6], YTITLE='Aeronet', psym=3

device, /close

;compute monthly means

for month=0, 11 do begin
    aqua_month=where(new_aqua_month eq (month+1.), aqua_month_count)
    aqua_month_aot[month]=mean(new_aqua_pair[aqua_month])
    terra_month=where(new_terra_month eq (month+1.), terra_month_count)
    terra_month_aot[month]=mean(new_terra_pair[terra_month]) 
    ;aero_aqua_month=where(aero_aqua eq (month+1.), aero_aqua_month_count)
    aero_aqua_month_aot[month]=mean(new_aero_aqua_pair[aqua_month])
    ;aero_terra_month=where(aero_terra eq (month+1.), aero_terra_month_count)
    aero_terra_month_aot[month]=mean(new_aero_terra_pair[terra_month])

endfor

set_plot, 'ps'
device, filename='aquavaeronetmonthly.ps'

plot, aqua_month_aot, aero_aqua_month_aot, TITLE='Monthly Aqua AOT Data vs Aeronet AOT Data', $
XTITLE='Aqua', XRANGE=[0, .7], YTITLE='Aeronet', psym=3

device, /close

set_plot, 'ps'
device, filename='terravaeronetmonthly.ps'

plot, terra_month_aot, aero_terra_month_aot, TITLE='Monthly Terra AOT Data vs Aeronet AOT Data', $
XTITLE='Terra', XRANGE=[0, .6], YTITLE='Aeronet', psym=3

device, /close

s=n_elements(new_aero_aqua_pair)
t=n_elements(new_terra_pair)

print, "aquapair count= ", n_elements(new_aqua_pair)
print, "aeroaquapair count= ", n_elements(new_aero_aqua_pair)
print, "aquapairmonth count= ", n_elements(aqua_month_aot)
print, "aeroaquapairmonth count= ", n_elements(aero_aqua_month_aot)
print, "terrapair count= ", n_elements(new_terra_pair)
print, "aeroterrapair count= ", n_elements(new_aero_terra_pair)
print, "terrapairmonth count= ", n_elements(terra_month_aot)
print, "aeroterrapairmonth count= ", n_elements(aero_terra_month_aot)

;write arrays to file for computation use in Excel

  openw, 1, 'Walker_Branch_aqua.txt'
  for i=0, s-1 do begin 
    	printf, 1, new_aqua_pair[i],new_aero_aqua_pair[i]	
   endfor    
  close,1 

  openw, 3, 'Walker_Branch_aqua_monthly.txt'
  for k=0, 11 do begin      
    printf, 3, aqua_month_aot[k], aero_aqua_month_aot[k]
  endfor
  close, 3
     
  openw, 5, 'Walker_Branch_terra.txt'
    for l=0, t-1 do begin
     printf, 5, new_terra_pair[l], new_aero_terra_pair[l]
    endfor
  close, 5
    
   openw, 7, 'Walker_Branch_terra_monthly.txt'
    for j=0, 11 do begin
     printf, 7, terra_month_aot[j], aero_terra_month_aot[j]
    endfor
    close, 7

END
