;
;purpose: calculate AQI
;
pro ozone_refl,yy,xx,xxstd, yystd,  xmedian, ymedian, xa, xb, slope, icpt


   ipnt=N_elements(xx)
   for i = 0, ipnt - 1 do begin
;    oplot, [xx(i), xx(i)], [yy(i)-yystd(i), yy(i)+yystd(i)], thick=5
;    oplot, [xx(i)-xxstd(i), xx(i)+xxstd(i)], [yy(i), yy(i)], thick=5
; plot box cursors
     if (yy(i) lt yystd(i) ) then yystd(i) = yy(i)-0.02
     oplot, [xx(i)-xxstd(i), xx(i)+xxstd(i),   xx(i)+xxstd(i), $
             xx(i)-xxstd(i), xx(i)-xxstd(i) ], $
            [yy(i)-yystd(i), yy(i)-yystd(i),  yy(i)+yystd(i), $
	     yy(i)+yystd(i), yy(i)-yystd(i) ], thick=7, color=2
     
     oplot,[xmedian(i), xmedian(i)], [yy(i)+yystd(i), yy(i)-yystd(i)],$
           thick=7, color=3
     oplot,[xx(i)+xxstd(i), xx(i)-xxstd(i)], [ymedian(i), ymedian(i)],$
           thick=7, color=3

     plots, xx(i), yy(i),psym = sym(1), symsize=1.2, color=3
print, xxstd(i)


   endfor

; set linear equation
    weights=replicate(1.0,ipnt)
    print,' ipnt= ', ipnt
    refl=fltarr(1,ipnt) & refl(0,*)=xx(*)
    Result=REGRESS(refl,yy,weights,yfit,const,sigma,/relative_weight)
    result1=sort(xx)
    oplot,xx(result1),yfit(result1),linestyle=0,thick=7.0,color=3 ;plot the regression line

    ; add more statistics
    	result1 = moment(xx)
	print, 'xx mean=', result1(0), 'std = ', sqrt(result1(1))
	result1 = moment(yy)
	print, 'yy mean =', result1(0), 'std = ',sqrt(result1(1))
				 	
     ; calculate mean differences
        tot = 0.0
        totxx = 0.0
        totyy = 0.0
        for i = 0, ipnt-1 do begin
          xxx = (yy(i)-const)/result
	  tot = abs(xx(i)-xxx)^2 + tot
          totxx = totxx + xx(i)
          totyy = totyy + xxx
        endfor
       
      print, 'rms = ', sqrt(tot / ipnt)
      print, 'bias = '
      print, (totyy-totxx)/ipnt, format='(f8.5)'
      print, totyy, totxx 


    if const ge 0 then sign='+'
    if const lt 0 then sign=''
    
    icpt = const
    slope = result(0)
    linear_equation=' Y = '+string(result,format='(f5.3)')+' X '+ sign + $
               strcompress(string(const,format='(f6.3)'))
    
    captionR =  ' R ='+string(correlate(xx,yy),format='(f6.2)')
    print, 'linear equation = ', linear_equation, 'R = ',captionR 

    xyouts, xa, xb, linear_equation + '!c' + captionR, /normal, $
            charsize=1.5, charthick=3
end    

; pro to read file and calculate mean and  standard deviations.  
pro  read_file, inf, daypm, aot, nl 
nouse = ' '
PM = fltarr(3000)
DayStd = fltarr(3000)
DayTime = fltarr(3000)
StationN = fltarr(3000)
j = 0
openr, 1, InF
readf, 1, nouse
while ( not eof(1) ) do begin
  readf, 1, a, b, c, d,e, f
  PM(j)= a
  AOT(j) = b
  DayPM(j) = c
  DayStd(j) = d
  DayTime(j) = e
  StationN(j) = f
  j = j  +1
endwhile
close,1
nl = j
end

pro cal_aqi, daypm, aot, pmmean, pmmeanstd, aotmean, aotmeanstd, $
             AOTmedian, PMMedian, nl

; calculate mean as for AQI
; AQI 20 (good), 40(morderate) 60 unheathly for sensitive people 
;  80 unhealthy, 120 very unhealthy, 200 hazadous

; PM standard
  npt = nl                   ; total useful point
  NLEVEL = 12
  TmpPM = fltarr(npt)       ; tmp pm
  TmpAOT = fltarr(npt)      ; tmp AOT
  k = 0
  
  PMMEAN = fltarr(nlevel)   ; pm mean
  PMMEANSTD = fltarr(nlevel) ; pm std for different air quality levels
  
  AOTMEAN = fltarr(nlevel)
  AOTMEANSTD = fltarr(nlevel)
  
;  PMStd = [0, 40, 60, 80, 120, 200]
  
   PMStd = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45,50,55,60, 65, 70]
  
  
  for j = 0, NLEVEL-2 do begin
  k = 0
  for i = 0, npt-1 do begin
    if ( DayPM(i) gt PMSTD(j) and DAyPM(i) le PMSTD(j+1)) then begin
       TmpPM(k)= DayPM(i)
       TmpAOT(k) = AOT(i)
       k = k +1
    endif
  endfor
    
    if ( k ge 3 ) then begin
   	 result = moment( TmpPM(0:k-1) )
    	PMMean(j) = result(0)
    	PMMeanstd(j)= sqrt(result(1))
       
    	result = moment( TmpAOT(0:k-1))
    	AOTMEAN(j) = result(0)
    	AOTMEANSTD(j) = sqrt(result(1))
        
	AOTmedian(j) = median(TmpAOT(0:k-1), /even)
        PMMedian(j) = median(TmpPM(0:k-1), /even) 
	
       
	print, j, k, PMMean(j),PMMeanstd(j),  AOTMEAN(j), AOTMEANSTD(j)
    endif   	
  
 endfor

end

; read data

AInF = 'Final_Aqua_collocate.dat'
TInF = 'Final_Terra_collocate.dat'
adaypm = fltarr(3000)
tdaypm = fltarr(3000)
adayaot = fltarr(3000)
tdayaot = fltarr(3000)

read_file, Ainf, Adaypm, Adayaot, anl
read_file, Tinf, Tdaypm, Tdayaot, tnl


; merge data
daypm = fltarr(anl+tnl)
dayaot = fltarr(anl+tnl)
colorinx =intarr(anl+tnl)

daypm(0:anl-1) = adaypm(0:anl-1)
daypm(anl:anl+tnl-1) = tdaypm(0:tnl-1)
colorinx(0:anl-1) = 11 
dayaot(0:anl-1)= adayaot(0:anl-1)
dayaot(anl: anl+tnl-1) = tdayaot(0:tnl-1)
colorinx(anl: anl+tnl-1) =8 

; calculate box cursor
nlevel = 12
pmmean = fltarr(nlevel)
pmmeanstd= fltarr(nlevel)
aotmean= fltarr(nlevel)
aotstd = fltarr(nlevel)
aotmedian=fltarr(nlevel)
pmmedian=fltarr(nlevel)
cal_aqi, daypm, dayaot, pmmean, pmmeanstd, aotmean, aotmeanstd, $
          aotmedian, pmmedian, anl+tnl

;
; start to plot AOT for AQI at differnet intervals
; 

 set_plot, 'ps'
 device, filename = 'AQI_AOT.ps', xoffset=0.5, yoffset=0.5, $
          xsize = 7, ysize = 10, /inches, bits=9, /color

rr = [ 0,  125,  0, 255, 0, 255, 120, 140,   0,  255,  204, $
     214, 255, 255,  50,    0,  150, 255, 220, 0, 255, 255]

gg = [ 0,  180,  0,  0, 255, 220, 255, 228, 220,  180,  102,  $
      0,   0,  50,  50,  150, 0,  255, 220 , 220, 255, 180]

bb = [ 0, 240, 255,  0, 0, 180, 255, 200,   0,   50,  255, $
      147, 255,  50, 255,  255, 255, 255, 220, 0, 0, 0]

 tvlct, rr, gg, bb
	  

   plot, [0, 65], [0.0, 1.6], xtitle = $
   	' 24hr Average PM!d2.5!n Content (!4l!6gm!u-3!n)  ', $
         ytitle = 'MODIS AOT (0.55!4l!6m)', xthick=3, ythick=3,$
	 xstyle=1, ystyle=1, charsize=1.5, charthick=3, $
	 position = [0.15, 0.2, 0.9, 0.65],/nodata
	 
;   plots, [0.15, 0.9], [0.1, 0.1], /normal, thick=3
;   plots, [0.15, 0.15], [0.1, 0.12], /normal, thick=3
;   plots, [0.9, 0.9], [0.1, 0.12], /normal, thick=3	
;   plots, 0.15+[0.17, 0.17], [0.1, 0.12], /normal, thick=3	
;   plots, 0.15+[0.465, 0.465], [0.1, 0.12], /normal, thick=3
; change it to different colors
   polyfill, [0.15, 0.32, 0.32, 0.15, 0.15], [0.1, 0.1, 0.12, 0.12,0.10 ], color=19,/normal
   polyfill, [0.32, 0.615, 0.615, 0.32, 0.32], [0.1, 0.1, 0.12, 0.12,0.10 ], color=20,/normal
   polyfill, [0.615, 0.9, 0.9, 0.615, 0.615], [0.1, 0.1, 0.12, 0.12,0.10 ], color=21,/normal


   xyouts, 0.2, 0.105, 'Good', /normal, charthick=3, charsize=1.0
   xyouts, 0.4, 0.105, 'Moderate', /normal, charthick=3, charsize=1.0
   xyouts, 0.625, 0.105, 'Unhealthy Sens. Group', /normal, charthick=3	, charsize=1.0
   xyouts, 0.14, 0.08, '0', /normal, charthick=3, charsize=1 
   xyouts, 0.31, 0.08, '50', /normal, charthick=3, charsize=1
   xyouts, 0.60, 0.08, '100', /normal, charthick=3, charsize=1
   xyouts, 0.88, 0.08, '150', /normal, charthick=3, charsize=1
   xyouts, 0.35, 0.06, 'Air Quality Index (AQI)', /normal,charthick=3, charsize=1.5

	 
   usersym, cos(findgen(16)/15.*!pi*2), sin(findgen(16)/15.*!pi*2), /fill
   
  
 for i = 0, anl+tnl -1 do begin
   plots, DayPm(i),  DayAOT(i), psym=sym(2), symsize=0.6, color=COLORINX(I)
 endfor  

ozone_refl,AOTMean(0:nlevel-4),PMmean(0:nlevel-4), $
           PMmeanstd(0:nlevel-4), AOTmeanstd(0:nlevel-4), $
	   pmmedian(0:nlevel-4), aotmedian(0:nlevel-4),  0.21,0.60,slope, icpt


; plot legent
    xa = 40
    ya = 1.3
    dx = 3
    dy = 0.1
    plots, xa, ya, psym=sym(2), color=8
    plots, xa, ya-dy, psym = sym(2), color=11
    xyouts, xa+dx, ya-0.03, 'Terra', charsize=1.5, charthick=3
    xyouts, xa+dx, ya-dy-0.03, 'Aqua', charsize=1.5, charthick=3
;    plots, xa, ya-2*dy, psym=sym(1), color=3, symsize=1.2
;    xyouts, xa+dx, ya-2*dy-0.03, 'Mean', charsize=1.5, charthick=3

    

print, 'slope = ', slope, 'intercept = ', icpt	   

 print, 'modeled is over '
 
	   
 
 device, /close
 end  
   
   
   
   
   
   
   
   
   
   
   
     
     
   	 
	 	  
  
  
  
  
  
  
  
  
  
  
  
    
    
    
    
    
    
    
    
    
    
  
  





   
