;
; calculate statistics of mean of AOT and WATER, multiyear averages
;
PRO Multiyr_mean,  MONALL, WATERALL, AOTALL, COLORS, MeanWater, MeanAOT, sitename 
MeanWater = fltarr(12)
StdWater = fltarr(12)
MeanAOT = fltarr(12)
StdAOT = fltarr(12)
for i = 1, 12 do begin
  result = where(MONALL eq i, count)
  if (count gt 0 ) then begin
   tmp = moment(WATERALL(result))
   MeanWater(i-1) = tmp(0)
   StdWater(i-1) = sqrt(tmp(1))
   tmp = moment(AOTALL(result))
   MeanAOT(i-1) = tmp(0)
   StdAOT(i-1) = sqrt(tmp(1))
  endif
endfor

plot, [0.0, 3.0], [0.0, 0.4], xrange = [0, 4.0], yrange = [0., 0.4], $
        xtitle = '!6 CWP (cm)', $
        ytitle = '!6 AOT (0.67!4l!6m)', xstyle=1, ystyle=1, $
        position = [0.1, 0.3, 0.8, 0.8], /nodata, title = sitename + ' Monthly Average!c!c!c'
   for i = 0, 11 do begin
     oploterror, MeanWater(i),  MeanAOT(i), StdWater(i), StdAOT(i), color= colors(i)
     plots,  MeanWater(i),  MeanAOT(i), psym = sym(1), color= colors(i)
   endfor

plots, 4./5*(0.3+ findgen(12)*0.4), 2./3*(fltarr(12)+0.65), psym = sym(1), color=colors
xyouts,4./5*( 0.3+ findgen(12)*0.4), 2./3*(fltarr(12)+0.62), $
         ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', $
         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'], align=0.5, charsize=1.0

weights = 1.0 + fltarr(n_elements(MeanAOT))
A = [0.38, 0.732, 0.0]
AA = findgen(51)/10.
yfit = CURVEFIT(MeanWater, MeanAOT, weights, A, SIGMA, FUNCTION_NAME='gfunct')
gfunct, AA, A, F
oplot, AA, F, thick=3
gfunct, MeanWater, A, F
A1 = string(A(0), format='(f4.2)')
A2 = string(A(1), format='(f4.2)')
A3 = string(abs(A(2)), format='(f4.2)')

sequation =  '  Y = '+A1+'e!u'+A2 +'X!n -' + A3  
xyouts, 0.5, 0.35, sequation + $
                   '!c!c  R = ' + $
            string(correlate(MeanWater,  MeanAOT), format='(f4.2)') + '!c!c  N = 12'

print, 'curve explains variability ', correlate(F, MeanAOT)^2, ' ---%'

; calculate to see if the variability of water vapor is highly correlates
; with varaibility of water vapor
plot, [0.0, 3.0], [0.0, 0.4], xrange = [-2, 2], yrange = [-0.2, 0.2], $
        xtitle = '!4D!6CWP (cm, depature from respevely monthly mean)', $
        ytitle = '!4D!6AOT (0.67!4l!6m, epature from respevely monthly mean)', xstyle=1, ystyle=1, $
        position = [0.1, 0.3, 0.8, 0.8], /nodata, title = sitename+ ' Monthly Average!c!c!c'
  
   result = where (AOTALL gt 0, count)
   XX = findgen(count)
   YY = findgen(count)
   kk = 0 
   for i = 0, n_elements(AOTALL)-1  do begin
      mn = MonALL(i)-1
      if (mn ge 0 ) then begin 
        plots,  WATERALL(i) - MeanWater(mn),  AOTALL(i) - MeanAOT(mn), $
                psym = sym(1), color= colors(mn)
       XX(kk) = WATERALL(i) - MeanWater(mn)
       YY(kk) = AOTALL(i) - MeanAOT(mn)
       kk = kk + 1
      endif
    endfor
  
plots, 4./5*(0.3+ findgen(12)*0.4), 2./3*(fltarr(12)+0.65), psym = sym(1), color=colors
xyouts,4./5*( 0.3+ findgen(12)*0.4), 2./3*(fltarr(12)+0.62), $
         ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', $
         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'], align=0.5


weights = 1.0 + fltarr(n_elements(YY))
A = [0.38, 0.732, 0.0]
AA = findgen(61)/10.-3
yfit = CURVEFIT(XX, YY, weights, A, SIGMA, FUNCTION_NAME='gfunct')
gfunct, AA, A, F
oplot, AA, F, thick=3
gfunct, XX, A, F
A1 = string(A(0), format='(f4.2)')
A2 = string(A(1), format='(f4.2)')
A3 = string(abs(A(2)), format='(f4.2)')

NN = n_elements(XX)
if (NN ge 100) then SNN = string(n_elements(XX), format='(I3)')
if (NN lt 100) then SNN = string(n_elements(XX), format='(I2)')

sequation =  'Y = '+A1+'e!u'+A2 +'X!n -' + A3  
xyouts, -1, 0.15, sequation + $
                   '!c!c  R = ' + $
            string(correlate(YY,  XX), format='(f4.2)') + '!c!c  N = ' + SNN 
print, 'curve explains variability chage of AOT CWP', correlate(F, YY)^2, ' ---%'

best_fit, yy, xx, slope = slope, intercpt = intercpt
xyouts, 1, -0.1, 'A: ' + string(slope, format = '(f6.2)') + $
            '!c!c' + 'B: ' + string(intercpt, format = '(f6.2)') 

;
; Plot as monthly variation of AOT and Water Vapor 
;
 plot, [0, 3], [0, 500], xtitle='Month', ytitle='!4D!6AOT (0.67!4l!6m)', $
      xstyle =1, ystyle=1, yrange = [-0.15, 0.15], xthick=1, $
      ythick=1, charthick=1, xrange=[0.5, 12.5],$
      position=[0.2, 0.2, 0.9, 0.7], /nodata, yticks=6, yminor = 5, $
      title = sitename+ ' Monthly Average!c!c!c'

   plots, findgen(12)+1, MeanAOT-mean(MeanAOT), psym = sym(1)
   oplot, findgen(12)+1, MeanAOT-mean(MeanAOT) 

   axis,  ystyle=1, yaxis=1, /save, ythick=1, $
      yrange = [-1.5, 1.5], ytitle = '!4D!6CWP (cm)', $
      charthick=1, yticks=6, yminor = 5
;   plots, findgen(12)+1, MeanWater-mean(MeanWater), psym = sym(5), color=colors
   oplot, findgen(12)+1, MeanWater-mean(MeanWater), linestyle=2 
   plots, findgen(12)+1, MeanWater-mean(MeanWater), psym = sym(5), color=1 
   plots, findgen(12)+1, MeanWater-mean(MeanWater), psym = sym(10), thick=3

; add symolsA
   plots, 7.5,  -1.2, psym= sym(10)
   xyouts, 7.7, -1.22, '!4D!6CWP'
   arrow, 9.1, -1.2, 9.7, -1.2, /data
           
   plots, 5.5,  -1.2, psym= sym(1)
   xyouts, 5.7, -1.22, '!4D!6AOT'
   arrow, 5.1, -1.2, 4.5, -1.2, /data
 
  R =    correlate( MeanAOT-mean(MeanAOT), MeanWater-mean(MeanWater))
  SR = string(R, format = '(f4.2)')
   xyouts, 7, -0.7, 'N = 12 !c!c R = '+SR, align=0.5 

END

;
; PRO read single processed AERONET data
; 
 PRO  read_single_aeronet, filedir, sitename, AOT, WATER, $
       ANG, YEAR, MONTH, NDAY
  A = fltarr(22, 120000L)
  k = 0L
  nouse = ' '
  oneline= fltarr(22)
  filename =  filedir + 'mon_920801_080218_'+sitename+'.lev20'
  if (file_test(filename)) then begin
  openr, 1, filename
  readf, 1, nouse
  while(not eof (1) ) do begin
  readf, 1, oneline
  A(*, k) = oneline(*)
  k = k + 1L
  endwhile
  close, 1

; number averaged
  AOT = reform(A(2,0:k-2))   ; 0.67
  WATER = reform(A(4, 0:k-2))
  ANG = reform(A(5, 0:k-2))
  YEAR = reform(A(0,0:k-2))
  MONTH = reform(A(1, 0:k-2))
  NDay = reform(A(10, 0:k-2))
  endif else begin
   print, 'file can not find ...' 
   stop
  endelse
END

; best fit
; regression
  PRO best_fit, yy, xx, slope = slope, intercpt = intercpt, $
                yfit = yfit, ifplot = ifplot, title = title, $
                xrange = xrange, yrange = yrange, $
                position = position, pequation = pequation, $
                xtitle = xtitle, ytitle = ytitle, colors = colors

       ipnt = n_elements(xx)
       weights=replicate(1.0,ipnt)
       refl=fltarr(1,ipnt) & refl(0,*)=xx(*)
       Result=REGRESS(refl,yy,weights,yfit,const,sigma,/relative_weight)
       slope = result
       intercpt = const

       if not keyword_set(title)  then title = ' '
       if not keyword_set(ifplot) then ifplot = 0
       if not keyword_set(xtitle) then xtitle = ' '
       if not keyword_set(ytitle) then ytitle = ' '
   ;    if not keyword_set(xrange) then xrange = [0.90*min(xx), 1.1*max(xx)] 
   ;    if not keyword_set(yrange) then yrange = [0.90*min(yy), 1.1*max(yy)] 
       if not keyword_set(xrange) then xrange = [0.4, 3.6]
       if not keyword_set(yrange) then yrange = [0.0, 0.4]
       if not keyword_set(position) then position = [0.1, 0.3, 0.8, 0.8]
       if not keyword_set(pequation) then pequation = [0.2, 0.7]
       if not keyword_set(colors) then colors=0

       if ifplot eq 1 then begin
          plot, [0, 1], [0, 1], /nodata, xrange = xrange, yrange=yrange, xstyle=1, ystyle=1, $
                xtitle = xtitle, ytitle = ytitle, position = position
          xyouts, position(2) - (position(2) - position(0))*0.03 , $
                  position(1) + (position(3) - position(1))*0.03, $
                  title, align = 1.0 , /normal

          plots, xx, yy, psym = sym(1), color= colors
       endif

          if ( intercpt ge 0) then sign='+'
          if ( intercpt lt 0) then sign='-'
         linear_equation=' Y = '+strcompress(string(slope,format='(f10.3)')) +' X '+ sign + $
                               strcompress(string(const,format='(f10.3)'))
         print, 'linear equation :', linear_equation
         Rchar = ' R ='+string(correlate(xx,yy),format='(f6.2)') +$
                '!c!c N = ' + strcompress(string(ipnt, format='(i5)'), /remove_all)

     ;    xyouts, pequation(0), pequation(1), linear_equation +'!c!c' + Rchar, /normal
      if ifplot eq 1 then begin
         xyouts, pequation(0), pequation(1), Rchar, /normal
      endif
 END



PRO gfunct, X, A, F, pder
  bx = EXP(A[1] * X)
  F = A[0] * bx + A[2]

;If the procedure is called with four parameters, calculate the  
;partial derivatives.  
  IF N_PARAMS() GE 4 THEN $
    pder = [[bx], [A[0] * X * bx], [replicate(1.0, N_ELEMENTS(X))]]

END


PRO ready_trend, XX, YY, slope, intercpt
    weights=replicate(1.0,N)
    refl=fltarr(1,N) & refl(0,*)=XX(*)
    Result=REGRESS(refl,yy,weights,yfit,const,sigma,/relative_weight)
    slope = result
    intercpt = const
    oplot, XX, XX*slope + intercpt
END

PRO Trent, A, Year, Month
;  N = n_elements(A)
;  BB = sort(YEAR)
;  NewA = A(result)
;  NewYear = 
  weights=replicate(1.0,N)
  refl=fltarr(1,N) & refl(0,*)=XX(*)
  Result=REGRESS(refl,yy,weights,yfit,const,sigma,/relative_weight)
       slope = result
       intercpt = const

    plot, [1990, 2010], [0, 1], xrange= [1990, 2010], $
          xstyle=1, ystyle=1, yrange = [0, 6], /nodata
        plots, year, A, psym = sym(1)

        for i = 0, 11 do begin
          result = where ( month eq i, count)
          if ( count gt 0 ) then begin
             YYear = Year(result)
             AA = A(result)
             NewAA = AA(sort(YYear))
             ready_trend, YYear(sort(YYEAR)), NEWAA, slope, intercpt
           endif
        endfor
END

;
; PRO
;
PRO process_alldata, nf, filedir, sitename, LAT, LON, ELV, colors, AOTALL, $ 
       WATERALL,  MONALL,  YEARALL, DAOTALL,  DWATERALL,  DMONALL, $
       fileselected

  NS = 0
  FS = 0
  AOTALL = fltarr(3500)
  WATERALL = fltarr(3500)
  MONALL =  fltarr(3500)
  YEARALL = fltarr(3500)
  DAOTALL = fltarr(3500)
  DWATERALL = fltarr(3500)
  DMONALL = fltarr(3500)
  Fileselected = fltarr(100)

  openw, 3, 'aeronet_sitename_seUS_statis.txt'
  for i = 0, nf-1 do begin
  ; read data
  read_single_aeronet, filedir, sitename(i), AOT, WATER, $
       ANG, YEAR, MONTH, NDAY

  ; month that has the data
  result = where (AOT gt 0 and WATER GT 0 and ANG ne -9 and YEAR lt 2008, count1)
  YEARR = YEAR(result)
  MONN = month(result)

  ; process data in monthes that has the data for statiscal analysis
  result = where (AOT gt 0 and WATER GT 0 and ANG ne -9 and NDay ge 10 $
                  and YEAR lt 2008, count)
  if ( count gt 24 and lat(i) gt 20 and lat(i) le 50 $
         and lon(i) gt -100 and lon(i) le -60) then begin

; selectee files
  fileselected(fs) = i
  fs = fs+1

; collected data for selected files for further analysis
  AAOT = AOT(result)
  WWATER = WATER(result)
  NN = n_elements(WWATER)
  YYEAR = YEAR(result)
  MMON = month(result)

  ; out other statistics for put in the table
  correlation = correlate(AAOT, WWATER)
  AOTSTATIS = moment(AAOT)
  WATERSTATIS = moment(WWATER)
  AOTmean = AOTSTATIS(0)
  AOTstd = sqrt(AOTSTATIS(1))
  Watermean = WATERSTATIS(0)
  Waterstd = sqrt(WATERSTATIS(1))
 
  printf, 3, sitename(i), lat(i), lon(i), elv(i), yyear(0), $
             mmon(0), yearr(count1-1), monn(count1-1), $
             count, count1, correlation, count*1.0/count1, AOTMEAN, $
             AOTSTD, WATERMEAN, WATERSTD, format = '(a20, 15(1x, f10.5))'

  AOTALL(NS:NS+NN-1) = AAOT(0:NN-1)
  WATERALL(NS:NS+NN-1) = Wwater(0:NN-1)
  MONALL(NS:NS+NN-1) = MMON(0:NN-1)
  YEARALL(NS:NS+NN-1) = YYEAR(0:NN-1)
  NS = NS + NN
  print, sitename(i), 'NN = ', NN, NS

; further ploting
  plot, [0.0, 3.0], [0.0, 0.6], xrange = [0, 5.0], yrange = [0., 0.6], $
        xtitle = '!6CWP (cm)', ytitle = '!6AOT (0.67!4l!6m)', xstyle=1, ystyle=1, $
        position = [0.1, 0.3, 0.8, 0.8], /nodata, title = sitename(i)

  plots,  Wwater,  AAOT, psym = sym(1) , color = colors(mmon-1)
  save, file = sitename(i) + 'water_aot.xdr',  AOT, WATER, AAOT, WWATER, YYEAR, MMON, result, /verbose

; also save AOT and water vapor starting from Jan 1, 2000 onward
  AOTTime = fltarr(96)
  PWTime = fltarr(96)
  INDX = (YYEAR-2000)*12 + MMON-2        ; MODIS data starts from Feb.
  for iindx = 0, n_elements(INDX)-1 do begin
    if (indx(iindx) ge 0 ) then begin
        AOTTime(indx(iindx)) = AAOT(iindx)
        PWTime(indx(iindx)) = WWATER(iindx)
    endif
  endfor
  save, file = sitename(i) + 'water_aot_time.xdr', AOTTime, PWTime, /verbose
  endif

endfor

best_fit,  AOTALL(0:NS-1), WATERALL(0:NS-1), ifplot = 1, title = '  ', $
  xtitle = '!6CWP (cm)', ytitle = '!6AOT (0.67!4l!6m)', $
   xrange = [0.0, 5], yrange = [0, 0.6], colors = colors(MONALL(0:NS-1)-1)

xyouts, 0.18, 0.73, '   Y = 0.11e!u0.36X!n - 0.09', /normal

result = poly_fit(WATERALL(0:NS-1),  AOTALL(0:NS-1), 2)
AA = findgen(51)/10.
;oplot, AA, poly(AA, result), thick=5 
;F = poly(WATERALL(0:NS-1), result)
print, 'result = ', result

weights = 1.0 + fltarr(n_elements(AOTALL(0:NS-1)))
A = [0.38, 0.732, 0.0]
yfit = CURVEFIT(WATERALL(0:NS-1), AOTALL(0:NS-1), weights, A, SIGMA, FUNCTION_NAME='gfunct')
gfunct, AA, A, F
oplot, AA, F, thick=3
gfunct, WATERALL(0:NS-1), A, F
print, 'A = ', A
print, 'curve explains variability ', correlate(F, AOTALL(0:NS-1))^2, ' %'

plots, 0.3+ findgen(12)*0.4, fltarr(12)+0.65, psym = sym(1), color=colors
xyouts,0.3+ findgen(12)*0.4, fltarr(12)+0.62, $
         ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', $
         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'], align=0.5, charsize=1.0

fileselected = reform(fileselected(0:fs-1))

END    
