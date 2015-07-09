; to set legend
;

pro set_legend, minvalue, maxvalue, n_levels , colors, $
                xa, dx, ddx, dddx, $
                ya, dy, ddy, dddy, dirinx, extrachar

;set AOT legend
 barticks = minvalue + (findgen(N_levels+1))*(maxvalue-minvalue)/(n_levels)

 
 ; set n_levels
       for i = 0, n_levels+1 do begin
         x = [xa+i*dx, xa+(i+1)*dx+ddx, xa+(i+1)*dx+ddx, xa+i*dx, xa+i*dx]
         y = [ya+i*dy, ya+i*dy, ya+dy+i*dy+ddy, ya+dy+i*dy+ddy, ya+i*dy]
         polyfill, x, y, color=colors(i), /normal
         plots, x, y, color=16, /normal, thick=2
       endfor

      if ( dirinx lt 0 ) then barticks = reverse(barticks)
      align = 0.5
      extrachar1='' 
      if ( dx eq 0 ) then begin
        align = 1
	extrachar1 = extrachar 
      endif	

       for i = 0, n_levels, 4 do begin
        if ( (abs(barticks(i)) lt 1 and barticks(i) ne 0) or $
	     (fix(abs(barticks(i))) ne abs(barticks(i)) ) ) then begin
	xyouts,  xa+i*dx+ddx+dddx, ya+i*dy+ddy+dddy,'!6'+strcompress(string(barticks(i), $
                                     format='(f5.2)'),/remove_all)+extrachar1 , $
           color=16, /normal, charsize=1.5, charthick=3, align=align
           tmpx = xa+i*dx+ddx+dddx
	endif else begin

        xyouts,  xa+i*dx+ddx+dddx, ya+i*dy+ddy+dddy, $
	        '!6'+strcompress(string(fix(barticks(i)),$
                        format='(I4)'),/remove_all) + extrachar1, $
           color=16,/normal, charsize=1.5, charthick=3, align=align
           tmpx = xa+i*dx+ddx+dddx
	endelse
        endfor

        if ( dx ne 0 ) then begin 
        xyouts, tmpx+dx+dddx/2, ya+i*dy+ddy+dddy, extrachar, $
	         color=16,/normal, charsize=1.5, charthick=3, $
		 align=align
        endif		 

       ; xyouts, xa+dx/2., ya+i*dy+dy, '!6-', charsize=1, /normal, $
       ;                color=colors(0), charthick=2, align = 0.5



end
