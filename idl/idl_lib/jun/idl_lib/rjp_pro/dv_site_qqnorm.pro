;=========================================================================

pro plot_site, obs, pos=pos

  @define_plot_size
  ;=========================
  ; Distribution of mean
  ;========================
  limit = [25., -130., 50., -60.]
  LatRange = [ Limit[0], Limit[2] ]
  LonRange = [ Limit[1], Limit[3] ]


  ;---- observation----
  map_set, 0, 0, color=1, /contine, limit=limit, /usa,$
    position=pos[*,0]

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
          Align=1.0, Color=1, /Normal, charsize=csfac, charthick=charthick

  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick


  plots, obs.lon, obs.Lat, color=1, psym=8, symsize=symsize

 end

;=====================================================================

 pro plot_histo, obs=obs, sim=sim, bkg=bkg, nat=nat, asi=asi, cumulative=cumulative, $
     deciview=deciview, position=position, label=label,  $
     plotbkg=plotbkg

  COMMON SHARE, SPEC, MAXD, MAXP

  @define_plot_size
  @calc_bext

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

  if keyword_set(cumulative) then begin

;     MaxD = Max(obs_d) < 35.
;     MaxD = MaxD
     MinD = Min(obs_d) < Min(sim_d)
     yrange = [MinD, MaxD]
     Xtitle = '(dv)'
     xrange = [0., 100.]

  end else begin
;     MaxD = Max(obs_d) < 35.
;     MaxD=35.
     MinD = Min(obs_d) < Min(sim_d)
;     yrange = [MinD,MaxD]
     Xtitle = ' '
     yrange = [0., MaxP]
     xrange = [0., MaxD]
     line  = 0
  end

;  out = nan_chk(obs_bext, sim_bext)
;  check, out

;xrange = [-4., 4.]

; title = 'B!dext!n ('+SPEC+') at IMPROVE in the West (<95!uo!nW)'
 title = 'Frequency distribution of B!dext!n at IMPROVE sites'
 title = ' '

 if keyword_set(cumulative) then begin

  qqnorm, obs_d, position=position, yrange=[0.,40.], xrange=[-3,3], psym=1
  qqnorm, sim_d, color=4, /over, psym=4

 end else begin

 o = histo( obs_d, p, MinD=MinD, MaxD=MaxD, Nbins=Nbins, pos=Position, $
        color=1, line=line, Xtitle=Xtitle,            $
        Title=title, yrange=yrange, xrange=xrange, $
        xticks=5, cumulative=cumulative)

 ; Simulation (blue dotted)
 s = histo( sim_d, p, MinD=MinD, MaxD=MaxD, Nbins=Nbins,  /Oplot, $
        color=4, line=line, cumulative=cumulative, yrange=yrange )

 end

 ; Simulation (red dotted)
 if Keyword_set(plotbkg) then $
    d = histo( bkg_d, p, MinD=MinD, MaxD=MaxD, Nbins=Nbins,  /Oplot, $
        color=2, line=line, cumulative=cumulative, yrange=yrange )

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


    if Keyword_set(plotbkg) then begin
        plots, xrange, [yval,yval]-2.9*dy, color=2, line=1, thick=dthick
        string='('+string(d.mean,format=format)+$
               ','+string(d.std, format=format)+$
               ','+string(d.p[0],format=format)+$
               ','+string(d.p[1],format=format)+$
               ' ) Model (bkgn) '
        xyouts, xrange[1]*1.1, yval-3*dy, string, color=1, charthick=charthick,$
                charsize=charsize
     endif
  endif

 return

 end

;============================================================================
  @ctl

  NAME    = ['ALL4','SO4', 'NO3', 'OMC', 'EC']
  NAME    = ['ALL4','+SO4','+NO3','+IOA','+OMC']
  SPEC    = 'ALL4'
  figfile = 'josh1.ps'

  Maxd   = 25.
  Maxp   = 5.
  maxval = 25.

  ; W1 (clean but high variability)

;=====================
; eastern sites
;=====================
  ; good
   mapid = [  1,  3, 11, 22, 28, 43, 46, 51, 53, 59, $
             60, 63, 64, 67, 68, 72, 77, 86, 93,103, $
            108,109,121,124]
  ; too high
  mapid = [10,15] ; due to nitrate
  mapid = [88] ; too much sulfate in Ohio
  mapid = [0,17,18,20,41,84,89,123]
  ; too low
;  mapid = [13,21,25,35,34,99,105,106,114]

;=====================
; western sites
;=====================
   ; good sites
   goodid = [  4,  6, 14, 16, 19, 23, 24, 26, 31, 36, $
              37, 42, 45, 47, 48, 52, 56, 57, 62, 65, $
              74, 75, 79, 85,102,116,119,120,125,127, $
             128,129,130]
   okid   = [  5,  8, 27, 39, 40, 49, 58, 66, 69, 71, $
              80, 81, 83, 90, 92, 94,100,113,118]

   ; too low due to nitrate in CA
   mapid = [2,33,54,55,91,97,104] ; 54 is selected
   ; too high due to soa 
   mapid = [73, 76, 117]  ; 117 is selected

  ; too low due to OMC
   mapid = [12,50,82,115,132,133]  ; 12 is selected

  ; too low due to 
;   mapid = [30,32,87,110,112]
;   mapid = [9,61,95,98,101,134]

   ; too low (mexico so2)
;   mapid = [7,44,131]  ; 7 is selected [BIBE]
   ; good 
;   mapid = [6,26,37]   ; 26 is selected [CHIR]


;   mapid = 7
    mapid = where(newobs.state eq 'NC')

  !P.multi=[0,3,2,0,0]
  Pos = cposition(3,2,xoffset=[0.05,0.05],yoffset=[0.15,0.15], $
        xgap=0.05,ygap=0.1,order=0)

  if !D.name eq 'PS' then $
    open_device, file=figfile, /color, /ps, /landscape

  erase

  For D = 0, N_elements(mapid)-1 do begin
     thisDat = newobs(mapid[D])
     position = pos[*,0]
     plot_site, newobs(mapid[D]), pos=position

     xp = (position[0]+position[2])*0.5
     yp = position[3]+0.04

     title = strmid(thisDat.siteid,0,4)+', '+thisDat.state+'!C(' $
          + strmid(strtrim(thisDat.lat,2),0,4) + 'N, '  $
          + strmid(strtrim(thisDat.lon,2),1,4) + 'W)'

     xyouts, xp, yp, title, color=1, alignment=0.5, /normal

  For N = 0, N_elements(Name)-1 do begin
     SPEC = NAME[N]
     deciview=1
     position = pos[*,N+1]
     plot_histo, obs=newobs(mapid[D]), sim=newsim(mapid[D]), bkg=newbkg(mapid[D]), $
       nat=newnat(mapid[D]), asi=newasi(mapid[D]), deciview=deciview, position=position, $
       /cumulative

     xp = (position[0]+position[2])*0.5
     yp = position[3]+0.02
     xyouts, xp, yp, spec, color=1, alignment=0.5, /normal
  END

  print, '==========Mean altitude============'
  print, mapid[D], ' ['+newobs[mapid[D]].siteid+', '+newobs[mapid[D]].state+']', newobs[mapid[D]].elev
  print, mean(newobs[mapid[D]].elev), ptz(mean(newsim[mapid[D]].pres))

  halt

  end

 if !D.name eq 'PS' then close_device

End
