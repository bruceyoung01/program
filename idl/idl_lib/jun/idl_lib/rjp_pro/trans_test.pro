
;=============================================================

 function sync_stat, str, obsfld, simfld

  Lat = 0.
  Lon = 0.
  v_avg = 0.
  v_std = 0.

  m_avg = 0.
  m_std = 0.

  For D = 0, N_elements(str.siteid)-1 do begin
;     data = chk_undefined(reform(fld[*,D]))

      data = reform(obsfld[*,D])

      id   = where(data gt 0.)
      mon  = tau2month(str[D].jday[id])

;      nuq  = uniq(mon)
;      if n_elements(nuq) lt 12 then goto, jump

;      For n = 1L, 12L do begin
;         nm = where(mon eq n)
;         if n_elements(nm) lt 5 then goto, jump
;      end

      data = chk_undefined(reform(obsfld[*,D]))
      conc = chk_undefined(reform(simfld[*,D]))

      if data[0]          ne -1   and $
         n_elements(data) gt 80.  and $
         str[D].lat       gt 20.  then begin
         v_avg  = [v_avg, Mean(Data)  ]  ; annual mean
         v_std  = [v_std, STDDEV(Data)]  ; daily std

         m_avg  = [m_avg, Mean(conc)  ]  ; annual mean model
         m_std  = [m_std, stddev(conc)]  ; std model

         lat    = [lat,   str[d].lat]
         lon    = [lon,   str[d].lon]   
      end

     jump:
  End

  obs_avg = v_avg[1:*]
  obs_std = v_std[1:*]
  mod_avg = m_avg[1:*]
  mod_std = m_std[1:*]

  obs_lat = lat[1:*]
  obs_lon = lon[1:*]

  return, {obs_avg:obs_avg, obs_std:obs_std, $
           sim_avg:mod_avg, sim_std:mod_std, $
           lat:obs_lat, lon:obs_lon }

 end

;=======================================================================

 pro plot_histo, obs=obs, sim=sim, bkg=bkg, nat=nat, asi=asi, cumulative=cumulative, $
     deciview=deciview, position=position, label=label,  $
     plotbkg=plotbkg, yrange=yrange, nogylab=nogylab, ylab=ylab, xlab=xlab


  COMMON SHARE, SPEC, MAXD, MAXP

  @define_plot_size
  @calc_bext

  if n_elements(yrange) eq 0 then yrange=[0.,40.]

  Nbins = 100.

  p    = [0.1,0.9]

  Xtitle = 'B!dext!n (Mm!u-1!n)'


  obs_d = obs_bext
  sim_d = sim_bext
  bkg_d = bkg_bext

  if keyword_set(deciview) then begin
     obs_d = obs_vis
     sim_d = sim_vis
     bkg_d = bkg_vis     
  endif
   
  qqnorm, obs_d, position=position, yrange=yrange, xrange=[-3,3], $
     psym=1, nogylab=nogylab, ylab=ylab, xlab=xlab
  qqnorm, sim_d, color=4, yrange=yrange,  /over, psym=4

 return

 end

;============================================================================

  COMMON SHARE, SPEC, MAXD, MAXP

  if n_elements(obs) eq 0 then begin

    obs    = get_improve_dayly()
    sim    = get_model_day_improve(res=10)
    bkg    = get_model_day_improve(res=110)
    nat    = get_model_day_improve(res=111)
    asi    = get_model_day_improve(res=1111)
    newsim = syncro( sim, obs )
    newbkg = syncro( bkg, obs )
    newnat = syncro( nat, obs )
    newasi = syncro( asi, obs )
    newobs = group( obs , ID=ID )

    ; reconstruct omc conentrations by replacing soa conc. with baseline soa
    omc    = sim.soa + bkg.poa
    bkg1   = bkg
    bkg1.omc = omc

    omc    = sim.soa + nat.poa
    nat1   = nat
    nat1.omc = omc

    ; reconstruct omc conentrations by replacing soa conc. with baseline soa
    omcbkg = newsim.soa + newbkg.poa
    newbkg1= newbkg
    newbkg1.omc = omcbkg

    omcnat = newsim.soa + newnat.poa
    newnat1= newnat
    newnat1.omc = omcnat

  endif


  !P.multi=[0,3,2,0,0]
  Pos = cposition(3,2,xoffset=[0.1,0.1],yoffset=[0.1,0.1], $
        xgap=0.03,ygap=0.1,order=0)

  figfile = 'trans_test.ps'

  if !D.name eq 'PS' then $
    open_device, file=figfile, /color, /ps, /landscape


  SPEC    = 'ALL4'

  Maxd   = 40.
  Maxp   = 4.
  maxval = 25.
;  minval = 1.


  ; us bad
  mapid = [117, 132, 0, 54, 7, 25]

  ; us good
;  mapid = [31, 116,  3,   $  ; north
;           26, 108,  77]     ; south


  For D = 0, N_elements(mapid)-1 do begin
    thisDat = newobs(mapid[D])
    thispos = pos[*,D]

    if (D eq 0) or (D eq 3) then nogylab=0 else nogylab=1
    plot_histo, obs=newobs(mapid[D]), sim=newsim(mapid[D]), bkg=newbkg(mapid[D]), $
         nat=newnat(mapid[D]), asi=newasi(mapid[D]), /deciview, position=pos[*,D], $
         yrange=[0.,40.], nogylab=nogylab, ylab=(1-nogylab)

    title = strmid(thisDat.siteid,0,4)+', '+thisDat.state+'!C(' $
          + strmid(strtrim(thisDat.lat,2),0,4) + 'N, '  $
          + strmid(strtrim(thisDat.lon,2),1,4) + 'W)'
    
    Mx = (thispos[0]+thispos[2])*0.5
    My = thispos[3]+0.04
    xyouts, Mx, My, title, /normal, color=1, $
    charsize=charsize, charthick=charthick, alignment=0.5

    print, '==========Mean altitude============'
    print, mean(newobs[mapid[D]].elev), ptz(mean(newsim[mapid[D]].pres))
  End

   xyouts, 0.5, 0.04, 'Cumulative probability (%)', /normal, color=1, $
   charsize=tcharsize, charthick=charthick, alignment=0.5


 if !D.name eq 'PS' then close_device

End
