
 pro tseries, imp, pos=pos, yrange=yrange, xrange=xrange, $
     legend=legend

  if n_elements(yrange) eq 0 then yrange=[0.,10.]
  if n_elements(xrange) eq 0 then xrange=[1.,365.]

  Jday = imp[0].jday
  mon  = jday2month(Jday)
  jj   = where(mon ge 6 and mon le 8)

  tau0 = nymd2tau(20040101L)
  ddd  = [20040709L,20040711L,20040720L,20040721L,20040722L,20040725L]
  ddd  = (nymd2tau(ddd) - tau0[0])/24L + 1L

;======================================================================
;  Plotting begins here
;======================================================================

  @define_plot_size
  
  YTicks  = yrange[1]
  xrange  = [Jday[min(jj)], Jday[max(jj)]]

  ; geos-chem simulation of omc 
;  fac    = 1.4
;  Model  = (gc.ocpi+gc.ocpo)*fac + gc.soa1+gc.soa2+gc.soa3
;  M_jday = gc[0].jday 

  ; improve observations
  Data  = imp.omc
  array = composite(Data, /first)

  ytitle = 'Concentration (!4l!3g m!u-3!n)'
  xtitle = 'Julian day of year 2004'

  plot, jday, array.mean, color=1, xstyle=1, xrange=xrange, $
    yrange=yrange, psym=-2, symsize=symsize, thick=thin,              $
    ystyle=1, charthick=charthick,    $
    ytitle=ytitle, position=pos, charsize=charsize, $
    xtitle=xtitle, Yticks=YTicks, yminor=1

;  plots, ddd, 5, color=4, psym=8

  Data  = imp.ec*10.
  array = composite(Data, /first)
  oplot, jday, array.mean, color=1, psym=8

;  array = composite(Model[*,q], /first)
;  oplot, m_jday, array.mean, color=4, line=2, thick=dthick

;  oplot, [jday[min(jj)],jday[min(jj)]], ocrange, color=1
;  oplot, [jday[max(jj)],jday[max(jj)]], ocrange, color=1

;  xyouts, 15, 5, 'R < '+CR, color=1, charsize=charsize, $
;   charthick=charthick

 ; potassium

  ylabel = strarr(YTicks+1)
  ylabel[*] = ' '

;  Axis, YAxis=1, Yrange=ocrange*0.01, /Save, Yticks=YTicks, $
;   color=2, charsize=charsize, charthick=charthick, $
;   ytickname=Ylabel, yminor=1

  ; nonsoil potassium
  data  = imp.knon*100.
  array = composite(data, /first)
  oplot, jday, array.mean, color=2, psym=4


  if keyword_set(legend) then begin
    xxx = indgen(3)*5 + 160.
    yyy = yrange[1]

    plots, xxx, yyy*0.9, color=1, psym=-2
    plots, xxx, yyy*0.8, color=1, psym=8
    plots, xxx, yyy*0.7, color=2, psym=4

  end

 end
