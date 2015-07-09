; qqsens program -- plots O3 data from different model sensitivity runs.

pro qqpiston, ibox, jbox, res, seas

;ibox = 22
;jbox = 34
;res = 4

case (seas) of
   'DJF': ndays = 90
   'MAM': ndays = 92
   'JJA': ndays = 92
   'SON': ndays = 91
endcase

print,  ibox
print,  jbox
istr = strtrim(string(ibox),2)
jstr = strtrim(string(jbox),2)

lat=(jbox-1)*4. - 90. 
lon=(ibox-1)*5. - 180.

close, /all

;define array to hold positions on standard quantile axis & pass to
;qqnorm which will calculate positions on which to plot x-axis of
;quantiles of standard normal

latstr = strtrim(string(fix(lat)),2)
lonstr = strtrim(string(fix(-lon)),2)

;read in model time series Ox file & plot time series
file = '/users/ctm/amf/CTM4/model_tsaft/TimeSeries1_4LT.O34x5_EPA_HUS_std_'$
+ seas
tsmod = fltarr(ndays)

;std model O3
read_EPAtsfile, file, ibox, jbox, lon, lat, tsmod, ll, res
modpos = dblarr(n_elements(tsmod))
qqnorm, tsmod, modpos, qqpos
ytitle = "Ozone (ppb)"
plot, modpos, tsmod,psym=5, color=1, xtitle='Quantiles of Standard Normal', $
	ytitle=ytitle, yrange=[15,120] 
std = tsmod

; hNOx

file = '/users/ctm/amf/CTM4/model_tsaft/TimeSeries1_4LT.O34x5_EPA_HUS_hNOx_'$
+ seas
tsmod = fltarr(ndays)

;add hNOx to plot
read_EPAtsfile, file, ibox, jbox, lon, lat, tsmod, ll, res
hNOx = tsmod[qqpos]
oplot,  modpos,  hNOx, psym=6, color=2

; RUN hCH4
file = '/users/ctm/amf/CTM4/model_tsaft/TimeSeries1_4LT.O34x5_EPA_HUS_hCH4_'$
+ seas
tsmod = fltarr(ndays)

;add hCH4 to plot
read_EPAtsfile, file, ibox, jbox, lon, lat, tsmod, ll, res
hCH4 = tsmod[qqpos]
oplot,  modpos,  hCH4, psym=4, color=4

xyouts, -1.5, 100., lonstr+'W'+latstr+'N', color=1, /data

;RUN hVOC
file= '/users/ctm/amf/CTM4/model_tsaft/TimeSeries1_4LT.O34x5_EPA_HUS_hVOC_'$ 
+ seas
tsmod = fltarr(ndays)

;add hVOC to plot
read_EPAtsfile, file, ibox, jbox, lon, lat, tsmod, ll, res
hVOC = tsmod[qqpos]
oplot, modpos, hVOC, psym=1, color=3

;run hCO
file= '/users/ctm/amf/CTM4/model_tsaft/TimeSeries1_4LT.O34x5_EPA_HUS_hCO_'$
+ seas
tsmod = fltarr(ndays)

;add hVOC to plot
read_EPAtsfile, file, ibox, jbox, lon, lat, tsmod, ll, res
hCO = tsmod[qqpos]
oplot, modpos, hCO, psym=2, color=7


;NOW plot percentage change as function of freq. distribution:
delnox = 100*(hNOx-std)/std
delch4 = 100*(hCH4-std)/std
delstd = 100*(std-std)/std
delCO = 100*(hCO-std)/std
delVOC = 100*(hVOC-std)/std

plot, modpos, delstd,psym=5, color=1, xtitle='Quantiles of Standard Normal', $
	ytitle="Percent Change", yrange=[-40,10] 

oplot, modpos, delnox, psym=6, color=2

oplot, modpos, delch4, psym=4, color=4

oplot, modpos, delVOC, psym=1, color=3

oplot, modpos, delCO, psym=2, color=7

xyouts, -1.5, 5., lonstr+'W'+latstr+'N', color=1, /data

;close_device
close, /all

end
