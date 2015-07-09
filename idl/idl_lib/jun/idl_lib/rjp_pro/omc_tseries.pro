
 pro tseries, imp, gc, gc2, gc3, pos=pos, yrange=yrange, xrange=xrange, $
     legend=legend

  if n_elements(yrange) eq 0 then yrange=[0.,10.]
  if n_elements(xrange) eq 0 then xrange=[1.,365.]

  Jday = imp[0].jday
  mon  = jday2month(Jday)
  jj   = where(mon ge 7 and mon le 8)

  tau0 = nymd2tau(20040101L)
  ddd  = [20040709L,20040711L,20040720L,20040721L,20040722L,20040725L]
  ddd  = (nymd2tau(ddd) - tau0[0])/24L + 1L

;======================================================================
;  Plotting begins here
;======================================================================

  @define_plot_size
  
  YTicks  = yrange[1]
  xrange  = [Jday[min(jj)], Jday[max(jj)]]


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

  ; geos-chem simulation of omc 
  fac    = 1.4
  Model  = (gc.ocpi+gc.ocpo)*fac + gc.soa1+gc.soa2+gc.soa3
  M_jday = gc[0].jday 

  array = composite(Model, /first)
  oplot, m_jday, array.mean, color=4, line=0, thick=dthick


  fac    = 1.4
  Model  = (gc2.ocpi+gc2.ocpo)*fac + gc2.soa1+gc2.soa2+gc2.soa3
  M_jday = gc2[0].jday 

  array = composite(Model, /first)
  oplot, m_jday, array.mean, color=2, line=0, thick=dthick


;  fac    = 1.4
;  Model  = (gc3.ocpi+gc3.ocpo)*fac + gc3.soa1+gc3.soa2+gc3.soa3
;  M_jday = gc3[0].jday 
;
;  array = composite(Model, /first)
;  oplot, m_jday, array.mean, color=3, line=0, thick=dthick

;  oplot, [jday[min(jj)],jday[min(jj)]], ocrange, color=1
;  oplot, [jday[max(jj)],jday[max(jj)]], ocrange, color=1

;  xyouts, 15, 5, 'R < '+CR, color=1, charsize=charsize, $
;   charthick=charthick



  if keyword_set(legend) then begin
    xxx = indgen(3)*5 + !x.crange[0]*1.1
    yyy = yrange[1]

    plots, xxx, yyy*0.9, color=1, psym=-2
    plots, xxx, yyy*0.8, color=4, line=0, thick=dthick
    plots, xxx, yyy*0.7, color=2, line=0, thick=dthick

    xyouts, xxx[2], yyy*0.9, 'IMPROVE', color=1, charsize=charsize, $
             charthick=charthick, alignment=0
    xyouts, xxx[2], yyy*0.8, 'GEOS-Chem', color=1, charsize=charsize, $
             charthick=charthick, alignment=0
    xyouts, xxx[2], yyy*0.7, 'GEOS-Chem!Cw/o fires in Alask &!C            Canada', color=1, charsize=charsize, $
             charthick=charthick, alignment=0


  end

 end

;======================================================================

  @load

  @define_plot_size
 
  if n_elements(gc3) eq 0 then  gc3 = rd_gc(/pbl)

  ; site selection with correlation coefficient between KNON and OMC
  Rarr = imp.r_knon_carb[2]  ; correlation coefficient
  Lon  = imp.Lon
  Lat  = imp.lat

  Rcri = 0.7 & CR = strtrim(string(Rcri, format='(F3.1)'),2)


 ; Plotting begins

  multipanel, row=2, col=2

  Pos = cposition(2,2,xoffset=[0.1,0.1],yoffset=[0.1,0.1], $
        xgap=0.1,ygap=0.15,order=1)

  if !D.name eq 'PS' then $
    open_device, file='omc_model.ps', /color, /ps, /landscape

    Jday = imp[0].jday
    mon  = jday2month(Jday)
    jj   = where(mon ge 6 and mon le 8)

    yrange = [0,7]
  ; correlation coefficient
    mindata = 0.
    maxdata = 5.

    id  = indgen(n_elements(imp))
    tseries, imp[id], gc[id], gc2[id], gc3[id], pos=pos[*,0], yrange=yrange, $
             /legend

    array = composite(imp[id].omc[jj])
    fld = array.mean
    mapplot, fld, imp[id], pos=pos[*,1], mindata=mindata, maxdata=maxdata, $
    missing=0., unit='[!4l!3g m!u-3!n]'


    mindata = 0.
    maxdata = 5.

    KvsOMC  = imp.r_knon_omc[0]
    ECvsOMC = imp.r_ec_omc[0]

    id  =  where(KvsOMC ge 100. and ECvsOMC ge 15.)
    tseries, imp[id], gc[id], gc2[id], gc3[id], pos=pos[*,2], yrange=yrange

    array = composite(imp[id].omc[jj])
    fld = array.mean
    mapplot, fld, imp[id], pos=pos[*,3], mindata=mindata, maxdata=maxdata, $
    missing=0., unit='[!4l!3g m!u-3!n]'
    
  if !D.name eq 'PS' then close_device


  End
