
 pro scatter, X, Y, pos=pos, xrange=xrange, yrange=yrange, $
     xtitle=xtitle, ytitle=ytitle, title=title, al=al, r2=r2

    if n_elements(xrange) eq 0 then xrange=[0.,max(x)]
    if n_elements(yrange) eq 0 then yrange=[0.,max(y)]

    @define_plot_size

    ; remove missing data
    p = where(x lt 0. or y lt 0., complement=c)

    if c[0] eq -1 then return

    X = X[c]
    Y = Y[c]        

    rma   = lsqfitgm(X, Y)
    slope = rma[0]
    const = rma[1]
    R2    = rma[2]^2

    plot, x, y, psym=1, color=1, pos=pos, xrange=xrange, $
     yrange=yrange, xtitle=xtitle, ytitle=ytitle, $
     charsize=charsize, title=title, charthick=charthick

    XXX = Findgen(101)*Max(X)/100.
    oplot, XXX, const+slope*XXX, color=1, line=0, thick=dthick

;    oplot, xrange, yrange, color=1, thick=thin

    if R2 gt 0.01 then R2 = strmid(strtrim(R2,2),0,4) else $
       R2 = '0.0'
    al = strmid(strtrim(slope,2),0,4)
    ab = strmid(strtrim(abs(const),2),0,4)
    if const lt 0.0 then XX = 'x-' else XX = 'x+'

    xwid = xrange[1]-xrange[0]
    ywid = yrange[1]-yrange[0]

    Xyouts, xwid*0.1, yrange[1]-ywid*0.2, 'R!u2!n = '+R2,    color=1,  $
      alignment=0.,charthick=charthick,charsize=charsize
    Xyouts, xwid*0.1, yrange[1]-ywid*0.1, 'y = '+al+XX+ab, color=1,  $
      alignment=0.,charthick=charthick,charsize=charsize


 end
