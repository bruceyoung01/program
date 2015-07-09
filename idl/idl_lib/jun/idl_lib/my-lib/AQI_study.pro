;
;purpose: calculate AQI
;
pro ozone_refl,yy,xx,xxstd, yystd, xa,xb, slope, icpt

   ipnt=N_elements(xx)
   for i = 0, ipnt - 1 do begin
    plots, xx(i), yy(i),psym = 8, symsize=1.3
    oplot, [xx(i), xx(i)], [yy(i)-yystd(i), yy(i)+yystd(i)], thick=5
    oplot, [xx(i)-xxstd(i), xx(i)+xxstd(i)], [yy(i), yy(i)], thick=5
    print, xxstd(i)
   endfor

; set linear equation
    weights=replicate(1.0,ipnt)
    print,' ipnt= ', ipnt
    refl=fltarr(1,ipnt) & refl(0,*)=xx(*)
    Result=REGRESS(refl,yy,weights,yfit,const,sigma,/relative_weight)
    result1=sort(xx)
    oplot,xx(result1),yfit(result1),linestyle=0,thick=5.0,color=1 ;plot the regression line

    if const ge 0 then sign='+'
    if const lt 0 then sign=''
    
    icpt = const
    slope = result(0)
    linear_equation=' Y = '+string(result,format='(f5.3)')+' X '+ sign + $
               strcompress(string(const,format='(f6.3)'))
    
    captionR =  ' R ='+string(correlate(xx,yy),format='(f6.2)')

    xyouts, xa, xb, linear_equation + '!c' + captionR, /normal, $
            charsize=1.5, charthick=3
end    


; read data

;InF = 'Final_Aqua_collocate.dat'
InF = 'Final_Terra_collocate.dat'
nouse = ' '
PM = fltarr(3000)
DayPM = fltarr(3000)
DayStd = fltarr(3000)
AOT = fltarr(3000)
DayTime = fltarr(3000)
StationN=fltarr(3000)
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

; calculate mean as for AQI
; AQI 20 (good), 40(morderate) 60 unheathly for sensitive people 
;  80 unhealthy, 120 very unhealthy, 200 hazadous

; PM standard
  npt = j                   ; total useful point
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
	print, j, k, PMMean(j),PMMeanstd(j),  AOTMEAN(j), AOTMEANSTD(j)
    endif   	
  
 endfor
  
;
; start to plot AOT for AQI at differnet intervals
; 

 set_plot, 'ps'
 device, filename = 'AQI_AOT.ps', xoffset=0.5, yoffset=0.5, $
          xsize = 7, ysize = 10, /inches
	  

   plot, [0, 60], [0.0, 1.6], xtitle = $
   	' 24hr Average PM2.5 Content (!4l!6g/m!u3!n)  ', $
         ytitle = 'MODIS/AQUA AOT (0.55!4l!6m)', xthick=3, ythick=3,$
	 xstyle=1, ystyle=1, charsize=1.5, charthick=3, $
	 position = [0.15, 0.2, 0.9, 0.60],/nodata
	 
  
   plots, [0.15, 0.9], [0.1, 0.1], /normal, thick=3
   plots, [0.15, 0.15], [0.1, 0.12], /normal, thick=3
   plots, [0.9, 0.9], [0.1, 0.12], /normal, thick=3	
   plots, [0.4, 0.4], [0.1, 0.12], /normal, thick=3	
   plots, [0.65, 0.65], [0.1, 0.12], /normal, thick=3
   xyouts, 0.2, 0.105, 'Good', /normal, charthick=3, charsize=1.5
   xyouts, 0.45, 0.105, 'Moderate', /normal, charthick=3, charsize=1.5
   xyouts, 0.7, 0.105, 'Unhealthy', /normal, charthick=3	, charsize=1.5
   xyouts, 0.35, 0.07, 'Air Quality Index (AQI)', /normal,charthick=3	, charsize=1.5	
	 
   usersym, cos(findgen(16)/15.*!pi*2), sin(findgen(16)/15.*!pi*2), /fill
   
  
 ozone_refl,AOTMean(0:nlevel-4),PMmean(0:nlevel-4), $
           PMmeanstd(0:nlevel-4), AOTmeanstd(0:nlevel-4), $
	   0.18,0.57,slope, icpt

 for i = 0, npt -1 do begin
   plots, DayPm(i),  AOT(i), psym=1
 endfor  

print, 'slope = ', slope, 'intercept = ', icpt	   

; tested model result
;  plot, [0, 60], [0, 100], xtitle = ' PM2.5 content (AQI) ', $
;         ytitle = 'MODIS derived PM2.5', xthick=3, ythick=3,$
;	 xstyle=1, ystyle=1, charsize=1.5, charthick=3, $
;	 position = [0.15, 0.2, 0.9, 0.7]

 
;  ozone_refl,(AOT(0:npt-1)-icpt)/slope,DayPM(0:npt-1), $
;           fltarr(npt), fltarr(npt), $
; 	   0.4,0.6,result,sigma
  
 ; ozone_refl,AOT(0:npt-1),DayPM(0:npt-1), $
 ;          fltarr(npt), fltarr(npt), $
;	   0.4,0.6,result,sigma

 print, 'modeled is over '
 
; showing how much accuracy for testing air quality
 
  JulianD = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365] 
  PMStd = [0, 40, 60, 80, 120, 200]
  DiffNum = 0
  NumSta = 7
  StaDiffN = 0.
  StaObsN = 0.
  
!p.multi = [0, 1, 7] 

; open a file, save it for furhter processing
  openw, 1, 'AQI_STATION_'+INF
  printf, 1, 'JulianD, Date,  AQI, DAQI'
 
for k = 0, NumSta-1 do begin

   StaObsN = 0
   StaDiffN = 0
   
  ;plot, [1, 365], [-1, 3], xtitle = ' AQI derived from PM2.5 content ', $
  ;       ytitle = 'AQI derived from MODIS', xthick=3, ythick=3,$
;	 xstyle=1, ystyle=1, charsize=1.5, charthick=3, $
;	 position = [0.15, 0.2+k*0.1, 0.9, 0.2+(k+1)*0.07]
;
   plot, [1, 365], [-1, 2], xthick=3, ythick=3,$
	 xstyle=1, ystyle=1, charsize=1.5, charthick=3, $
	 position = [0.15, 0.2+k*0.1, 0.9, 0.2+(k+1)*0.1], $
	 /nodata, yticks = 3

	 
  for i = 0, npt -1 do begin
   
   
   if ( StationN(i) eq k ) then begin
     Tmp = (AOT(i)-icpt)/slope   ; derived PM
     StaObsN = StaObsN + 1
     
  for j = 0, 4 do begin
     if ( DayPM(i) gt PMSTD(j) and DayPM(i) lt PMSTD(j+1)) then begin
        AQI = j
     endif 	
     
     if ( Tmp gt PMSTD(j) and Tmp lt PMSTD(j+1) ) then begin
        DAQI = j               ; derived AQI
     endif
  endfor       
    
      if ( AQI ne DAQI ) then begin
         DiffNum = DiffNum+1
	 StaDiffN = StaDiffN + 1
      endif
       	 
      JDay = JulianD(fix(Daytime(i)/100)-1) + Daytime(i) - fix(Daytime(i)/100)*100
     
      usersym, cos(findgen(16)/15.*!pi*2), sin(findgen(16)/15.*!pi*2)
      plots, Jday, AQI, psym = 8, symsize = 0.8
      usersym, cos(findgen(16)/15.*!pi*2), sin(findgen(16)/15.*!pi*2), /fill
      plots, Jday, DAQI, psym=8, symsize = 0.4
      
      if ( k eq 3 ) then printf, 1, Jday, Daytime(i), DAQI, AQI
      
      
      if ( AQI gt 2 or DAQI gt 2 ) then print, 'larger than 2'
    endif 
  endfor    ; end of i
  print, 'Accuracy ', k, 1 - StaDiffN*1.0/StaObsN

endfor  ; end of k

 print, 'accuracy = ', 1-Diffnum*1.0/npt

close, 1
	   
 
 device, /close
 end  
   
   
   
   
   
   
   
   
   
   
   
     
     
   	 
	 	  
  
  
  
  
  
  
  
  
  
  
  
    
    
    
    
    
    
    
    
    
    
  
  





   
