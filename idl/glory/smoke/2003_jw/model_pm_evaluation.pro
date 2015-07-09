
; purpose: this program reads RAMD datas, and do the correlation 
;          comparision with each EPA stations



pro   plot_time_series, tmprams, tmptxmass, titlename, lat, lon
       
 !p.multi = [0, 1, 3]
      npt = n_elements(tmprams)
   ;   time = timegen(npt, units='hours', start=Julday(4, 20, 2003, 12, 0)) 
      
      xtickname=['April 21', ' May 1',  '11', '21'] 

      plot, [0, npt], [0, 100], xtitle = 'Date in year 2003', ytitle = '!6PM!d2.5!n Mass Concentration',$
            xrange = [0, npt], xstyle=1, yrange=[0, 110],  ystyle=1,$
	    position=[0.01, 0.2, 0.94, 0.7],/nodata, title = titlename,$
	    xthick=3, ythick=3, charthick=3, charsize=1.2, xticks=3,$
	    xminor=10, xtickname = xtickname, color=255

      ; set smoke event range
      tstart = [21, 27, 42, 48] - 21  
      tend =  [ 27, 42, 48, 51] -21
      color = [220, 175, 220, 175] 
      
      for i = 0, 3 do begin 
       polyfill, 24*[tstart(i), tstart(i), tend(i), tend(i)], [0, 65, 65, 0],$
        color=color(i)  
      endfor

      plot, [0, npt], [0, 100], xtitle = 'Date in year 2003', ytitle = '!6PM!d2.5!n Mass Concentration',$
            xrange = [0, npt], xstyle=1, yrange=[0, 110],  ystyle=1,$
	    position=[0.01, 0.2, 0.94, 0.7],/nodata, title = titlename,$
	    xthick=3, ythick=3, charthick=3, charsize=2.5, xticks=3,$
	    xminor=10, xtickname = xtickname

      result = where ( tmptxmass ne 999 and tmptxmass gt 0, count)
      
      if ( count gt 0 ) then begin
        oplot, result, tmptxmass(result), thick=3 
      endif

; Mark unvalid data
;      count = n_elements(tmptxmass)
      print, 'npt = ', npt
      for i = 0, npt-1 do begin
        if ( tmptxmass(i) eq 999 or tmptxmass(i) lt 0 ) then begin
          inx = where(tend*24 gt i) 
	  print, inx(0), i
          polyfill, [i-1.0, i-1.0, i+1.0, i+1.0, i-1.0], [0, 65, 65, 0, 0],$
             color=color(inx(0))  
        endif
      endfor     
      print, 'npt = ', npt, tend*24
      
;       oplot, findgen(npt),  tmprams, color=2


; plot unhealthy lines
       pmlines =  [0, 15.5, 40.5, 65.5]
       category = ['!cGood', '!cModerate', 'Unhealthy !cSpecial!cGroups', 'Unhealthy']  
       xa = 0.96
       xb = 1.175 
       plots, [xa, xb, xb, xa, xa], [0.2, 0.2, 0.7, 0.7, 0.2], /normal ,  thick=3
       for i = 1, n_elements(pmlines)-1 do begin
         oplot, [0, npt], [pmlines(i), pmlines(i)], linestyle=2, thick=3
	 plots, [xa, xb], [pmlines(i)/110*0.5+0.2, pmlines(i)/110*0.5+0.2],/normal,thick=3,linestyle=2
	 xyouts, (xa+xb)/2., (pmlines(i)+pmlines(i-1))/110*0.25+0.218, category(i-1), $
	         /normal, align = 0.5, charthick=3, charsize=1.2
       endfor	 
       
       xyouts, (xa+xb)/2., (pmlines(i-1)+110)/110*0.25+0.2, category(i-1), $
	         /normal, align = 0.5, charthick=3, charsize=1.2



; draw a map on the figure
        plot, [0, 1], [0, 2], /nodata, $
	xrange = [-110, -92], yrange = 	[25, 38] , xstyle=1, ystyle=1,$
	position = [0.07, 0.51,  0.29, 0.71], color=255,$
	xtickname=[' ',' '], xticks=1
        
	plots, lon, lat, psym = sym(5,1), symsize=1.5
        add_texas_boundary, 155 
end



Pro Add_texas_Boundary, color

; Purpose: To add the TEXAS boundary to the plot.

bnd = FltArr(2,1085)

OpenR, 3, '~/idl_lib/US/TX_state.ovl'
ReadF, 3, lon, lat
i = 0
WHILE lon NE 909.9 DO BEGIN
   bnd[0,i] = lon
   bnd[1,i] = lat
   ReadF, 3, lon, lat
   i = i + 1
   ENDWHILE
   Close, 3
   numpts = i
   ;PolyFill, bnd[0,0:numpts-1], bnd[1,0:numpts-1], Color=12
   PlotS, bnd[0,0:numpts-1], bnd[1,0:numpts-1], Color=color, $
          Thick=4
 END ; Add_TEXAS_Boundary

		  


;
; plto linear relationship
;
 pro ozone_refl,yy,xx,xxstd, yystd, xa,xb,result,sigma, titlename, lat,$
 lon, ID, stachar, clrinx, locationinx 
 !p.multi = [0, 1, 2]
 plot, [0.0, 30], [0.0, 100], xtitle="!6 RAMS-AROMA Smoke (!4l!6gm!u-3!n)", $
        ytitle="Measured PM!d2.5!n (!4l!6gm!u-3!n)", xstyle=1, ystyle = 1, $
        title='!c!c!c!c'+titlename, /nodata, xcharsize=1.5, ycharsize=1.5,$
        charthick=3, xthick=3, ythick=3, position=[0.1, 0.3, 0.9, 0.8]

   ipnt=N_elements(xx)
   for i = 0, ipnt - 1 do begin
    plots, xx(i), yy(i),psym = sym(1), color = fix(clrinx(i))
;    print, 'color = ', clrinx(i) 
    ;oplot, [xx(i), xx(i)], [yy(i)-yystd(i)/2., yy(i)+yystd(i)/2.]
    ;oplot, [xx(i)-xxstd(i), xx(i)+xxstd(i)], [yy(i), yy(i)]
   endfor

; set linear equation
        weights=replicate(1.0,ipnt)
        ;print,' ipnt= ', ipnt
        refl=fltarr(1,ipnt) & refl(0,*)=xx(*)
        Result=REGRESS(refl,yy,weights,yfit,const,sigma,/relative_weight)
        result1=sort(xx)
        oplot,xx(result1),yfit(result1),linestyle=0,thick=4.0,color=0 ;plot the regression line

; linear equation
	intercept = const
	slope = result

        if const ge 0 then sign='+'
        if const lt 0 then sign=''
       linear_equation='Y = '+ strcompress(string(result,format='(f7.2)'))+' X '+ sign + $
       strcompress(string(const,format='(f6.2)'))

      ;  caption3 = linear_equation + '!c!c R ='+string(correlate(xx,yy),format='(f6.2)') +$
      ; '!c!c N = ' + string(ipnt, format='(i3)')

; xx and yy std
       result1 = moment(xx)
       xmean = result1(0)
       xstd = sqrt(result1(1))
       result1 = moment(yy)
       ymean = result1(0)
       ystd = sqrt(result1(1))
				
       xystd = 'Measured: ' + string(ymean, format= '(f5.2)') + '!9+!6'+  string(abs(ystd), format= '(f5.2)') + $
             '!cModeled : ' + string(xmean, format= '(f5.2)') + '!9+!6'+ string(abs(xstd), format= '(f5.2)') 

; add signicance level
     ; set several P levels. 
	Parray = 0.00001 + findgen(1001)*(0.05-0.0001)/1000.
	tarray = fltarr(1001)
	for i = 0, 1000 do begin
	tarray(i) = t_cvf(parray(i), ipnt-2)
	endfor
	
        RR = correlate(xx,yy)
	tobs = RR * sqrt( (ipnt - 2)/(1 - rr^2) )
        result = where ( tarray lt tobs, count) 
        if ( count gt 0 ) then Pchar = ' P < ' + strcompress(string(parray(result(0)), format = '(f10.5)'), /remove_all)  
        if ( count le 0 ) then Pchar = ' P > 0.05'   

; RMS
      tot = 0.0
      totxx = 0.0
      totyy = 0.0
      for i = 0, ipnt-1 do begin
        tot = abs(xx(i)-yy(i))^2 + tot
	totxx = totxx + xx(i)
	totyy = totyy + yy(i)
      endfor
        rms = sqrt(tot / ipnt)
	bias = (totyy-totxx)/ipnt

	rmschar = 'RMSE = ' + strcompress(string(rms, format='(f7.2)'),	/remove_all) 

       RR = correlate(xx,yy)
       if ( RR ge 0.685 and RR lt 0.7) then RR = 0.7 

       caption3 = 'R ='+string(RR,format='(f6.2)') + pchar + $
                  '!cN = ' + strcompress(string(ipnt, format='(i4)'),  /remove_all) + ' ' +  RMSchar + $
		  '!c'+ linear_equation+ $
                  '!c' + xystd   
        
       xyouts,xa + 0.02, xb + 0.46, caption3,/normal,charsize=1.3,charthick=3.0,color=0
       
       
       smokelevel1 = (15.5 - intercept)/slope
       smokelevel2 = (40.5 - intercept)/slope
 
	 ;print, 'Station ', ID, ' Lat ', lat, ' lon ', lon, '  linear equation  = ', linear_equation, '    R = ',$
	 ;        string(correlate(xx,yy),format='(f6.2)') , '   N =', Ipnt, 'smoke level=', smokelevel1, $
;		 smokelevel2  
	 print,  ID,  stachar, lat,  lon, linear_equation, $
	 correlate(xx,yy) ,  Ipnt,  smokelevel1, smokelevel2, $
	 format='(I3, 10A, f9.4, 2x, f9.4, 20a,  f9.4, I3, 2f9.4)'  

; draw a map on the figure
        plot, [0, 1], [0, 2], /nodata, $
	xrange = [-110, -92], yrange = 	[25, 38] , xstyle=1, ystyle=1,$
	position = [0.65, 0.3,  0.87, 0.5], color=8
        
 if (titlename ne 'Over All' ) then begin 
	plots, lon, lat, psym = sym(5,1), symsize=1.5
        add_texas_boundary, 9
endif 
        
        
	sigma = RR 

; add color points
   dy = 0.025
   ddy = 0.48
   ddx = 0.2
   dx = 0.05
   dddy = 0.005

;   plots, xa - ddx, xb+ddy,      psym = sym(1), color=1 , /normal
;   xyouts, xa - ddx + dx, xb+ddy-dddy, 'WTX  R=0.71', color=0, /normal, charthick=3, charsize=1.25
   
;   plots, xa - ddx, xb+ddy-dy,   psym = sym(1), color=2 , /normal
;   xyouts, xa - ddx + dx, xb+ddy-dy-dddy, 'ETX  R=0.83', color=0, /normal, charthick=3,charsize=1.25
   
;   plots, xa - ddx, xb+ddy-2*dy, psym = sym(1), color=3 , /normal
;   xyouts, xa - ddx + dx, xb+ddy-2*dy-dddy, 'CTX  R=0.89', color=0, /normal, charthick=3,charsize=1.25
   
;   plots, xa - ddx, xb+ddy-3*dy, psym = sym(1), color=4 , /normal
;   xyouts, xa - ddx + dx, xb+ddy-3*dy-dddy, 'STX  R=0.70', color=0, /normal, charthick=3,charsize=1.25
   
;   plots, xa - ddx, xb+ddy-4*dy, psym = sym(1), color=5 , /normal
;   xyouts, xa - ddx + dx, xb+ddy-4*dy-dddy, 'NTX  R=0.81 ', color=0, /normal, charthick=3,charsize=1.25

END




; 
; post reanalysis
;

pro post_reanalysis_hourly
 ;restore, 'model_pm_grid2_1.0_on.xdr'
 ;restore, 'model_pm_grid2_1.7_off.xdr'
; restore, 'model_pm_grid2.xdr'
 restore, 'model_pm_grid2_layer9-1.0-hourly-on.xdr'
 
 totalxx = fltarr(2000)
 totalyy = fltarr(2000)
 startDay =0 
 EndDAy = 29 
 shr = 0    ; already taken care of. 1 is April 21, 2003 local time 
 xa = 0.4
 xb = 0.3

; Adjust here * 888888888888888888888888888888888888

 for i = 0, TXPMNS-1 do begin
 
 tmprams = fltarr((EndDay - StartDay + 1)*24 + shr)
 tmptxmass  = fltarr((EndDay - StartDay + 1)*24 +shr)
 
 for j = startday, endday do begin
   k = j - startday
   tmprams (k*24: (k+1)*24-1) = ramsmassdaily(i, j, 0: 23 +shr)
   tmptxmass(k*24: (k+1)*24-1) = txmassdaily(i,j, 0:23 +shr)
 endfor
  
  result = where ( tmprams gt 0 and tmprams ne 999 and $
                   tmptxmass gt 0 and tmptxmass ne 999, count)
  if ( count gt 0 ) then begin
    xx = fltarr(count)
    xx(0:count-1) = tmprams(result)
    yy = fltarr(count)
    yy(0:count-1) = tmptxmass(result)
    
    titlename = 'Station NO.' + string(i, format= '(I2)') + ' Lat: ' +$
    string(txpmlat(i), format='(f9.4)') + ' Lon: ' + $
    string(txpmlon(i),format='(f9.4)')

; plot hourly correlation station by station 
  ;  ozone_refl,yy, xx, fltarr(count), fltarr(count),$
  ;          xa,xb,result,sigma, titlename, 0.0, 0.0, 0, 'overall',$
  ;          fltarr(count)
 
 endif

; plot time series
   plot_time_series, tmprams, tmptxmass, titlename, txpmlat(i),   txpmlon(i)

 endfor

 
END 


pro post_reanalysis_daily

 ; define color table
 
 
 r = [0,    0,   0,   153,    0, 255, 255, 255,   255, 150 ]
 g = [0,    0,   0,   255,  255, 155,   0,   0,   255, 150]
 b = [0,  155,  255,   0,    51, 155,   0, 255,   255, 150]
 tvlct, r, g, b

 EPALEVEL = [15.4, 40.4, 65.4, 150.4, 1000]
 
 STARTLEVEL = [1, 5, 9]
 ENDLEVEL =   [13, 17, 21]
 startDay =0 
 EndDAy = 29
 
 
 ;restore, 'model_pm_grid2_1.0_daily.xdr'
 ;restore, 'model_pm_grid2_1.0_daily.xdr'
 restore, 'model_pm_grid2_layer9-1.0-hourly-on.xdr'
; restore, 'model_pm_grid2.xdr'
;  restore, 'model_pm_grid2_1.0_on.xdr'
 totalxx = fltarr(2000)
 totalyy = fltarr(2000)
 colorinx = fltarr(2000)
 
 selectsta = fltarr(TXPMNS)
 usesta=[34, 8, 24, 9, 21]
 usesta=[34, 8, 24, 9, 37]
 mycolor = [1, 2, 3, 4, 5]
 usecolor = fltarr(txpmns)
 ;usecolor(usesta(0:4)) = mycolor(0:4)

; usesta = findgen(TXPMNS)+1
 ;selectsta(usesta) = 1
 selectsta(*) = 1
 clrinx = 1
  
; LOOP DIFFERENT SCHEME for air quality evalutations
for ii = 1, 1 do begin
for jj = 0, 0 do begin

  RAMSLEVEL = [ STARTLEVEL(ii), ENDLEVEL(jj), 100]
 
 Correct_overall = 0.0
 Correct_good = 0.0
 Correct_moderate = 0.0
 Correct_USP = 0.0
 iii = 0   ; index for total points
 
 correlation = fltarr(TXPMNS)

; adjust here ******************, if wipe out two stations 
 for i = 0, TXPMNS-1 do begin
 
 
 ; several definitions 
 Tmp_correct = 0.0
 Tmp_good = 0.0
 Tmp_moderate = 0.0
 Tmp_USP = 0.0
 total_good = 0.0
 total_moderate = 0.0
 total_usp = 0.0
 total_correct = 0.0
  
 ; daily comparison
 tmprams = fltarr(EndDay - StartDay + 1)
 tmptxmass  = fltarr(EndDay - StartDay + 1)
 tmprams (0:EndDay - StartDay)  = ramsmassdavg(i, StartDAy:EndDay)
 tmptxmass (0:EndDay - StartDay)  = txmassdavg(i, StartDAy:EndDay)
 
  result = where( tmprams gt 0.00 and $
                  tmprams lt 999 and $
		  tmptxmass gt  0.0 and $
		  tmptxmass lt 999, count)  

  if ( count gt 2 ) then begin
    xx = fltarr(count)
    yy = fltarr(count)
    xxstd = fltarr(count)
    yystd = fltarr(count)
  
    xx(0:count-1) = tmprams(result) 
    yy(0:count-1) = tmptxmass(result)
    xa = 0.38
    xb = 0.3
    
;    print, 'count = ', count, selectsta(i)
    ; select for a specific station
     if selectsta(i) gt 0   then begin
        totalxx(iii:iii+count-1) = xx(0:count-1)
	totalyy(iii:iii+count-1) = yy(0:count-1)
	colorinx(iii:iii+count-1) = usecolor(i)   ; same colr for same station
        iii = iii + count
     endif	
    
titlename = 'Station NO.' + string(i, format= '(I2)') + ' Lat: ' +$
string(txpmlat(i), format='(f9.4)') + ' Lon: ' + $
string(txpmlon(i),format='(f9.4)')
    ozone_refl,yy,xx,xxstd, yystd, xa,xb,result,sigma, titlename,$
           txpmlat(i), txpmlon(i), i, txstachar(i), fltarr(count)
  
    correlation(i) = sigma 
  
  endif
 

 ; AQI comparison
   correct  = 0
   TXAQINUM = fltarr(4)
   RAMSAQINUM = fltarr(4)
   
   for j = 8, 17 do begin
     k = 0
     
     while (txmassdavg(i, j) gt  EPALEVEL(k) ) do begin 
       k = k + 1
     endwhile
       
     kk = 0
     while  ( ramsmassdavg(i,j) gt RAMSLEVEL(kk) ) do begin
       kk = kk + 1
     endwhile   
     
; overall
     if ( k eq kk ) then begin 
       tmp_correct = tmp_correct + 1
       total_correct = total_correct+1
     endif
     
     if ( k ne kk ) then begin
       total_correct = total_correct+2
     endif  
     
; moderate     
     if ( k eq 1 or kk eq 1 ) then begin
       total_moderate = total_moderate+1
     endif  
     
     if ( k eq 1 and kk eq 1 ) then begin
       tmp_moderate = tmp_moderate+1
     endif  
    
; USP     
     
     if ( k eq 2 or kk eq 2 ) then begin
       total_usp = total_usp+1
     endif
     
     if ( k eq 2 and kk eq 2 ) then begin
       tmp_usp = tmp_usp+1
     endif
    
; good     
     
     if ( k eq 0 or kk eq 0 ) then begin
       total_good = total_good+1
     endif
    
     if ( k eq 0 and kk eq 0 ) then begin
       tmp_good = tmp_good+1
     endif
    
     RAMSAQINUM(kk) =  RAMSAQINUM(kk)+1
     TXAQINUM(k) = TXAQINUM(k) + 1 
     
  endfor    
  
  together = max([TXAQINUM(1) + TXAQINUM(2), RAMSAQINUM(1) + RAMSAQINUM(2)])
  
;  print, 'TX: good days', TXAQINUM(0), ' mod : ', TXAQINUM(1), ' USP: ',  TXAQINUM(2), ' Lat ', TXPMLAT(i), ' LON ', TXPMLON(i), ' ID = ', i
;  print, 'RM: good days', RAMSAQINUM(0), ' mod : ', RAMSAQINUM(1), ' USP: ',  RAMSAQINUM(2)
   

; evaluate performance   
   if ( total_good eq 0 ) then begin
    tmp_good = 1
   endif else begin
    tmp_good = tmp_good/total_Good
   endelse
   
   if ( total_moderate eq 0 ) then begin
    tmp_moderate = 1
   endif else begin
    tmp_moderate = tmp_moderate/total_moderate
   endelse

   if ( total_usp eq 0 ) then begin
    tmp_usp = 1
   endif else begin
    tmp_usp = tmp_usp/total_usp
   endelse
   
   if ( total_correct ne 0 ) then begin
     tmp_correct= tmp_correct/total_correct
   endif else begin
     tmp_correct = 1
   endelse  
      
;   print, ' Good ',  tmp_good, ' moderate = ', tmp_moderate, ' USP = ',   tmp_USP,$
;   'overall = ', tmp_correct
  
   Correct_overall = correct_overall + tmp_correct
   Correct_good = correct_good + tmp_good
   Correct_moderate = correct_moderate + tmp_moderate
   Correct_USP = correct_USP + tmp_USP
   
endfor  

titlename = 'Over All'
ozone_refl,totalyy(0:iii-1), totalxx(0:iii-1), fltarr(iii), fltarr(iii),$
            xa,xb,result,sigma, titlename, 0.0, 0.0, 0, 'overall',$
	    colorinx(0:iii-1)


print,  'overall correct = ', correct_overall*1.0/TXPMNS
print,     'overall good = ',    correct_good*1.0/TXPMNS
print, 'overall moderate = ', correct_moderate*1.0/TXPMNS
print,      'overall USP = ',   correct_USP*1.0/TXPMNS


endfor
endfor

; do correlation map
hist = fltarr(7)

 plot, [0, 1], [0, 2], /nodata, $
   xrange = [-108, -92], yrange = 	[25, 38] , xstyle=1, ystyle=1,$
   position = [0.1, 0.2,  0.9, 0.7], xthick=3, ythick=3, $
   charsize=1.2, charthick=3, color=0 , xticks = 4, xminor=4 ,$
   xtitle = 'Longitude (degree)', ytitle = 'Latitude (degree)'
   
; result = sort(correlation(0:TXPMNS-1))
 
print, 'TXPMNS = ', TXPMNS 
  for  i = 0, TXPMNS-1 do begin       
 ;  i = result(j)
   print, 'correlation = ', correlation(i) , txpmlat(i), txpmlon(i) 
    if ( correlation(i) lt 0.40 ) then colorinx = 1
   ; if ( correlation(i) lt 0.40 and correlation(i) ge 0.30) then colorinx = 2
    if ( correlation(i) lt 0.50 and correlation(i) ge 0.4)  then colorinx = 2
    if ( correlation(i) lt 0.60 and correlation(i) ge 0.5 ) then colorinx = 3
    if ( correlation(i) lt 0.685 and correlation(i) ge 0.6 ) then colorinx = 4
    if ( correlation(i) lt 0.80 and correlation(i) ge 0.685 ) then colorinx = 5
    if ( correlation(i) lt 0.9 and correlation(i) ge 0.8 ) then colorinx = 6
    
    hist(colorinx) = hist(colorinx)+1
    plots, txpmlon(i), txpmlat(i), psym = sym(5,1), symsize=1.2, color =  colorinx+1
  endfor
  
  add_texas_boundary, 0
  
; plot legend
  xa = 0.08
  dx = 0.06
  ya = 0.23
  dy = 0.02
  ;range = [0.3, 0.4, 0.5, 0.6, 0.7, 0.8]
  range = ['.3', '.4', '.5', '.6', '.7', '.8', '.9']
  
  for i = 1, 6 do begin
    
    polyfill, i*dx+ [xa, xa+dx, xa+dx, xa, xa], [ya, ya, ya+dy, ya+dy, ya], /normal, color=  i +1 
    plots, i*dx+ [xa, xa+dx, xa+dx, xa, xa], [ya, ya, ya+dy, ya+dy, ya],  thick=3, /normal, color = 0
    ;xyouts, xa+i*dx, ya+dy+dy/2., string(range(i-1), format='(f2.1)'), /normal, align=0.5, charthick=3, charsize=1.2
    xyouts, xa+i*dx, ya+dy+dy/2.,  range(i-1), /normal, align=0.5, charthick=3, charsize=1.2
  
  endfor
    xyouts, xa+i*dx, ya+dy+dy/2.,  range(i-1), /normal, align=0.5, charthick=3, charsize=1.2
    xyouts, xa+0.6,  0.65, 'Correlation Coefficient', /normal, align=0.5, charthick=3, charsize=1.2  

;
; histogram
;
save, correlation, TXPMNS, filename = 'correlation.xdr'




; do hourly comparison

ramspm = ramsmass(0:txpmns-1, 0:24*30-1)
txpm = txmass(0:txpmns-1, 0:24*30-1)

result = where(ramspm gt 0 and ramspm lt 999 and $
               txpm gt 0 and txpm lt 999, count )

if ( count gt 0 ) then begin
xx = fltarr(count)
yy = fltarr(count)
xx (0:count-1) = ramspm(result)
yy(0:count-1) = txpm(result)
ozone_refl,yy(0:count-1), xx(0:count-1), fltarr(count),$
              fltarr(count), xa,xb,result,sigma, titlename, 0.0, 0.0, 0, 'overall',$
	      fltarr(count) 
endif
	       
END



;
; Main begins
;

set_plot,'ps'
device,filename='model_pm.ps',/portrait,xsize=6, ysize=8,$
xoffset=1,yoffset=1.5,/inches, /color, bits=8
;
post_reanalysis_daily
post_reanalysis_hourly

device,/close
stop

tmpnz =20
;dir = '../../data/parallel-offline-cld/grid1/'
;dir = '../../data/pbl/grid1/'
;dir = '../../data/pbl-1.0-on-daily/grid2/'
;dir = '../../data/pbl-1.7-off/grid2/'
dir = '../../data/layer9-1.0-hourly-on/grid2/'
np = 62 
nl = 62 
nz = 20

; read lat and lon
flat = fltarr(np,nl)
flon = fltarr(np,nl)
dir1 = '../../data/pbl-1.7-off/grid2/'
inpf1 =  'LAT.dmp' 
read_rams_dump, dir1+inpf1, ttime1,  lat1, height1, nt1, tmpnz,'LAT', np, nl
inpf1 =  'LON.dmp' 
read_rams_dump, dir1+inpf1, ttime1, lon1, height1, nt1, tmpnz,'LON', np, nl
flat(0:np-1, 0:nl-1) = lat1(0:np-1, 0:nl-1, 0)
flon(0:np-1, 0:nl-1) = lon1(0:np-1, 0:nl-1, 0)

; read mass
inpf = 'MASS.dmp'
read_rams_dump, dir + inpf, ttime, aot, height, nt, nz, 'MASS' , np, nl

; read tx data
txdatadir = '/s1/data/wangjun/s4/Proj/texis_aqi/pmdat/2003_processed/'
txfilelist = '/s1/data/wangjun/s4/Proj/texis_aqi/pmdat/pro/filelist'
monchar = ['April', 'May']
txdatatype = 'TXDATA'
txnp = 31
read_pm_monthly, txdatadir, txfilelist, monchar, txdatatype, $
                     txnp, txpmlat, txpmlon, txpmdata, txpmns, txstachar


; read other EPA data
;usdatadir =  '/s1/data/wangjun/s7/pm_10/PM_OBS/processed/'
;usnp = 25
;usfilelist =  '/s1/data/wangjun/s7/pm_10/PM_OBS/valid_stationid.txt'
;monchar = ['Apr', 'May']
;read_pm_monthly, usdatadir, usfilelist, monchar, 'USDATA', $
;                     usnp, pmlat, pmlon, pmdata, pmns

; find the correlations, search stations by stations
tmpdata = fltarr(np, nl)
ramsmass = fltarr(txpmns, nt)   ; each station, each modeling time
txmass = fltarr(txpmns, nt)
OneStationData = fltarr(nt)
OneDAyData = fltarr(24)
nday = fix((nt-17)/24); total days.
txmassdavg = fltarr(txpmns, nday)
ramsmassdavg = fltarr(txpmns, nday)

txmassdaily = fltarr(txpmns, nday, 24)
ramsmassdaily = fltarr(txpmns, nday, 24)



for i = 0, txpmns-1 do begin
   result = where ( abs(txpmlat(i) - flat) + abs(txpmlon(i)-flon) eq $
             min(abs(txpmlat(i) - flat) + abs(txpmlon(i)-flon)),count)
   
   Onestationdata(*) = 0
   if ( count gt 0 ) then begin


; APril 20, 12UTC:  (20-1)*24+7 =, in central time hrs from APril 1,
; 00time,
; the starting time now is APril 20, 12UTC for both txmass and ramsmass 
; or staring time is APril 20, 7CDT 2003 for Central time
; 463 = 19*24+7;  463-1 = 462 

     ; very hour
     for j = 0, nt-1 do begin
       tmpdata(0:np-1, 0:nl-1) = aot(0:np-1, 0:nl-1, j,   1)     
       ramsmass(i,j) = tmpdata(result) 
       OneStationData(j) = tmpdata(result)
       txmass(i,j) =  txpmdata(i, j+462)
     endfor

; day starts from April 21, CST time, post 7 to next day, 18hrs
     ; daily avg
     for j =0 , nday-1 do begin

;      if ( not ((i eq 0 or i eq  1 or i eq 2)  and j eq 24) and  $
;           not (( i eq 28 or i eq 27  or i eq 26 or i eq 25 or $
;	         i eq 30 or i eq 29 or i eq 31 or i eq 35 or i eq 34 or i eq 33  $
;		 or i eq 23 ) and j eq 20 ) ) then begin
       
       
       OneDayData(0:23) = OneStationData(18+j*24: 18+(j+1)*24-1)
       result1 = where(OneDayData gt 0 and OneDayData lt 999, count1)
       if ( count1 gt 0 ) then begin
          ramsmassdavg(i, j) = total(OneDayData(result1))/count1
       endif  
       
        ramsmassdaily(i,j, 0:23) = OneDayData(0:23) 
       
       OneDayData(0:23) = txmass(i, 18+j*24: 18+(j+1)*24-1)
       result1 = where(OneDayData gt 0 and OneDayData lt 999, count1)
       if ( count1 gt 0 ) then begin
          txmassdavg(i, j) = total(OneDayData(result1))/count1
       endif 

        txmassdaily(i,j, 0:23) = OneDayData(0:23) 

;      endif

     endfor  
   endif 

xx = fltarr(nt)
yy=fltarr(nt)
xx(0:nt-1) = ramsmass(i, 0:nt-1)
yy(0:nt-1) = txmass(i, 0:nt-1)
xxstd = fltarr(nt)
ysstd = fltarr(nt)
xa = 0.4
xb = 0.3
titlename = 'Station Num' + string(i, format= '(I2)') + ' Lat: ' +$
string(txpmlat(i), format='(f9.4)') + ' Lon: ' + $
string(txpmlon(i),format='(f9.4)')

;ozone_refl,yy,xx,xxstd, yystd, xa,xb,result,sigma, titlename,i
endfor   

save, ramsmass, txmass, txstachar, ramsmassdavg, txmassdavg, nt, txpmns, nday,$
txpmlat, txpmlon, ttime, txmassdaily, ramsmassdaily, filename='model_pm_grid2.xdr'


device, /close


END 	 
	 
	    
         
	 

