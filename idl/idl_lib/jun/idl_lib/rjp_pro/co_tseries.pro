
 pro tseries, imp, gc, gc2, spec, pos=pos, yrange=yrange, xrange=xrange, $
     legend=legend

  if n_elements(yrange) eq 0 then yrange=[0.,10.]
  if n_elements(xrange) eq 0 then xrange=[1.,365.]
  if n_elements(spec)   eq 0 then spec = 'CO'

  spec  = strupcase(spec)
  NAMES = tag_names(gc)
  N     = where(NAMES eq spec)
  If N[0] eq -1 then message, 'no species matched ',spec

  Jday = gc[0].jday
  mon  = jday2month(Jday)
  jj   = where(mon ge 6 and mon le 8)

  tau0 = nymd2tau(20040101L)
  ddd  = [20040709L,20040711L,20040720L,20040721L,20040722L,20040725L]
  ddd  = (nymd2tau(ddd) - tau0[0])/24L + 1L

;======================================================================
;  Plotting begins here
;======================================================================

  @define_plot_size
  
;  YTicks  = yrange[1]
  xrange  = [Jday[min(jj)], Jday[max(jj)]]

  ; geos-chem simulation of co
  Data  = gc.(N[0])
  array = composite(Data, /first)

  ytitle = 'Concentration (ppbv)'
  xtitle = 'Julian day of year 2004'

  plot, jday, array.mean, color=1, line=0,          $
    xstyle=1, xrange=xrange,                        $
    yrange=yrange, symsize=symsize, thick=dthick,   $
    ystyle=1, charthick=charthick,                  $
    ytitle=ytitle, position=pos, charsize=charsize, $
    xtitle=xtitle, Yticks=YTicks, yminor=1

  Model  = gc2.(N[0])
  array = composite(Model, /first)
  oplot, jday, array.mean, color=2, line=0, thick=dthick


  if keyword_set(legend) then begin
    xxx = indgen(3)*5 + !x.crange[0]*1.1
    yyy = yrange[1]

;    plots, xxx, yyy*0.9, color=1, psym=-2
    plots, xxx, yyy*0.8, color=1, line=0, thick=dthick
    plots, xxx, yyy*0.7, color=2, line=0, thick=dthick

;    xyouts, xxx[2], yyy*0.9, 'IMPROVE', color=1, charsize=charsize, $
;             charthick=charthick, alignment=0
    xyouts, xxx[2], yyy*0.8, 'GEOS-Chem', color=1, charsize=charsize, $
             charthick=charthick, alignment=0
    xyouts, xxx[2], yyy*0.7, 'GEOS-Chem!Cw/o fires in Alask &!C            Canada', color=1, charsize=charsize, $
             charthick=charthick, alignment=0


  end

 end

;======================================================================

  @load
  @define_plot_size


  ; site selection with correlation coefficient between KNON and OMC
  Rarr = imp.r_knon_omc[2]  ; correlation coefficient
  Lon  = imp.Lon
  Lat  = imp.lat

  Rcri = 0.7 & CR = strtrim(string(Rcri, format='(F3.1)'),2)


 ; Plotting begins

  multipanel, row=2, col=2

  Pos = cposition(2,2,xoffset=[0.1,0.1],yoffset=[0.1,0.1], $
        xgap=0.1,ygap=0.15,order=1)

  if !D.name eq 'PS' then $
    open_device, file='co_model.ps', /color, /ps, /landscape

    spec = 'co'

    case spec of 
     'ox' : yrange = [20,60]
     'co' : yrange = [100,200]
     'so2': yrange = [0,2]
     'nox': yrange = [0,2]
    end

    spec  = strupcase(spec)
    NAMES = tag_names(gc)
    N     = where(NAMES eq spec)
    If N[0] eq -1 then message, 'no species matched ',spec

    Jday = imp[0].jday
    mon  = jday2month(Jday)
    jj   = where(mon ge 7 and mon le 8)

  ; correlation coefficient
    mindata = 0
    maxdata = 40

    unit    = '[ppbv]'
    cbformat= '(I4)'
    id  = indgen(n_elements(imp))
    tseries, imp[id], gc[id], gc2[id], spec, pos=pos[*,0], yrange=yrange, /legend

    del   = (gc[id].(N[0])[jj]) - (gc2[id].(N[0])[jj])
    array = composite(del)
    fld   = array.mean
    mapplot, fld, gc[id], pos=pos[*,1], mindata=mindata, maxdata=maxdata, $
    missing=0., unit=unit, cbformat=cbformat

    KvsOMC  = imp.r_knon_omc[0]
    ECvsOMC = imp.r_ec_omc[0]

    id  =  where(KvsOMC ge 100. and ECvsOMC ge 15.)
    tseries, imp[id], gc[id], gc2[id], spec, pos=pos[*,2], yrange=yrange

    del   = (gc[id].(N[0])[jj]) - (gc2[id].(N[0])[jj])
    array = composite(del)
    fld   = array.mean
    mapplot, fld, gc[id], pos=pos[*,3], mindata=mindata, maxdata=maxdata, $
    missing=0., unit=unit, cbformat=cbformat
    
  if !D.name eq 'PS' then close_device


  End
