
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
     cumulative=cumulative, $
     deciview=deciview, position=position, label=label,  $
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

  if keyword_set(deciview) then begin
     obs_d = obs_vis
     sim_d = sim_vis
     bkg_d = bkg_vis     
  endif
   
  qqnorm, obs_d, position=position, yrange=yrange, xrange=[-3,3], $
     psym=1, nogylab=nogylab, ylab=ylab, xlab=xlab, nogxlab=nogxlab
  qqnorm, sim_d, color=2, yrange=yrange,  /over, psym=4

  print, obs.siteid
  print, mean(obs_d), stddev(obs_d)
  print, mean(sim_d), stddev(sim_d)

 return

 end

;============================================================================

  @ctl

  !P.multi=[0,3,4,0,0]
  Pos = cposition(3,4,xoffset=[0.1,0.05],yoffset=[0.1,0.1], $
        xgap=0.01,ygap=0.01,order=0)

  figfile = 'fig06_qqplot_std.ps'

  if !D.name eq 'PS' then begin
    open_device, file=figfile, /color, /ps, /portrait, $
      xoffset=0.5, yoffset=0.5, xsize=7.5, ysize=10.5

  end

  SPEC    = 'ALL'

  Maxd   = 40.
  Maxp   = 4.
  maxval = 25.
;  minval = 1.


  ; us bad
  mapid = [117, 132, 0, 54, 7, 25]

  ; us good
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
  For D = 0L, N_elements(mapid)-1L do begin
    thisDat = newobs(mapid[D])
    thispos = pos[*,D]

    nogylab = (D mod 3) < 1
    nogxlab =  1L - (D / 9L)
    plot_histo, obs=newobs(mapid[D]), sim=newsim(mapid[D]), bkg=newbkg(mapid[D]), $
         nat=newnat(mapid[D]), asi=newasi(mapid[D]), chi=newchi(mapid[D]),        $
         /deciview, position=pos[*,D], $
         yrange=[0.,40.], nogylab=nogylab, ylab=0L, nogxlab=nogxlab

   
;    title = strmid(thisDat.name,0,4)+', '+thisDat.state+'!C(' $
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

;  xyouts, 0.28, 0.65, '(a) WEST', /normal, color=1, $
;  charsize=charsize, charthick=charthick, alignment=0.5

;  xyouts, 0.73, 0.65, '(b) EAST', /normal, color=1, $
;  charsize=charsize, charthick=charthick, alignment=0.5

;  xyouts, 0.40, 0.6, '(a)', /normal, color=1, $
;  charsize=charsize, charthick=charthick
;
;  xyouts, 0.85, 0.6, '(b)', /normal, color=1, $
;  charsize=charsize, charthick=charthick

 if !D.name eq 'PS' then close_device

End
