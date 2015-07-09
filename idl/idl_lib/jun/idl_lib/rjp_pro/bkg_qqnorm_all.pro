
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

 pro plot_histo, obs=obs, sim=sim, bkg=bkg, nat=nat, asi=asi, chi=chi, $
     cumulative=cumulative, deciview=deciview, position=position, label=label,  $
     plotbkg=plotbkg, yrange=yrange, nogylab=nogylab, ylab=ylab, xlab=xlab, $
     nogxlab=nogxlab


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
  nat_d = nat_bext
  asi_d = asi_bext
  chi_d = chi_bext
  int_d = int_bext
  trn_d = trn_bext

  if keyword_set(deciview) then begin
     obs_d = obs_vis
     sim_d = sim_vis
     bkg_d = bkg_vis
     nat_d = nat_vis
     asi_d = asi_vis
     int_d = int_vis
     trn_d = trn_vis
  endif
 
; qqnorm, sim_d, position=position, yrange=yrange, xrange=[-3,3], psym=1, $
;   nogylab=nogylab, ylab=ylab, xlab=xlab, nogxlab=nogxlab
; qqnorm, sim_d-(bkg_d-asi_d), color=4, /over, psym=4
; qqnorm, sim_d-(asi_d-nat_d), color=2, /over, psym=8

; color = jday2season(obs.jday)+1L

 qqnorm, bkg_d, position=position, yrange=yrange, xrange=[-3,3], psym=1, $
   nogylab=nogylab, ylab=ylab, xlab=xlab, nogxlab=nogxlab, color=1
; qqnorm, bkg_d-(asi_d-nat_d), color=2, /over, psym=8
; qqnorm, int_d, color=2, /over, psym=8, yrange=yrange
; qqnorm, trn_d, color=2, /over, psym=8
 qqnorm, nat_d, color=4, /over, psym=4, yrange=yrange

  print, obs.siteid
  print, mean(nat_d), stddev(nat_d)

  out = quantile(nat_d, 0.8)
  dat = nat_d[sort(nat_d)]
  p   = where(dat ge out[0])
  a80 = mean(dat[p])
  epa = mean(nat_d)+1.42*stddev(nat_d)
  print, epa, a80, a80/epa*100.
;  print, mean(sim_d), stddev(sim_d)

; standard deviation between nat vs bak
  print, stddev(nat_d), stddev(bkg_d), stddev(bkg_d)/stddev(nat_d)*100.

 return

 end

;============================================================================

  @ctl

  !P.multi=[0,3,4,0,0]
  Pos = cposition(3,4,xoffset=[0.1,0.05],yoffset=[0.1,0.1], $
        xgap=0.01,ygap=0.01,order=0)

  figfile = 'fig09_qqplot_bkg_all.ps'

  if !D.name eq 'PS' then $
    open_device, file=figfile, /color, /ps, /portrait, $
      xoffset=0.5, yoffset=0.5, xsize=7.5, ysize=10.5


  SPEC    = 'ALL'

  Maxd   = 20.

          ;w    m    e
;  mapid = [31, 116,  3,   $  ; north
;           26, 108,  77]     ; south

 mapid = [117,  116, 0,  $
          31, 132, 3,  $
          54,  108, 77, $
          26,  7,   25]
 sitename = ['Three Sisters,!C Oregon', 'Theodore Roosevelt,!C North Dakota', $
             'Acadia, Maine', 'Crater Lake, Oregon', 'Yellowstone, Wyoming', $
             'Arendtsville,!C Pennsylvania', 'Joshua Tree,!C California', $
             'Sikes, Louisiana', 'Okefenokee, Georgia', $
             'Chiricahua, Arizona', 'Big Bend, Texas', $
             'Chassahowitzka,!C Florida']

 dfac = [0.02,0.02,0.03,0.03,0.03,0.02,0.02,0.03,0.03,0.03,0.03,0.02]
  For D = 0, N_elements(mapid)-1 do begin
    thisDat = newobs(mapid[D])
    thispos = pos[*,D]

    nogylab = (D mod 3) < 1
    nogxlab =  1L - (D / 9L)

    plot_histo, obs=newobs(mapid[D]), sim=newsim(mapid[D]), bkg=newbkg1(mapid[D]), $
         nat=newnat1(mapid[D]), asi=newasi1(mapid[D]), chi=newchi1(mapid[D]),      $
         /deciview, position=pos[*,D], $
         yrange=[0.,Maxd], nogylab=nogylab, ylab=0L, nogxlab=nogxlab

;    title = strmid(thisDat.siteid,0,4)+', '+thisDat.state+'!C(' $
;          + strmid(strtrim(thisDat.lat,2),0,4) + 'N, '  $
;          + strmid(strtrim(thisDat.lon,2),1,4) + 'W)'
    
    title = sitename[D]+'!C(' $
          + strmid(strtrim(round(thisDat.lat),2),0,4) + 'N, '  $
          + strmid(strtrim(round(thisDat.lon),2),1,4) + 'W)'

    Mx = (thispos[0]+thispos[2])*0.5
    My = thispos[3]-dfac[D]
    xyouts, Mx, My, title, /normal, color=1, $
    charsize=charsize*0.85, charthick=charthick, alignment=0.5

;    print, '==========Mean altitude============'
;    print, mean(newobs[mapid[D]].elev), ptz(mean(newsim[mapid[D]].pres))
  End

   xyouts, 0.5, 0.06, 'Cumulative probability (%)', /normal, color=1, $
   charsize=tcharsize, charthick=charthick, alignment=0.5

   xyouts, 0.04, 0.5, 'Deciviews', /normal, color=1, $
   charsize=tcharsize, charthick=charthick, alignment=0.5, orientat=90.


 if !D.name eq 'PS' then close_device

End
