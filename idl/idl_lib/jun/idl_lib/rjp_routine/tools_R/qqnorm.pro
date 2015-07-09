pro qqline, y

@define_plot_size

    da = quantile(y,[0.25, 0.75])
    x  = qnorm([0.25, 0.75])


    slope = (da[1]-da[0])/(x[1]-x[0])
    int   =  da[1]-slope*x[1]
    yval = !x.crange*slope[0] + int[0]
    oplot, !x.crange, yval, color=1, thick=thick

end

;

pro qqnorm, y, qline=qline

@define_plot_size

    if n_elements(y) eq 0 then message, 'y is empty or has only NAs'

    n = n_elements(y)
    x = qnorm(ppoints(n))
    p = gauss_pdf(x)*100.

    da = y[sort(y)]
    xlabel = [' ',' ',' ',' ',' ',' ',' ']
    plot, x, da, color=1, psym=4, charsize=charsize, charthick=charthick, $
    thick=symthick, XTicks=6, xtickname=xlabel

    pt = [2.2,15.9,50.0,84.1,97.7]
    j = locate(pt, p, cof=cof)
    j = ifelse(cof gt 0.5, j+1, j)
    cpt = string(pt,format='(g4.3)')
    dy = (!y.crange[1]-!y.crange[0])
    xyouts, x[j], !y.crange[0]-dy*0.05, cpt, color=1, alignment=0.5, $
      charsize=charsize, charthick=charthick

    pt = [10.,20.,80.,90.]
    j = locate(pt, p, cof=cof)
    j = ifelse(cof gt 0.5, j+1, j)
    cpt = string(pt,format='(g3.2)')
    xyouts, x[j], !y.crange[0]+dy*0.02, cpt, color=1, alignment=0.5, $
      charsize=charsize, charthick=charthick

    if keyword_set(qline) then qqline, da

end
