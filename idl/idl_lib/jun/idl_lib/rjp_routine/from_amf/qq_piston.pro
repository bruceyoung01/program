; qqsens program -- plots O3 data from different model sensitivity runs.

pro qqpiston, ibox, jbox, res

;ibox = 22
;jbox = 34
;res = 4

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
file = '/users/ctm/amf/CTM4/model_tsaft/TimeSeries1_4LT.O34x5_EPA_HUS_std_JJA'
tsmod = fltarr(92)

;std model O3
read_EPAtsfile, file, ibox, jbox, lon, lat, tsmod, ll, res
modpos = dblarr(n_elements(tsmod))
qqnorm, tsmod, modpos, qqpos
ytitle = "Ozone (ppb)"
plot, modpos, tsmod,psym=5, color=1, xtitle='Quantiles of Standard Normal', $
	ytitle=ytitle, yrange=[15,120] 

; hNOx

file = '/users/ctm/amf/CTM4/model_tsaft/TimeSeries1_4LT.O34x5_EPA_HUS_hNOx_JJA'
tsmod = fltarr(92)

;add hNOx to plot
read_EPAtsfile, file, ibox, jbox, lon, lat, tsmod, ll, res
tsmod=tsmod[where(tsmod gt 0.)]
modpos = dblarr(n_elements(tsmod))
qqnorm, tsmod, modpos, qqpos
oplot,  modpos,  tsmod, linestyle=1, color=1

; RUN hCH4
file = '/users/ctm/amf/CTM4/model_tsaft/TimeSeries1_4LT.O34x5_EPA_HUS_hCH4JJA'
tsmod = fltarr(92)

;add hCH4 to plot
read_EPAtsfile, file, ibox, jbox, lon, lat, tsmod, ll, res
tsmod=tsmod[where(tsmod gt 0.)]
modpos = dblarr(n_elements(tsmod))
qqnorm, tsmod, modpos, qqpos
oplot,  modpos,  tsmod, psym=4, color=4

;RUN NO NAMERICA, NO SOIL NOX:
;file = '/users/ctm/amf/CTM4/model_tsaft/TimeSeries1_4LT.Ox_4x5.nona_nosoilNOx'
;tsmod = fltarr(92)

;read_EPAtsfile, file, ibox, jbox, lon, lat, tsmod, ll, res
;tsmod=tsmod[where(tsmod gt 0.)]
;modpos = dblarr(n_elements(tsmod))
;qqnorm, tsmod, modpos, qqpos
;oplot,  modpos,  tsmod, psym=4, color=3

; RUN ONLY ANTHRO FROM NORTH AMERICA???

xyouts, -1.5, 100., lonstr+'W'+latstr+'N', color=1, /data

;close_device
close, /all

end
