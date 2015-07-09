
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
     plotbkg=plotbkg, yrange=yrange


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
     psym=1
  qqnorm, sim_d, color=4, /over, psym=4


 if Keyword_set(Label) then begin
  ;=======Label=========
   format='(f5.1)'
   dx=(xrange[1]-xrange[0])*0.05
   xrange=[-dx,dx]
   dy=(yrange[1]-yrange[0])*0.05
   yval  = yrange[1]+dy*6
   dy    = yrange[1]/15.

   plots, xrange, [yval,yval]-0.9*dy, color=1, psym=8, thick=dthick
   plots, xrange, [yval,yval]-1.9*dy, color=4, psym=8, thick=dthick

  label = 'B!dext!n for Sulfate, Nitrate, OMC, EC';, !8Soil, CM!3'
  label = ' '
  xyouts, xrange[1]*0.6, yval+dy, label,$
          color=1, charsize=charsize, charthick=charthick

  charsize=1.
  xyouts, xrange[1]*1.1, yval, '( Mean, STD, p10, p90 )', color=1, $
         charsize=charsize, charthick=charthick

  string='('+string(o.mean,format=format)+$
         ','+string(o.std, format=format)+$
         ','+string(o.p[0],format=format)+$
         ','+string(o.p[1],format=format)+$
         ' ) IMPROVE '
  xyouts, xrange[1]*1.1, yval-dy, string, color=1, charthick=charthick,$
          charsize=charsize

  string='('+string(s.mean,format=format)+$
         ','+string(s.std, format=format)+$
         ','+string(s.p[0],format=format)+$
         ','+string(s.p[1],format=format)+$
         ' ) Model '
  xyouts, xrange[1]*1.1, yval-2*dy, string, color=1, charthick=charthick,$
          charsize=charsize

  endif

 return

 end

;============================================================================

  @ctl

  !P.multi=[0,2,1,0,0]
  Pos = cposition(2,1,xoffset=[0.1,0.1],yoffset=[0.3,0.3], $
        xgap=0.1,ygap=0.15,order=0)

  figfile = 'qqplot_std.ps'

  if !D.name eq 'PS' then $
    open_device, file=figfile, /color, /ps, /landscape


  SPEC    = 'ALL4'

  Maxd   = 40.
  Maxp   = 4.
  maxval = 25.
;  minval = 1.


  ; east
  mapid = where(newobs.lon gt -95. and newobs.lat gt 35. and newobs.std gt 5. and newobs.mean gt 18.)

  plot_histo, obs=newobs(mapid), sim=newsim(mapid), bkg=newbkg(mapid), $
       nat=newnat(mapid), asi=newasi(mapid), /deciview, position=pos[*,1], yrange=[0.,40.]

  ; west
  mapid = where(newobs.lon lt -95. and newobs.lat gt 40. and newobs.std gt 3. and newobs.mean gt 8.)

  plot_histo, obs=newobs(mapid), sim=newsim(mapid), bkg=newbkg(mapid), $
       nat=newnat(mapid), asi=newasi(mapid), /deciview, position=pos[*,0], yrange=[0.,30.]

  print, '==========Mean altitude============'
  print, mean(newobs[mapid].elev), ptz(mean(newsim[mapid].pres))


  xyouts, 0.28, 0.65, '(a) WEST', /normal, color=1, $
  charsize=charsize, charthick=charthick, alignment=0.5

  xyouts, 0.73, 0.65, '(b) EAST', /normal, color=1, $
  charsize=charsize, charthick=charthick, alignment=0.5

;  xyouts, 0.40, 0.6, '(a)', /normal, color=1, $
;  charsize=charsize, charthick=charthick
;
;  xyouts, 0.85, 0.6, '(b)', /normal, color=1, $
;  charsize=charsize, charthick=charthick

 if !D.name eq 'PS' then close_device

End
