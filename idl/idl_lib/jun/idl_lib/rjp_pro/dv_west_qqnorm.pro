

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

  qqnorm, obs_d, position=position, /qline, yrange=[0.,30.], xrange=[-3,3]
  qqnorm, sim_d, color=4, /qline, /over

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

  SPEC    = 'ALL4'
  figfile = 'dv_west_qqnorm.ps'

  Maxd   = 25.
  Maxp   = 5.
  maxval = 25.

  ; W1 (clean but high variability)
  mapid = where(newobs.lon lt -95. and newobs.lat gt 40. and newobs.std gt 3. and newobs.mean gt 8.)
  mapid = [12,30,32,80,94,110,112]
  mapid = [7,9,44,95,98,107,115,118,131,134]
  mapid = 127

  !P.multi=[0,3,2,0,0]
  Pos = cposition(3,2,xoffset=[0.05,0.15],yoffset=[0.15,0.15], $
        xgap=0.01,ygap=0.15,order=0)

  if !D.name eq 'PS' then $
    open_device, file=figfile, /color, /ps, /landscape

  erase

  newpos = fltarr(4,4)
  newpos[*,0:1] = pos[*,0:1]
  newpos[*,2:3] = pos[*,3:4]


  For D = 0, N_elements(mapid)-1 do begin

  map_dist, newobs(mapid[D]), newsim(mapid[D]), newbkg(mapid[D]), newnat(mapid[D]), newasi(mapid[D]), pos=newpos

  deciview=1

  position = pos[*,5]
  dx = 0.04
  dy = -0.25
  dxx= 0.13
  position = [position[0]+dx,position[1]-dy,position[2]+dxx,position[3]-dy]

  deciview=1
  position = [0.63, 0.25, 0.98, 0.75]

  plot_histo, obs=newobs(mapid[D]), sim=newsim(mapid[D]), bkg=newbkg(mapid[D]), $
    nat=newnat(mapid[D]), asi=newasi(mapid[D]), deciview=deciview, position=position, $
    /cumulative


  print, '==========Mean altitude============'
  print, mapid[D], ' ['+newobs[mapid[D]].siteid+', '+newobs[mapid[D]].state+']', newobs[mapid[D]].elev
  print, mean(newobs[mapid[D]].elev), ptz(mean(newsim[mapid[D]].pres))

  halt

  end

 if !D.name eq 'PS' then close_device

End
