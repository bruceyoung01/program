;=======================================================================


 pro plot_histo, obs=obs, sim=sim, bkg=bkg, nat=nat, asi=asi, cumulative=cumulative, $
     deciview=deciview, position=position, label=label,  $
     plotbkg=plotbkg

  COMMON SHARE, SPEC, MAXD, MAXP

  @define_plot_size
  @calc_bext

  Nbins = 100.

  p    = [0.1,0.9]

  Xtitle = 'B!dext!n (Mm!u-1!n)'


  CASE SPEC OF
   'ALL4': begin
           obs_bext = chk_undefined(ammso4_bext+ammno3_bext+ec_bext+omc_bext)
           sim_bext = chk_undefined(rbext_ammso4+rbext_ammno3+rbext_ec+rbext_omc)
           bkg_bext = chk_undefined(bbext_ammso4+bbext_ammno3+bbext_ec+bbext_omc)
           end
   'ALL' : begin
           obs_bext = chk_undefined(ammso4_bext+ammno3_bext+ec_bext+omc_bext+soil_bext+cm_bext)
           sim_bext = chk_undefined(rbext_ammso4+rbext_ammno3+rbext_ec+rbext_omc+soil_bext+cm_bext)
           bkg_bext = chk_undefined(bbext_ammso4+bbext_ammno3+bbext_ec+bbext_omc+soil_bext+cm_bext)
           end
   'SO4' : begin
           obs_bext = chk_undefined(ammso4_bext)
           sim_bext = chk_undefined(rbext_ammso4)
           bkg_bext = chk_undefined(bbext_ammso4)
           end
   'OMC' : begin
           obs_bext = chk_undefined(omc_bext)
           sim_bext = chk_undefined(rbext_omc)
           bkg_bext = chk_undefined(bbext_omc)
           end
   'NO3' : begin
           obs_bext = chk_undefined(ammno3_bext)
           sim_bext = chk_undefined(rbext_ammno3)
           bkg_bext = chk_undefined(bbext_ammno3)
           end        
   'EC' : begin
           obs_bext = chk_undefined(ec_bext)
           sim_bext = chk_undefined(rbext_ec)
           bkg_bext = chk_undefined(bbext_ec)
           end        
  END

  obs_d = obs_bext
  sim_d = sim_bext
  bkg_d = bkg_bext

  if keyword_set(deciview) then begin
     obs_vis = 10. * Alog( (obs_bext+10.) / 10. )
     sim_vis = 10. * Alog( (sim_bext+10.) / 10. )
     bkg_vis = 10. * Alog( (bkg_bext+10.) / 10. )

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

 o = histo( obs_d, p, MinD=MinD, MaxD=MaxD, Nbins=Nbins, pos=Position, $
        color=1, line=line, Xtitle=Xtitle,            $
        Title=title, yrange=yrange, xrange=xrange, $
        xticks=5, cumulative=cumulative)

 ; Simulation (blue dotted)
 s = histo( sim_d, p, MinD=MinD, MaxD=MaxD, Nbins=Nbins,  /Oplot, $
        color=4, line=line, cumulative=cumulative, yrange=yrange )

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

;  comment = 'Western site (<95W),!C!C #1, Mean<9, STD<3.5'
;  comment = 'Estern site(>95W), !C!C #2, Mean>18, STD<5'
;  comment = 'Western site (<95W)'
  comment=''

  newpos = fltarr(4,4)
  newpos[*,0:1] = pos[*,0:1]
  newpos[*,2:3] = pos[*,3:4]

  map_dist, newobs(mapid), newsim(mapid), newbkg(mapid), newnat(mapid), newasi(mapid), pos=newpos

  position = pos[*,2]
  dx = 0.04
  dy = 0.0
  dxx= 0.13
  position = [position[0]+dx,position[1]-dy,position[2]+dxx,position[3]-dy]

  deciview=1
  plot_histo, obs=newobs(mapid), sim=newsim(mapid), bkg=newbkg(mapid), $
    deciview=deciview, position=position

  position = pos[*,5]
  dx = 0.04
  dy = 0.0
  position = [position[0]+dx,position[1]-dy,position[2]+dxx,position[3]-dy]
  deciview=1

  plot_histo, obs=newobs(mapid), sim=newsim(mapid), bkg=newbkg(mapid), $
    nat=newnat(mapid), asi=newasi(mapid), deciview=deciview,           $
    position=position, /cumulative, /label


  print, '==========Mean altitude============'
  print, mean(newobs[mapid].elev), ptz(mean(newsim[mapid].pres))

  xyouts, 0.66, 0.4, comment, color=1, alignment=0., /normal, $
    charsize=charsize, charthick=charthick

 if !D.name eq 'PS' then close_device

End
