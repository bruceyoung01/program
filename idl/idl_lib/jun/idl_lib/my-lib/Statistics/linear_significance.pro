; routine to plot the linear fit, and print out 
; correlation, signficance level, and RMSE
; correlation signficance test following the 
; two-tailed assumption. If like to use one-detailed assumption
; change tarray(i) = t_cvf(parray(i)/2, ipnt-2) to
; tarray(i) = t_cvf(parray(i), ipnt-2)
; see t test following here
; http://en.wikipedia.org/wiki/Spearman%27s_rank_correlation_coefficient 

; INPUT:
;        yy, xx: input of y and x arrays 
;        xa, ya: the left bottom corner of the legend.

 pro linear_significance, yy,xx, xa,ya

        ; # of data points 
        ipnt=N_elements(xx)

        ; set equal weights to all points
        weights=replicate(1.0,ipnt)

        ; because regress in idl routine can be used for multiple 
        ; regression. so we need to change xx array, so that 
        ; the first dimention is # of variables
        refl=fltarr(1,ipnt) & refl(0,*)=xx(*)
        Result=REGRESS(refl,yy,weights,yfit,const,sigma,/relative_weight)
        
        ; plot the regression line
        result1=sort(xx)
        oplot,xx(result1),yfit(result1),linestyle=0,thick=4.0,color=0

        ; parameters for linear interpolation 
        intercept = const
        slope = result

        ; linear equation
        if const ge 0 then sign='+'
        if const lt 0 then sign=''
        linear_equation='Y = '+ strcompress(string(result,format='(f7.2)'))+$
                        ' X '+ sign + $
                         strcompress(string(const,format='(f6.2)'))

        ; xx and yy std
        result1 = moment(xx)
        xmean = result1(0)
        xstd = sqrt(result1(1))
        result1 = moment(yy)
        ymean = result1(0)
        ystd = sqrt(result1(1))
        xystd = 'Y: ' + string(ymean, format= '(f5.2)') + $
                '!9+!6'+  string(abs(ystd), format= '(f5.2)') + $
                '!cX: ' + string(xmean, format= '(f5.2)') + $
                '!9+!6'+ string(abs(xstd), format= '(f5.2)')

        ; add signicance level
        ; set several P levels. 
          Parray = 0.00001 + findgen(1001)*(0.05-0.0001)/1000.
           tarray = fltarr(1001)
           
        ; calcualte the cutoff value using the student's t test
        ; two-tailed  probability for the corresponding numbers
          for i = 0, 1000 do begin
            tarray(i) = t_cvf(parray(i)/2, ipnt-2)
          endfor

        ; correlation coefficient
        ; see from here: http://people.richland.edu/james/lecture/m170/ch11-cor.html
          RR = correlate(xx,yy)
          tobs = RR * sqrt( (ipnt - 2)/(1 - rr^2) )
          result = where ( tarray lt tobs, count)
          if ( count gt 0 ) then Pchar = ' P < ' + $
             strcompress(string(parray(result(0)), $
             format = '(f10.5)'), /remove_all)
          if ( count le 0 ) then Pchar = ' P > 0.05'

        ; RMSE
          tot = 0.0
          totxx = 0.0
          totyy = 0.0
          for i = 0, ipnt-1 do begin
            tot = abs(xx(i)-yy(i))^2 + tot
            totxx = totxx + xx(i)
            totyy = totyy + yy(i)
          endfor
          rms = sqrt(tot / ipnt)
          
        ; mean bias 
          bias = (totyy-totxx)/ipnt
          rmschar = 'RMSE = ' + strcompress(string(rms, format='(f7.2)'), /remove_all)
        
        ; write out R, N, RMSE, Bias, MEAN+/-STD 
          caption3 = 'R ='+string(RR,format='(f6.2)') + pchar + $
                  '!cN = ' + strcompress(string(ipnt, format='(i4)'),  /remove_all) + $
                  ' ' +  RMSchar +  '!c'+ linear_equation+  '!c' + xystd

          xyouts,xa , ya , caption3,/normal
  END 
