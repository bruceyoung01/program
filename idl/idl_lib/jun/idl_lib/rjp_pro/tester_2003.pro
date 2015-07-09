

 pro tseries, imp, pos=pos, yrange=yrange, xrange=xrange, $
     legend=legend, fld=fld

  if n_elements(yrange) eq 0 then yrange=[0.,10.]
  if n_elements(xrange) eq 0 then xrange=[1.,365.]

  Jday = imp[0].jday
  mon  = jday2month(Jday)
  jj   = where(mon ge 6 and mon le 9)

  tau0 = nymd2tau(20040101L)
  ddd  = [20040709L,20040711L,20040720L,20040721L,20040722L,20040725L]
  ddd  = (nymd2tau(ddd) - tau0[0])/24L + 1L

;======================================================================
;  Plotting begins here
;======================================================================

  @define_plot_size
  
  YTicks  = yrange[1] < 5
  xrange  = [Jday[min(jj)], Jday[max(jj)]]


  ; improve observations
  Data  = imp.carb
  array = composite(Data, /first)

  ytitle = 'Concentration (!4l!3g m!u-3!n)'
  xtitle = 'Julian day of year 2004'

  plot, jday, array.mean, color=1, xstyle=1, xrange=xrange, $
    yrange=yrange, psym=-2, symsize=symsize, thick=thin,              $
    ystyle=1, charthick=charthick,    $
    ytitle=ytitle, position=pos, charsize=charsize, $
    xtitle=xtitle, Yticks=YTicks, yminor=1

;  oplot, [jday[min(jj)],jday[max(jj)]], [fld, fld], color=1
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

;============================================

 end

  if n_elements( imp ) eq 0 then begin

  restore, filename='/users/ctm/rjp/Data/IMPROVE/Raw_data/daily_2003.sav'
  imp = knon( imp03 )

  month = [6,7,8]
  imp = corr( imp, ['KNON','OMC'], month=month )
  imp = corr( imp, ['KNON','EC'], month=month )
  imp = corr( imp, ['KNON','CARB'], month=month )
  imp = corr( imp, ['EC','OMC'], month=month )

  end

  @define_plot_size

  multipanel, row=2, col=2

  Pos = cposition(2,2,xoffset=[0.1,0.1],yoffset=[0.1,0.1], $
        xgap=0.1,ygap=0.15,order=1)

  if !D.name eq 'PS' then $
    open_device, file='tester_small.ps', /color, /ps, /landscape

    Jday = imp[0].jday
    mon  = jday2month(Jday)
    jj   = where(mon ge 6 and mon le 9)

    id = indgen(n_elements(imp))

    mindata = 0.
    maxdata = 1.

  Rarr = imp.r_knon_omc[2]  ; correlation coefficient
  Lon  = imp.Lon
  Lat  = imp.lat

   id  =  where(rarr ge 0.7 and Lat gt 40. and lon lt -100.)
   id  =  where(imp.state eq 'OR')
;   id = [5,18,34,39,41,50,63,92,98,106,145,161,163]
;   id = [51,81,100,146,150,130]

   for d = 0, n_elements(id)-1 do begin
;   for d = 0, 20 do begin
    q = id[D]
;    erase
    fld = imp[q].r_knon_omc[2]  ; R
    if (fld eq -999.) or (finite(fld) eq 0) then goto, jump
    mapplot, fld, imp[q], pos=pos[*,0], mindata=mindata, maxdata=maxdata, $
       limit = [40., -130., 60., -95.]

    ; omc vs k
    x = imp[q].knon[jj]   & y = imp[q].carb[jj] 
    scatter, X, Y, pos=pos[*,2], xrange=[0.,0.1], yrange=[0.,15.], $
    xtitle='K conc.', ytitle='CARB conc', al=al, r2=r2

    print, '======================'
    print, q,' ', al,' ', r2
    print, imp[q].siteid,'  ', imp[q].name, '  ', imp[q].state
    print, imp[q].elev, imp[q].lat, imp[q].lon
    fld = imp[q].r_knon_omc[1] ; intercept
    tseries, imp[q], pos=pos[*,3], yrange=[0.,15], fld=fld

    jump: halt
   end
  if !D.name eq 'PS' then close_device


;    plotongrid, fld, imp[id], mindata=mindata, maxdata=maxdata


end
