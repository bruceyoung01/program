pro qqline, y, color=color

@define_plot_size

    da = quantile(y,[0.25, 0.75])
    x  = qnorm([0.25, 0.75])


    slope = (da[1]-da[0])/(x[1]-x[0])
    int   =  da[1]-slope*x[1]
    yval = !x.crange*slope[0] + int[0]
    oplot, !x.crange, yval, color=color, thick=thick

end

;

pro qqnorm, y, qline=qline, position=position, $
    color=color, yrange=yrange, xrange=xrange, $
    over=over, psym=psym, Xlab=Xlab, Ylab=Ylab,$
    Nogxlab=Nogxlab, Nogylab=Nogylab

    if n_elements(psym)   eq 0 then psym = 4
    if n_elements(color)  eq 0 then color=1
    if n_elements(yrange) eq 0 then yrange = [min(y), max(y)]
    if n_elements(xrange) eq 0 then xrange = [-3.,3.]
    if n_elements(Nogxlab) eq 0 then Nogxlab = 0L

    @define_plot_size

    ; Define Usersymbol
    A = FINDGEN(33) * (!PI*2/32.)
    USERSYM, COS(A), SIN(A)

    if !d.name eq 'PS' then symsize = 0.7

    ; Axis thickness
    !x.thick = thick
    !y.thick = thick

    if n_elements(y) eq 0 then message, 'y is empty or has only NAs'

    n = n_elements(y)
    x = qnorm(ppoints(n))
    p = gauss_pdf(x)*100.

    da = y[sort(y)]
    color = color[sort(y)]

    icc = where(da gt yrange[1])
    if icc[0] ne -1 then da[icc] = 'NaN'

    xlabel = [' ',' ',' ',' ',' ',' ',' ']
    YTicks = Fix(Yrange[1]-Yrange[0])/10
    Ylabel = Indgen(YTicks+1)*10 + Yrange[0]
    Ylabel = strtrim(string(Ylabel,format='(I2)'),2)
    if Keyword_set(Nogylab) then Ylabel[*] = ' '

    if Keyword_set(Xlab) then xtitle='Cumulative probability (%)' else xtitle=''
    if Keyword_set(Ylab) then ytitle='dv'

    if keyword_set(over) then begin
;       oplot, x, da, color=color, psym=psym, symsize=symsize, thick=symthick
       plots, x, da, color=color, psym=psym, symsize=symsize, thick=symthick
    end else begin
;       plot, x, da, color=1, psym=psym, thick=symthick, symsize=symsize, $
       plot, xrange, yrange, color=1, psym=3, thick=symthick, symsize=symsize, $
       position=position, $
       xrange=xrange, xstyle=1, $
       yrange=yrange, ystyle=1, $
       charthick=charthick, charsize=charsize, $
       YTicks=YTicks, ytickname=Ylabel,             $
       XTicks=6,  xtickname=xlabel, ytitle=ytitle

       plots, x, da, color=color, psym=psym, thick=symthick, symsize=symsize

       xyouts, mean(!x.window), !y.window[0]-0.06, xtitle, color=1, $
       charsize=charsize, charthick=charthick, alignment=0.5, /normal

       pt = [2.2,15.9,50.0,84.1,97.7]
       pt = [2.,16.,50.,84.,98.]
       j = locate(pt, p, cof=cof)
       j = ifelse(cof gt 0.5, j+1, j)
      cpt = string(pt,format='(i2)')   
       dy = (!y.crange[1]-!y.crange[0])

    if keyword_set(1L-Nogxlab) then begin
       xyouts, x[j], !y.crange[0]-0.08*dy, cpt, color=1, alignment=0.5, $
         charsize=charsize, charthick=charthick
    end

;    pt = [10.,20.,80.,90.]
;       pt = [10.,90.]
       pt = [8.,92.]
       j = locate(pt, p, cof=cof)
       j = ifelse(cof gt 0.5, j+1, j)
       cpt = string(pt,format='(i2)')
;       xyouts, x[j], !y.crange[1]+dy*0.05, cpt, color=1, alignment=0.5, $
;         charsize=charsize, charthick=charthick

       oplot, [x[j[0]],x[j[0]]], [!y.crange[0],!y.crange[1]], color=1, thick=1.
       oplot, [x[j[1]],x[j[1]]], [!y.crange[0],!y.crange[1]], color=1, thick=1.
    end

    if keyword_set(qline) then qqline, da, color=1

end
