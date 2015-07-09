 pro rh_scatter_plot, sim=sim, id=id, pos=pos

 if n_elements(id) eq 0 then id = indgen(n_elements(sim[0].rh))

 @define_plot_size


  smp_rh = findgen(110)
  smp_rhw = smp_rh
  smp_rhe = smp_rh

  ; Light extinction from GEOS-CHEM simulation in the West
  sim_rh      = makevector(sim.rh[id])
  sim_frh_iso = makevector(sim.frh_iso[id])
  sim_frh_iso_nonit = makevector(sim.frh_iso_nonit[id])
  sim_frh_imp = makevector(sim.frh_imp[id])
  s_rh        = sim_rh
  sim_frh_imp = improve_frh(s_rh)

;  W_sim_frh_imp = frh_improve(W_s_rh)  
  ammno3      = makevector(sim.nit[id])*1.29
  amm         = (makevector(sim.nh4[id])/18.) - (makevector(sim.nit[id])/62.)
  amm         = make_zero(amm, val=0.)
  so4         = makevector(sim.so4[id])/96.
  don         = amm/(so4*2.)

  C      = Myct_defaults()
  Bottom = C.Bottom
; Bottom = 1.
  Ncolor = 255L-Bottom
  Ndiv   = 6
  Format = '(F4.1)'
  Min    = 0.
  Max    = 1.

  Colors = bytscl( don, Min=Min, Max=Max, $
      	       Top = Ncolor) + Bottom


  sim_frh_iso_mean = fltarr(N_elements(smp_rh)-1)
  mean_sim_frh     = fltarr(N_elements(smp_rh)-1)

  For D = 0, n_elements(smp_rh)-2 do begin

      mean_sim_frh[D] = (smp_rh[D]+smp_rh[D+1])*0.5

      p = where(sim_rh ge smp_rh[D] and sim_rh lt smp_rh[D+1])
      if p[0] ne -1 then $
      sim_frh_iso_mean[D] = mean(sim_frh_iso[P]) else $
      sim_frh_iso_mean[D] = 0.
  End

  plot, [0.,120.], [0.,15.], color=1, position=pos, /nodata, $
   xtitle='RH (%)', Ytitle='f(RH)', charsize=charsize, charthick=charthick
  plots, sim_rh, sim_frh_iso, color=colors, psym=1, symsize=symsize*0.5, $
        thick=symthick
  oplot, mean_sim_frh, sim_frh_iso_mean, color=1, psym=1, symsize=1, $
        thick=dthick
  oplot, sim_rh, sim_frh_imp, color=4, psym=3, symsize=symsize

  ; colorbar
  CBPosition = [0.3,0.51,0.7,0.53]
  ColorBar, Max=max,     Min=min,    NColors=Ncolor,     $
    	      Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition, $
    		Unit=Unit,       Divisions=Ndiv, Log=Log,             $
	      Format=Format,   Charsize=2,       $
    	      C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=1.5


  return

  plot, [0.,15.], [0.,15.], color=1, position=pos[*,0], $
   xtitle='f(RH, IMPROVE)', Ytitle='f(RH, GEOS-CHEM)', thick=thick
  plots, sim_frh_imp, sim_frh_iso, color=colors, psym=1
  
  ; colorbar
  CBPosition = [0.2,0.05,0.7,0.07]
  ColorBar, Max=max,     Min=min,    NColors=Ncolor,     $
    	      Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition, $
    		Unit=Unit,       Divisions=Ndiv, Log=Log,             $
	      Format=Format,   Charsize=2,       $
    	      C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=4, _EXTRA=e

  xyouts, 0.73, 0.05, '[NH!d4!u+!n]/[SO!d4!u2-!n] !CMolar ratio', color=1, $
      charsize=charsize, charthick=charthick, /normal

;  screen2jpg, 'frh_scatter2.jpg'



 end


 if n_elements(obs) eq 0 then begin
    sim    = get_model_day_improve(res=1)
    bkg    = get_model_day_improve(res=11)
    obs    = get_improve_dayly()
    newsim = syncro( sim, obs )
    newbkg = syncro( bkg, obs )
    id = group( obs )

 endif

 fld = newbkg

 !P.multi=[0,2,2,0,0]

 Pos = cposition(2,2,xoffset=[0.1,0.1],yoffset=[0.05,0.17], $
       xgap=0.05,ygap=0.1,order=0)

  W = Where(fld.lon le -95.)
  E = Where(fld.lon gt -95.)
  jday = fld[0].jday
  jmon = tau2month(jday)
  
  djf = where(jmon eq 1 or jmon eq 2 or jmon eq 12)
  mam = where(jmon eq 3 or jmon eq 4 or jmon eq 5)
  jja = where(jmon eq 6 or jmon eq 7 or jmon eq 8)
  son = where(jmon eq 9 or jmon eq 10 or jmon eq 11)

 if !D.name eq 'PS' then $
   open_device, file='fRH_scatter.ps', /color, /ps, /landscape

  rh_scatter_plot, sim=fld[W], pos=pos[*,0], id=son
  rh_scatter_plot, sim=fld[E], pos=pos[*,1], id=son

 if !D.name eq 'PS' then close_device

 end

;=================
