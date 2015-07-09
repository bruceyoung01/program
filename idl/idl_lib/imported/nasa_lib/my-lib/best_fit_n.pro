; regression
  PRO best_fit_n, yy, xx, slope = slope, intercpt = intercpt, $
                yfit = yfit, ifplot = ifplot, title = title, $
                xrange = xrange, yrange = yrange, $
                position = position, pequation = pequation, $
                xtitle = xtitle, ytitle = ytitle,  $
                axiscolor=axiscolor, colors = colors, $
                number=number

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
       if not keyword_set(xycolor) then xycolor=0
       if not keyword_set(axiscolor) then axiscolor=0
        
       print, ' xycolor  = ', axiscolor

       if ifplot eq 1 then begin
          plot, [0, 1], [0, 1], /nodata, xrange = xrange, yrange=yrange, xstyle=1, ystyle=1, $
                xtitle = xtitle, ytitle = ytitle, position = position, color=axiscolor
          xyouts, position(2) - (position(2) - position(0))*0.03, $
                  position(1) + (position(3) - position(1))*0.03, $
                  title, align = 1.0 , /normal

          if not keyword_set(number) then begin 
          plots, xx, yy, psym = mysym(1), color= colors
          endif else begin
          xyouts, xx, yy, string(number, format='(I3)'), color=colors
          endelse
 
 
          result = sort(xx)
          oplot, xx(result), slope(0) * xx(result) + const, color=axiscolor, thick=3
          if ( intercpt ge 0) then sign='+'
          if ( intercpt lt 0) then sign=''
         linear_equation=' Y = '+strcompress(string(slope,format='(f10.3)')) +' X '+ sign + $
                               strcompress(string(const,format='(f10.3)'))
         print, 'linear equation :', linear_equation
         Rchar = ' R ='+string(correlate(xx,yy),format='(f6.2)') +$
                '!c N = ' + strcompress(string(ipnt, format='(i5)'), /remove_all)

         xyouts, pequation(0), pequation(1), linear_equation +'!c' + Rchar, $
                color = axiscolor, /normal
 ;        xyouts, pequation(0), pequation(1), Rchar, /normal, color = axiscolor
       endif
 END

