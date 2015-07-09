
 pro tseries, imp, gc, gc2, gc3, pos=pos, yrange=yrange, xrange=xrange, $
     legend=legend, fire=fire

  if n_elements(yrange) eq 0 then yrange=[0.,10.]
  if n_elements(xrange) eq 0 then xrange=[1.,365.]

  Jday = imp[0].jday
  mon  = jday2month(Jday)
  jj   = where(mon ge 6 and mon le 8)

  tau0 = nymd2tau(20040101L)
  ddd  = [20040601L,20040711L,20040720L,20040721L,20040722L,20040725L]
  ddd  = (nymd2tau(ddd) - tau0[0])/24L + 1L

  ddd  = [160L,180L,200L,220L,240L]
  nymd = tau2yymmdd((ddd - 1L) * 24L + tau0[0])
  ttt  = strtrim(nymd.month,2) + '/' + strtrim(nymd.day,2)
  xlabel = ttt
;======================================================================
;  Plotting begins here
;======================================================================

  @define_plot_size
  
  YTicks  = yrange[1]
  xrange  = [Jday[min(jj)], Jday[max(jj)]]

  ; carbon mass only
  Data  = imp.carb
  array = composite(Data, /first)

  ytitle = 'TC (!4l!3gC m!u-3!n)'
  xtitle = 'Date'
  base   = array.mean
  plot, jday, array.mean, color=1, xstyle=1, xrange=xrange, xtickinterval=20, $
    yrange=yrange, psym=-2, symsize=symsize, thick=thin,              $
    ystyle=1, charthick=charthick,    $
    ytitle=ytitle, position=pos, charsize=charsize, $
    xtitle=xtitle, Yticks=YTicks, yminor=1, $
    XTickName=xlabel, xticks=n_elements(xlabel)-1
 
  print, xrange

  array = composite(fire, /first)
  print, mean(array.mean)

;  for nnn=0,n_elements(jj)-1 do print, base[jj[nnn]], array.mean[nnn]
;  oplot, jday[jj], (base[jj]-array.mean) > 0., color=1, psym=-6, thick=thin
;  oplot, jday[jj], array.mean, color=1, line=0, thick=dthick

  f_soa = [120.11/150., 120.11/160., 180.165/220.]
  ; geos-chem simulation of omc 
;  fac    = 1.4
;  Model  = (gc.ocpi+gc.ocpo)*fac + gc.soa1+gc.soa2+gc.soa3+gc.ecpi+gc.ecpo

  ; carbon mass only
  ; base model
  Model  = (gc.ocpi+gc.ocpo)+gc.soa1*f_soa[0]+gc.soa2*f_soa[1]+gc.soa3*f_soa[2]+(gc.ecpi+gc.ecpo)
  M_jday = gc[0].jday 

  array = composite(Model, /first)
  oplot, m_jday, array.mean, color=1, line=0, thick=dthick


;  fac    = 1.4
;  Model  = (gc2.ocpi+gc2.ocpo)*fac + gc2.soa1+gc2.soa2+gc2.soa3+gc2.ecpi+gc2.ecpo

  ; with no fires in canada and alaska
  Model  = (gc2.ocpi+gc2.ocpo)+gc2.soa1*f_soa[0]+gc2.soa2*f_soa[1]+gc2.soa3*f_soa[2]+(gc2.ecpi+gc2.ecpo)
  M_jday = gc2[0].jday 

  array = composite(Model, /first)
  oplot, m_jday, array.mean, color=2, line=0, thick=dthick


;  fac    = 1.4
;  Model  = (gc3.ocpi+gc3.ocpo)*fac + gc3.soa1+gc3.soa2+gc3.soa3+gc3.ecpi+gc3.ecpo

  Model  = (gc3.ocpi+gc3.ocpo)+gc3.soa1*f_soa[0]+gc3.soa2*f_soa[1]+gc3.soa3*f_soa[2]+(gc3.ecpi+gc3.ecpo)
  M_jday = gc3[0].jday 

  array = composite(Model, /first)
  oplot, m_jday, array.mean, color=3, line=0, thick=dthick

;  oplot, [jday[min(jj)],jday[min(jj)]], ocrange, color=1
;  oplot, [jday[max(jj)],jday[max(jj)]], ocrange, color=1

;  xyouts, 15, 5, 'R < '+CR, color=1, charsize=charsize, $
;   charthick=charthick



  if keyword_set(legend) then begin
    xxx = indgen(2)*5 + !x.crange[0]*1.02
    yyy = yrange[1]

    plots, xxx, yyy*0.9, color=1, psym=-2
    plots, xxx, yyy*0.8, color=1, line=0, thick=dthick
    plots, xxx, yyy*0.7, color=2, line=0, thick=dthick

    xyouts, xxx[1]+2, yyy*0.9, 'IMPROVE', color=1, charsize=charsize, $
             charthick=charthick, alignment=0
    xyouts, xxx[1]+2, yyy*0.8, 'GEOS-Chem', color=1, charsize=charsize, $
             charthick=charthick, alignment=0
    xyouts, xxx[1]+2, yyy*0.7, 'GEOS-Chem!Cw/o fires in Alaska &!C            Canada', color=1, charsize=charsize, $
             charthick=charthick, alignment=0


  end

 end

;=========================================================================

 pro process, fld, str, month=month, ID=ID, data=data

  Rcri = 0.7

  R    = fld.r  ; correlation
;  ID   = where( R ge Rcri )

  slope= fld.slope
  const= fld.const

  Jday = str[0].jday
  mon  = jday2month(Jday)

  jj   = -1.
  For N = 0, N_elements(month)-1 do jj = [jj, where( mon eq month[N] ) ]
  jj   = jj[1:*]

  Fire = Replicate(-999., n_elements(jj), n_elements(str))
;  Conc = Fire
;  ffac = Fire
  ID   = -1L

  For D = 0, N_elements(str)-1 do begin
      Info = str[D]
      CARB = Info.CARB[jj]  ; JJA
      CARB = chk_negative( CARB )
;      CONC[D] = mean(CARB, /NaN)
      KNON = Info.KNON[jj]
      KNON = chk_negative(KNON) 

      If R[D] ge Rcri then begin
; first method: subtracting intercep from OMC concentration
;         int = const[D] > 0.
;         Dat = CARB - int
;         Dat = chk_negative( Dat )

; second method: multiply the ratio by KNON
         ratio = slope[D]
         Dat   = KNON * ratio[0]  ; KNON * (OMC / K)
         Dat   = chk_negative( Dat )
     
         for ppp = 0, n_elements(dat)-1 do $
             dat[ppp] = dat[ppp] < carb[ppp]

         Fire[*,D] = Dat
;         ffac[D] = ratio
         ID  = [ID, D]
      End

  End

  ID   = ID[1:*]
  Data = Fire

  return

 end

;======================================================================

  @load
  @define_plot_size
 
  if n_elements(gc3) eq 0 then begin
    gc3 = rd_gc('./geos_test/out_trop_nowet/*_daily.txt')
    gc3   = sync( imp, gc3 )

;    gc3   = rd_gc('./geos_test/out_pbl/*_daily.txt')
;    gc3   = sync( imp, gc3 )
  end


  month = [7, 8]
  fld = comp_corr( imp, ['KNON','CARB'], month=month )
  process, fld, imp, month=month, ID=ID, data=fire

 ; Plotting begins

  multipanel, row=1, col=2

  Pos = cposition(2,1,xoffset=[0.1,0.1],yoffset=[0.3,0.3], $
        xgap=0.1,ygap=0.15,order=1)

  if !D.name eq 'PS' then $
    open_device, file='case_2004_03.ps', /color, /ps, /landscape

    Jday = imp[0].jday
    mon  = jday2month(Jday)
    jj   = where(mon ge 7 and mon le 8)

    mindata = 0.
    maxdata = 100.

   ; site selection with correlation coefficient between KNON and OMC
    Rarr = imp.r_knon_carb[2]  ; correlation coefficient
    rate = imp.r_knon_carb[0]  ; slope
    Lon  = imp.Lon
    Lat  = imp.lat

    Rcri = 0.7 & CR = strtrim(string(Rcri, format='(F3.1)'),2)
    ID   = where(Rarr ge Rcri and rate ge 70 and lat ge 40.)
    Fld  = imp[ID].r_knon_carb[0]  ; slopes

    mapplot, fld, imp[id], pos=pos[*,0], mindata=mindata, maxdata=maxdata, $
    missing=0., unit=' ', /cbar, cbformat='(F5.0)'


    yrange = [0.,6.]

;    KvsOMC  = imp.r_knon_omc[0]
;    ECvsOMC = imp.r_ec_omc[0]
;    id     =  where(KvsOMC ge 100. and ECvsOMC ge 15.)
;    id  =  where(Rarr ge Rcri and lat gt 42.)
;   id = [5,18,34,39,41,50,63,92,98,106,145,161,163]
;   id = [51,81,100,146,150,130]

    tseries, imp[id], gc[id], gc2[id], gc3[id], fire=fire[*,id], pos=pos[*,1], $
      yrange=yrange, /legend

;    fld = imp[id].r_knon_omc[0]   
;    mapplot, fld, imp[id], pos=pos[*,1], mindata=mindata, maxdata=maxdata, $
;    missing=0., unit='[!4l!3g m!u-3!n]', /cbar
;
    
  if !D.name eq 'PS' then close_device


  End
