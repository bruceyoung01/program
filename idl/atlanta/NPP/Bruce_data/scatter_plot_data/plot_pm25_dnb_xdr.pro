
 ; plot pm2.5 vs. radiances
 PRO plot_dnb_radiance, filename, dir, position, pequation, siteid

 readcol, dir + filename + '_1.txt', yy, mm, dd, hr, lat, lon, vvza, SatAZM, $
         moonphase, LZA, LAZM, PMA, PMB, PMC, PMD, $
         F= 'A4, A2, A2, A2,  F, F, F, F, F, F, F, F, F, F, F', $
         skipline = 1 , DELIMITER = ','

; readcol, dir + filename + '_2.txt', rad1, rad2, rad3, rad4, rad5, rad6, rad7, $
;         rad8, rad9, rad10, rad11, rad12, rad13, rad14, rad15, rad16, $
;         F = 'F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F', skipline = 1, $
;         DELIMITER = ','
 
; readcol, dir + filename + '_3.txt', rad17, rad18, rad19, rad20, rad21, rad22, rad23, $
;         rad24, rad25, $
;         F = 'F, F, F, F, F, F, F, F, F ', skipline = 1, DELIMITER = ','
 
 readcol, dir + '/visualized_couldmask_selected1.txt', cld1, skipline = 1
 readcol, dir + '/visualized_couldmask_selected2.txt', cld2, skipline = 1
 readcol, dir + '/visualized_couldmask_excellent.txt', cld3, skipline = 1


 ; read daily RH file from weather stations
  readcol, '/home/jwang/PRO/NPP/METR/Atlanta_RH_project.txt', ssiteid, wban, yymmdd, temp, $
           dewp, slp, stp, vis, $
           wdsp, mxspd, gust, matT, minT, prcp, SNDP, frshitt, rh, viskm, $
           format = 'A6, A5, A8, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F', skipline = 1, $
           DELIMITER = ' '
  yymmddflt = double (yymmdd)
  yyy = fix((yymmddflt/10000))
  mmm = fix( (yymmddflt - yyy * 10000D)/100)
  ddd  =fix( yymmddflt - yyy*10000D - mmm*100)

 ; read hourly RH file from weather stations
  readcol, '/home/jwang/PRO/NPP/METR/npp_overpass_mete.txt', YYY, MMM, DDD, HH, Vis, HourlyRH, Wind, WindDir, $
           precip, pressure, $ 
           format = 'I5,  I5,  I5, I5, F8.2, F8.2, F8.2, F8.2, F8.2, F8.2)', skipline = 1, $
           DELIMITER = ' '
stop
 ; read PBH, pressure, water vapor amount, and RH from WRFChem simulation
;  readcol, './wrfchem_site/' + siteid + '_2012.txt', wyy, wmm, wdd, whr, wrh, wu, wv, wpbl, wps, $
;         F= 'A4, A3, A3, A3, F, F, F, F, F', $
;         skipline = 1 , DELIMITER = ','
;  readcol, '/home/jwang/PRO/NPP/METR/WRF/' + siteid + '_2012.txt', wyy, wmm, wdd, whr, wrh, wu, wv, wpbl, wps, $
;         F= 'A4, A3, A3, A3, F, F, F, F, F', $
 ;        skipline = 1 , DELIMITER = ','


 ; covert WRHChem RH to time of our interest
;  result = where (whr eq 7, count) 
;  print, 'RH correlation: ', correlate(RH(0:count-1), wrh(result))
;  WRFRH = wrh(result)

 ; use hourly HR
 RH = RH
; Viskm = vis

 ; computer mean of radiances
 NL = n_elements (yy)
 brucerad = fltarr(NL)
 tmprad = fltarr(25)
 newrad = fltarr(NL)    ; new rad from my own computation
 maxnewrad = fltarr(NL)    ; new rad from my own computation
 newmphase = fltarr(NL)
 mfraction = fltarr(NL)
 newvza = fltarr(NL)-999

 for i = 0, NL-1 do begin
 if (min(tmprad) gt 0 ) then begin
 ; tmprad = alog(tmprad)
;  result = where (tmprad le max(tmprad) and tmprad gt median(tmprad))
;  rad(i) = median(alog(tmprad(result)))

 result = percentiles (tmprad)
 brucerad(i) = alog( (tmprad(result(1)) + tmprad(result(2)))*0.5 )
 brucerad(i) = alog(tmprad(result(1)))
 endif
 
 ; release xdr file
 xdrdir = '/home/jwang/PRO/NPP/DNB/dnbsitedata'
 xdrname = strcompress( yy(i) + mm(i) + dd(i), /remove_all ) 
 result = file_search (xdrdir, xdrname + '*_' + siteid + '.xdr', count=count)

 if (count gt 0 ) then begin
  restore, result(0)
  if (min(rad) gt 0 ) then begin 
  ; converting radiance to mw/m2/str.
;  newrad(i) = alog ( (rad(newresult(1)) + rad(newresult(2))) * 0.5 * 10.^7 ) 
;  newrad(i) = alog ( (rad(newresult(1)) + rad(newresult(2))) * 0.5 * 10.^7 ) 

;  newrad(i) = max(rad) *  10.^7
;  print, 'count = ', count, mm(i), dd(i) 
  rad = rad * 10.^7
  newresult = percentiles (rad, value = [0.75, 0.90])
;  print, n_elements(rad)
;  result = where (rad ge newresult(0) and rad le newresult(1) )
;  newrad(i) = alog ( mean (rad(result)) )
   
   nbins=11
   result = histogram (rad, nbins=nbins )
   nnresult = fltarr(nbins)
 
   for ii = 0, nbins-2 do begin
    nnresult(ii) = result(ii+1) - result(ii)
   endfor

   sresult = sort ( nnresult)
   slimit = min(rad) + findgen(nbins+1) *  ( max(rad) - min(rad) ) / nbins      
   
;   newrad(i) = alog (mean(rad( where (rad gt slimit(sresult(1)+1) ) ) ) )   
;   newrad(i) = slimit(sresult(1))

  tmp = reverse(sort(rad))

    newrad(i) = alog (max(rad(tmp(1))+rad(tmp(0))))
 ;   newrad(i) = alog (max(rad))
 ;   newrad(i) = 0.5 * (alog(rad(tmp(1))) + alog(rad(tmp(0))))

;   newrad(i) = alog ( newresult(1))  - alog (newresult(0))
;  hist = histgram(rad)
;  newrad(i) = alog(max(rad))
;  newrad(i) = alog( (mean(rad)) )
  newmphase(i) = mphase 
  mfraction(i) = mfrac
  newvza(i) = vza
 endif  
 endif
 endfor             

 ; plot linear and scatter plot DNB vs. PM25
; yy = maxnewrad 
 yy = newrad 
 xx = 0.25 * (PMA+PMB+PMC+PMD)/cos(newvza*!pi/180.)
 
 ; consider RH effect
 b0 = -0.24812
 b1 = 1.01865
 b2 = 0.01074
 F = b0 + b1 * 100/(100.-RH) + b2 * (100/(100.-RH))^2
 XX = xx*F
 ;YY = YY/F 
  
 result = where ( xx gt 0  and mfraction le 40 and $
              newvza ge 0 and  mm le 10 and mm ge 8 and RH gt 0 and cld1 eq 0, count)
 best_fit, yy(result),  xx(result) , ifplot=1, xrange = [0, 120], $
          yrange = [-8, 8], $
          xtitle = 'PM2.5/(cos(VZA)), Siteid:' + siteid, $
          ytitle = ' log(rad) ', position = position, $
          pequation = pequation

openw, 5, siteid+'_final.txt'
printf, 5, '  MM DD   PMA   PMB  PMC PMD  yy    maxrad   F     RH       VZA'
for k = 0, count-1 do begin
  kk = result(k) 
printf, 5, mm(kk), dd(kk), PMA(kk), PMB(kk), PMC(kk), PMD(kk), newrad(kk), maxnewrad(kk), F(kk), $
          RH(kk), newvza(kk), format='(I3, I3, F7.2, F7.2, F7.2, F7.2, F7.2, F7.2, F7.2, F7.2, F7.2)'
endfor
close, 5


 ; plot DNB vs. vis 
 multipanel, position = newposition, /advance
 newpequation = [ newposition(0)+0.1* (newposition(2)-newposition(0)), newposition(1)+0.9*(newposition(3)-newposition(1)) ]
 xx = (3.9 / viskm) /cos(newvza*!pi/180.)*1000. 
 best_fit, yy(result),  xx(result) , ifplot=1, xrange = [0, 1000], $
          yrange = [-8, 8], $
          xtitle = 'Ext/(cos(VZA)), Mm!u(-1)!n, Siteid:' + siteid, $
          ytitle = ' log(rad) ', position = newposition, $
          pequation = newpequation

; extinction efficiency vs. RH  
 multipanel, position = newposition, /advance
 newpequation = [ newposition(0)+0.1* (newposition(2)-newposition(0)), newposition(1)+0.9*(newposition(3)-newposition(1)) ]
 yy = 3.9/viskm*1000. / [0.25 * (PMA+PMB+PMC+PMD)]  ; this will be in unit of m2/g. 
 xx = RH
 reuslt = where (viskm lt 16)
 best_fit, yy(result),  xx(result) , ifplot=1, xrange = [0, 100], $
          yrange = [0, 100], $
          xtitle = 'RH, siteid:' + siteid, $
          ytitle = ' Ext. Mm!u-1!n ', position = newposition, $
          pequation = newpequation


; DNB vs. Specific Humidity
 multipanel, position = newposition, /advance
 newpequation = [ newposition(0)+0.1* (newposition(2)-newposition(0)), newposition(1)+0.9*(newposition(3)-newposition(1)) ]
 yy =  newrad

; first compute satureation pressure
; T should be in celcuis
; es: mb
 Temp = (Temp - 32) * 5/9.
 es = 6.12 * exp( (17.47 * Temp ) / (Temp + 253.5) )
 e = RH/100. * es
 SH = 0.622 * e / slp * 100 
 xx = SH / cos(newvza*!pi/180.)
 result = where ( xx gt 0  and mfraction le 40 and $
              newvza ge 0 and cld1 eq 0 and mm le 12 and mm ge 8 and RH gt 0) 
best_fit, yy(result),  xx(result) , ifplot=1, xrange = [0, 5], $
          yrange = [-8, 8], $
          xtitle = 'Specific Humidity/cos(VZA)*100, siteid:' + siteid, $
          ytitle = ' DNB Radiance (ln) ', position = newposition, $
          pequation = newpequation


; DNB vs. surface pressure
 multipanel, position = newposition, /advance
 newpequation = [ newposition(0)+0.1* (newposition(2)-newposition(0)), newposition(1)+0.9*(newposition(3)-newposition(1)) ]
xx = slp / cos(newvza*!pi/180.)
yy = newrad
result = where ( xx gt 0  and mfraction le 40 and $
              newvza ge 0 and cld1 eq 0 and mm le 12 and mm ge 8) 
best_fit, yy(result),  xx(result) , ifplot=1, xrange = [900, 3500], $
          yrange = [-8, 8], $
          xtitle = 'Pressure/cosVZA, siteid:' + siteid, $
          ytitle = ' DNB Radiance (ln) ', position = newposition, $
          pequation = newpequation


; xx = 0.5 * (1 + cos ( newmphase * !pi/180. )) * 100
; yy = mfraction
; best_fit, yy(result),  xx(result) , ifplot=1, xrange = [0, 100], $
;          yrange = [0, 100], $
;          xtitle = 'PM2.5/(cos(VZA))', $
;          ytitle = ' alog(rad) ', position = position, $
;          pequation = pequation

 end  


; Main Code Starts Here
 ; set plot ps
 ps_color, filename = 'PM_DNB_NEW_hourly.ps'
 
 ; set plot for 5 panels
 multipanel, row=3, col=2 
 multipanel, position = position

;                   A           B           C            D           E
;              N. Atlanta    SW            SE           CTR         CTR      
 FileNames = ['131350002', '130770002', '131510002', '131210055', '130890002', 'CTR', 'Yang'] 
 siteid =    ['A', 'B', 'C', 'D', 'E', 'CTR', 'YANG' ] 

 dir = './data_w_background/'
; dir = './data_ctr/'
 
 for i = 0, 5 do begin
 pequation = [ position(0)+0.1* (position(2)-position(0)), position(1)+0.9*(position(3)-position(1)) ] 
 plot_dnb_radiance, filenames(i), dir, position, pequation, siteid(i)
 multipanel, position = position, /advance
 multipanel, position = position, /advance
 endfor

 device, /close
 end
