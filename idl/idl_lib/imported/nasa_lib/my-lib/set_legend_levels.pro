; to set legend
;

pro set_legend_levels, barticks,  n_levels , colors, $
                xa, dx, ddx, dddx, $
                ya, dy, ddy, dddy, FORMAT, dirinx, extrachar

;set AOT legend


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

       for i = 0, n_levels do begin
        xyouts,  xa+i*dx+ddx+dddx, ya+i*dy+ddy+dddy, barticks(i), $
           color=16, /normal, charsize=1.2, charthick=3, align=align
           tmpx = xa+i*dx+ddx+dddx
       endfor

        if ( dx ne 0 ) then begin
        xyouts, tmpx+dx+dddx/2, ya+i*dy+ddy+dddy, extrachar, $
                 color=16,/normal, charsize=1.2, charthick=3, $
                 align=align
        endif

end
