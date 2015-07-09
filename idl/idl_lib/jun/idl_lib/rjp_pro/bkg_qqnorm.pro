
 pro plot_histo, obs=obs, sim=sim, bkg=bkg, nat=nat, asi=asi, $
     cumulative=cumulative, $
     deciview=deciview, position=position, label=label,  $
     plotbkg=plotbkg, yrange=yrange


  COMMON SHARE, SPEC, MAXD, MAXP

  @define_plot_size
  @calc_bext
  if n_elements(yrange) eq 0 then yrange=[0.,40.]

  Nbins = 100.

  p    = [0.1,0.9]

  Xtitle = 'B!dext!n (Mm!u-1!n)'


  CASE SPEC OF
   'ALL4': begin
           obs_bext = chk_undefined(ammso4_bext+ammno3_bext+ec_bext+omc_bext)
           sim_bext = chk_undefined(rbext_ammso4+rbext_ammno3+rbext_ec+rbext_omc)
           bkg_bext = chk_undefined(bbext_ammso4+bbext_ammno3+bbext_ec+bbext_omc)
           nat_bext = chk_undefined(nbext_ammso4+nbext_ammno3+nbext_ec+nbext_omc)
           asi_bext = chk_undefined(abext_ammso4+abext_ammno3+abext_ec+abext_omc)
           end
   'ALL' : begin
           obs_bext = chk_undefined(ammso4_bext+ammno3_bext+ec_bext+omc_bext+soil_bext+cm_bext)
           sim_bext = chk_undefined(rbext_ammso4+rbext_ammno3+rbext_ec+rbext_omc+soil_bext+cm_bext)
           bkg_bext = chk_undefined(bbext_ammso4+bbext_ammno3+bbext_ec+bbext_omc+soil_bext+cm_bext)
           nat_bext = chk_undefined(nbext_ammso4+nbext_ammno3+nbext_ec+nbext_omc+soil_bext+cm_bext)
           asi_bext = chk_undefined(abext_ammso4+abext_ammno3+abext_ec+abext_omc+soil_bext+cm_bext)
           end
   'SNA': begin
           obs_bext = chk_undefined(ammso4_bext+ammno3_bext)
           sim_bext = chk_undefined(rbext_ammso4+rbext_ammno3)
           bkg_bext = chk_undefined(bbext_ammso4+bbext_ammno3)
           nat_bext = chk_undefined(nbext_ammso4+nbext_ammno3)
           asi_bext = chk_undefined(abext_ammso4+abext_ammno3)
           end
   'SO4' : begin
           obs_bext = chk_undefined(ammso4_bext)
           sim_bext = chk_undefined(rbext_ammso4)
           bkg_bext = chk_undefined(bbext_ammso4)
           nat_bext = chk_undefined(nbext_ammso4)
           asi_bext = chk_undefined(abext_ammso4)
           end
   'OMC' : begin
           obs_bext = chk_undefined(omc_bext)
           sim_bext = chk_undefined(rbext_omc)
           bkg_bext = chk_undefined(bbext_omc)
           nat_bext = chk_undefined(nbext_omc)
           asi_bext = chk_undefined(abext_omc)
           end
   'NO3' : begin
           obs_bext = chk_undefined(ammno3_bext)
           sim_bext = chk_undefined(rbext_ammno3)
           bkg_bext = chk_undefined(bbext_ammno3)
           asi_bext = chk_undefined(abext_omc)
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
  nat_d = nat_bext 
  asi_d = asi_bext

  if keyword_set(deciview) then begin
     obs_vis = 10. * Alog( (obs_bext+10.) / 10. )
     sim_vis = 10. * Alog( (sim_bext+10.) / 10. )
     bkg_vis = 10. * Alog( (bkg_bext+10.) / 10. )
     nat_vis = 10. * Alog( (nat_bext+10.) / 10. )
     asi_vis = 10. * Alog( (asi_bext+10.) / 10. )

     obs_d = obs_vis
     sim_d = sim_vis
     bkg_d = bkg_vis     
     nat_d = nat_vis
     asi_d = asi_vis
  endif
   
   
  qqnorm, bkg_d, position=position, /qline, yrange=yrange, xrange=[-3,3], $
     psym=1
  qqnorm, nat_d, color=4, /over, /qline, psym=4


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

  COMMON SHARE, SPEC, MAXD, MAXP

  if n_elements(obs) eq 0 then begin
    obs    = get_improve_dayly()
    sim    = get_model_day_improve(res=1)
    bkg    = get_model_day_improve(res=11)
    nat    = get_model_day_improve(res=111)
    asi    = get_model_day_improve(res=1111)
    newsim = syncro( sim, obs )
    newbkg = syncro( bkg, obs )
    newnat = syncro( nat, obs )
    newasi = syncro( asi, obs )
    newobs = group( obs , ID=ID )
  endif

  @define_plot_size

  !P.multi=[0,2,2,0,0]
  Pos = cposition(2,2,xoffset=[0.1,0.1],yoffset=[0.15,0.15], $
        xgap=0.08,ygap=0.15,order=0)

  figfile = 'qqplot_bkg.ps'

  if !D.name eq 'PS' then $
    open_device, file=figfile, /color, /ps, /landscape


  SPEC    = 'ALL4'
;  SPEC    = 'SNA'

  Maxd   = 40.
  Maxp   = 4.
  maxval = 25.
  yrange =[0.,20.]
;  minval = 1.

  e_bad1 = [13,25,99,35,77,93,114] ; south east coastal
  e_bad2 = [0,86,72,78]
  bad    = e_bad1

;  m = search_index(bad, mapid, complement=n)
;  mapid = mapid(n)
;  mapid = [0,4]

  ; east
  mapid = where(newobs.lon gt -95. and newobs.std gt 5. and newobs.mean gt 18.)

  plot_histo, obs=newobs(mapid), sim=newsim(mapid), bkg=newbkg(mapid),  $
    nat=newnat(mapid), asi=newasi(mapid), /deciview, position=pos[*,1], $
    yrange=yrange

  ; west
  mapid = where(newobs.lon lt -95. and newobs.lat gt 40. and newobs.std gt 3.)

  plot_histo, obs=newobs(mapid), sim=newsim(mapid), bkg=newbkg(mapid),  $
    nat=newnat(mapid), asi=newasi(mapid), /deciview, position=pos[*,0], $
    yrange=yrange

  print, '==========Mean altitude============'
  print, mean(newobs[mapid].elev), ptz(mean(newsim[mapid].pres))


  xyouts, 0.28, 0.8, '(a) WEST', /normal, color=1, $
  charsize=charsize, charthick=charthick, alignment=0.5

  xyouts, 0.73, 0.8, '(b) EAST', /normal, color=1, $
  charsize=charsize, charthick=charthick, alignment=0.5

;  xyouts, 0.40, 0.6, '(a)', /normal, color=1, $
;  charsize=charsize, charthick=charthick
;
;  xyouts, 0.85, 0.6, '(b)', /normal, color=1, $
;  charsize=charsize, charthick=charthick

 if !D.name eq 'PS' then close_device

End
