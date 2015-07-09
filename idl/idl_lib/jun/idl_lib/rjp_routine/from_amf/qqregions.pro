; qqsens program -- plots O3 data from different model sensitivity runs.

;pro qqregions, region, seas

region = 'USA'

case (seas) of
   'DJF': ndays = 90
   'MAM': ndays = 92
   'JJA': ndays = 92
   'JUL': ndays = 30
   'SON': ndays = 91
endcase



close, /all

;define array to hold positions on standard quantile axis & pass to
;qqnorm which will calculate positions on which to plot x-axis of
;quantiles of standard normal

latstr = strtrim(string(lat),2)
lonstr = strtrim(string(lon),2)

;read in model time series Ox file & plot time series
;file = '/users/ctm/amf/CTM4/model_tsaft/TimeSeries1_4LT.O34x5_EPA_HUS_std_'$
;+ seas
file = '/users/ctm/amf/CTM4/model_tsaft/TimeSeries1_4LT.O32x2_EPA.std'
tsmod = fltarr(ndays)
;help,  tsmod

;std model O3
read_EPAtsfile, file, ibox, jbox, tsmod, ll, res,  ndays
;print, tsmod
;stop
tsmod = tsmod[0:n_elements(tsmod)-2]; to match 91 days for 1980 4x5 run
modpos = dblarr(n_elements(tsmod))
qqnorm, tsmod, modpos, qqpos
ytitle = "Ozone (ppb)"
;plot, modpos, tsmod,psym=5, color=1, xtitle='Quantiles of Standard Normal', $
;	ytitle=ytitle, yrange=[15,120] 
std = tsmod

; 1980

;ndays = 91
;file = '/users/ctm/amf/CTM4/model_tsaft/TimeSeries1_4LT.O34x5_EPA_HUS_1980_'$
;+ seas
file = '/users/ctm/amf/CTM4/model_tsaft/TimeSeries1_4LT.O32x2_EPA.1980'
tsmod = fltarr(ndays)

;add hNOx to plot
read_EPAtsfile, file, ibox, jbox, tsmod, ll, res, ndays
hNOx = tsmod[qqpos]
;oplot,  modpos,  hNOx, psym=6, color=2

;xyouts, -1.5, 100, lonstr+'W'+latstr+'N', color=1, /data

;NOW plot percentage change as function of freq. distribution:
delstd = std-hNOx
delnox = hNOx-hNOx
plot, modpos, delstd,psym=1, color=1, xtitle='Quantiles of Standard Normal', $
 ytitle="Change from 1980 (ppbv)", yrange=[-4,5], charsize=3.0, ymargin=[2,2] 
print, 'MIN = ', min(delstd)
oplot, modpos, delnox, linestyle=1, color=1


;xyouts, -1.5, 4, lonstr+'W'+latstr+'N', color=1, /data

;close_device
close, /all

end
