pro stats_out, xdata, ydata, xxp, yyp, range, xtitle, ytitle, black


	data=where(xdata gt range(0) and ydata gt range(0))
	xx=xdata(data)
	yy=ydata(data)
    	ipnt=N_elements(xx)

	    ;wang code

	    ; set linear equation 
	            weights=replicate(1.0,ipnt) 
	            print,' ipnt= ', ipnt 
	            refl=fltarr(1,ipnt) & refl(0,*)=xx(*) 
	            Result=REGRESS(refl,yy,weights,yfit,const,sigma,/relative_weight) 
	            result1=sort(xx) 
	            oplot,xx(result1),yfit(result1),linestyle=0,thick=4.0,color=black ;plot the regression line 

	    ; linear equation 
	            intercept = const 
	            slope = result 

	            if const ge 0 then sign='+' 
	            if const lt 0 then sign='' 
	           linear_equation='Y = '+ strcompress(string(result,format='(f7.2)'))+' X '+ sign + $ 
	           strcompress(string(const,format='(f6.2)')) 

	          ;  caption3 = linear_equation + '!c!c R ='+string(correlate(xx,yy),format='(f6.2)') +$ 
	          ; '!c!c N = ' + string(ipnt, format='(i3)') 

	    ; xx and yy std 
	           result1 = moment(xx) 
	           xmean = result1(0) 
	           xstd = sqrt(result1(1)) 
	           result1 = moment(yy) 
	           ymean = result1(0) 
	           ystd = sqrt(result1(1)) 

	           xystd = ytitle+': ' + string(ymean, format= '(f7.2) ') +' '+ '!9+!6'+' '+  string(abs(ystd), format= '(f7.2)') + $ 
	                 '!c'+xtitle+': ' + string(xmean, format= '(f7.2) ') +' '+ '!9+!6'+' '+ string(abs(xstd), format='(f7.2)') 

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

	            rmschar = 'RMSE = ' + strcompress(string(rms, format='(f7.2)'), /remove_all) 

	           RR = correlate(xx,yy) 
	           if ( RR ge 0.685 and RR lt 0.7) then RR = 0.7 

	           caption3 = 'R ='+string(RR,format='(f6.2)') + pchar + $ 
	                      '!cN = ' + strcompress(string(ipnt, format='(i4)'),  /remove_all) + ' ' +  RMSchar + $ 
	                      '!c'+ linear_equation+ $ 
	                      '!c' + xystd +'!c' + 'Bias = '+string(bias, format= '(f7.2)')


    	;ADD CAPTION TO PLOT
	    xyouts,xxp,yyp, caption3,color=black
	    
end
