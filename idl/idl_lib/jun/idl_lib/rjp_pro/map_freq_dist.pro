 function group, obs

  COMMON SHARE, SPEC

   ; Light extinction from IMPROVE obs
   ammso4_bext = make_zero(obs.ammso4_bext, val='NaN')
   ammno3_bext = make_zero(obs.ammno3_bext, val='NaN')
   ec_bext     = make_zero(obs.ec_bext,     val='NaN')
   omc_bext    = make_zero(obs.omc_bext,    val='NaN')
   soil_bext   = make_zero(obs.soil_bext,   val='NaN')
   cm_bext     = make_zero(obs.cm_bext,     val='NaN')

   ext = ammso4_bext+ammno3_bext+ec_bext+omc_bext+10.;+soil_bext+cm_bext
   vis = 10. * Alog( ext / 10. )

   avg = fltarr(N_elements(obs.siteid))
   std = avg

   For D = 0, N_elements(obs.siteid)-1 do begin
      data = chk_undefined(reform(vis[*,D]))

     if data[0]          ne -1   and $
        n_elements(data) gt 80.  and $
        obs[D].lat       gt 20.  then begin
        avg[D] = Mean(Data)
        std[D] = STDDEV(Data)
     end else begin
        avg[D] = -999.
        std[D] = -999.
     end
  End

   W  = where(obs.lon le -95. and avg gt 0. and std gt 0.)
   E  = where(obs.lon gt -95. and avg gt 0. and std gt 0.)

   print, mean(avg[W]), mean(std[W]), '  west'
   print, mean(avg[E]), mean(std[E]), '  east'

   avgw = 9.
   stdw = 3.5
   W1 = Where(obs.lon le -95. and avg ge avgw and std ge stdw)
   W2 = Where(obs.lon le -95. and avg ge avgw and std gt 0. and std lt stdw)
   W3 = Where(obs.lon le -95. and avg gt 0. and avg lt avgw and std ge stdw)
   W4 = Where(obs.lon le -95. and avg gt 0. and avg lt avgw and std gt 0. and std lt stdw)

   avge = 18.
   stde = 5.
   E1 = Where(obs.lon gt -95. and avg ge avge and std ge stde)
   E2 = Where(obs.lon gt -95. and avg ge avge and std gt 0. and std lt stde)
   E3 = Where(obs.lon gt -95. and avg gt 0. and avg lt avge and std ge stde)
   E4 = Where(obs.lon gt -95. and avg gt 0. and avg lt avge and std gt 0. and std lt stde)

   return, {W:W, E:E, W1:W1, W2:W2, W3:W3, W4:W4, E1:E1, E2:E2, E3:E3, E4:E4}

 end

;=======================================================================

 function syncro, sim, obs

  tag = tag_names(sim[0])
  ntg = n_tags(sim[0])
  sot = Long(obs[0].jday)-1L

  For D = 0, N_elements(sim.siteid)-1 do begin

     info = sim[D]
     
     a_str = create_struct(tag[0],info.(0), $
                           tag[1],info.(1), $
                           tag[2],info.(2), $
                           tag[3],info.(3)  )

     for n = 4, ntg-1 do begin
         d1    = info.(N)
         data  = d1(sot)
         a_str = create_struct(a_str, tag[N], data)
     end

     a_str = create_struct(a_str, 'FRHO', obs[D].frhgrid)
     if D eq 0 then newsim = a_str else newsim = [newsim, a_str]
  End

  return, newsim
 end

;=======================================================================

pro map_dist, obs, sim, pos=pos

  @define_plot_size
  @calc_bext

  COMMON SHARE, SPEC

  ; Data selecting 

  CASE SPEC OF
   'SO4' : obs_fld = ammso4_bext
   'NO3' : obs_fld = ammno3_bext
   'EC'  : obs_fld = ec_bext
   'OMC' : obs_fld = omc_bext
   'ALL2': obs_fld = ammso4_bext+ammno3_bext
   'ALL4': obs_fld = ammso4_bext+ammno3_bext+ec_bext+omc_bext
   'ALL' : obs_fld = ammso4_bext+ammno3_bext+ec_bext+omc_bext+soil_bext+cm_bext
  END

  CASE SPEC OF
   'SO4' : sim_fld = rbext_ammso4
   'NO3' : sim_fld = rbext_ammno3
   'EC'  : sim_fld = rbext_ec
   'OMC' : sim_fld = rbext_omc
   'ALL2': sim_fld = rbext_ammso4+rbext_ammno3
   'ALL4': sim_fld = rbext_ammso4+rbext_ammno3+rbext_ec+rbext_omc
   'ALL' : sim_fld = rbext_ammso4+rbext_ammno3+rbext_ec+rbext_omc+soil_bext+cm_bext
  END

  ; Convert extinction into visibility
  obs_fld = 10. * Alog( (obs_fld + 10.) / 10. )
  sim_fld = 10. * Alog( (sim_fld + 10.) / 10. )

  obs_stat    = stat( obs, obs_fld )
  sim_stat    = stat( sim, sim_fld )

  CASE SPEC OF
   'SO4' : begin
           Min_avg = 1.
           Max_avg = 80.

           Min_std = 2.
           Max_std = 60.
           end
   'NO3' : begin
           Min_avg = 1.
           Max_avg = 20.

           Min_std = 2.
           Max_std = 30.
           end 
   'EC'  : begin
           Min_avg = 1.
           Max_avg = 10.

           Min_std = 1.
           Max_std = 5.
           end
   'OMC' : begin
           Min_avg = 1.
           Max_avg = 20.

           Min_std = 2.
           Max_std = 15.
           end
   'ALL4': begin
           Min_avg = 1.
           Max_avg = 90.

           Min_std = 2.
           Max_std = 70.
           end
   'ALL2': begin
           Min_avg = 1.
           Max_avg = 80.

           Min_std = 2.
           Max_std = 60.
           end
   'ALL' : begin
           Min_avg = 1.
           Max_avg = 80.

           Min_std = 2.
           Max_std = 60.
           end
   'VIS' : begin
           Min_avg = 6.
           Max_avg = 24.

           Min_std = 2.
           Max_std = 7.
           end
  END

           Min_avg = 6.
           Max_avg = 24.

           Min_std = 2.
           Max_std = 7.


 if n_elements(pos) eq 0 then begin
  ;---------------Plotting----------------------;
 !P.multi=[0,2,2,0,0]

 Pos = cposition(2,2,xoffset=[0.05,0.15],yoffset=[0.1,0.1], $
       xgap=0.02,ygap=0.12,order=0)

 end

 C      = Myct_defaults()
 Bottom = C.Bottom
; Bottom = 1.
 Ncolor = 255L-Bottom
 Ndiv   = 6
 Format = '(F4.1)'
 Unit   = '[dv]'
 csfac  = 1.5

 C_obs_avg = bytscl( obs_stat.avg, Min=Min_avg, Max=Max_avg, $
      	         Top = Ncolor) + Bottom

 C_sim_avg = bytscl( sim_stat.avg, Min=Min_avg, Max=Max_avg, $
      	         Top = Ncolor) + Bottom

 C_obs_std = bytscl( obs_stat.std, Min=Min_std, Max=Max_std, $
                     Top = Ncolor) + Bottom

 C_sim_std = bytscl( sim_stat.std, Min=Min_std, Max=Max_std, $
                     Top = Ncolor) + Bottom

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
          Align=1.0, Color=1, /Normal, charsize=csfac 

  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac


  plots, obs_stat.lon, obs_stat.Lat, color=c_obs_avg, psym=8, symsize=symsize

  ;----simulation------
  map_set, 0, 0, color=1, /contine, limit = [25., -130., 50., -60.], /usa, $
   /noerase, position=pos[*,1]
  plots, sim_stat.lon, sim_stat.Lat, color=c_sim_avg, psym=8, symsize=symsize

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac

  ; colorbar
  dx = pos[2,1]-pos[2,1]*0.8
  CBPosition = [pos[0,0]+dx,pos[1,0]-0.05,pos[2,1]*0.8,pos[1,0]-0.03]
  ColorBar, Max=max_avg,     Min=min_avg,    NColors=Ncolor,     $
    	      Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition, $
    		Unit=Unit,       Divisions=Ndiv, Log=Log,             $
	      Format=Format,   Charsize=csfac,       $
    	      C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick, _EXTRA=e


  ;==========================
  ; Distribution of std
  ;==========================

  ;------observation----------
  map_set, 0, 0, color=1, /contine, limit=limit, /usa,$
    position=pos[*,2], /noerase

  plots, obs_stat.lon, obs_stat.Lat, color=c_obs_std, psym=8, symsize=symsize

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
          Align=1.0, Color=1, /Normal, charsize=csfac 
  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac

  ;------simulation----------
  map_set, 0, 0, color=1, /contine, limit = [25., -130., 50., -60.], /usa,$
    position=pos[*,3], /noerase

  plots, sim_stat.lon, sim_stat.Lat, color=c_sim_std, psym=8, symsize=symsize

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac

  ;------colorbar---------------
  dx = pos[2,3]-pos[2,3]*0.8
  CBPosition = [pos[0,2]+dx,pos[1,2]-0.05,pos[2,3]*0.8,pos[1,2]-0.03]
 
  ColorBar, Max=max_std,     Min=min_std,    NColors=Ncolor,     $
     	      Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition, $
     		Unit=Unit,       Divisions=Ndiv, Log=Log,             $
	      Format=Format, Charsize=csfac,       $
     	      C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick, _EXTRA=e

  x1 = 0.5*(pos[0,0]+pos[2,0])
  x2 = 0.5*(pos[0,1]+pos[2,1])
  xyouts, x1, 0.92, 'IMPROVE', color=1, charsize=tcharsize, $
    charthick=charthick, /normal, alignment=0.5
  xyouts, x2, 0.92, 'GEOS-CHEM', color=1, charsize=tcharsize, $
    charthick=charthick, /normal, alignment=0.5

  x1 = 0.5*(pos[2,0]+pos[0,1])
  x2 = 0.5*(pos[2,2]+pos[0,3])
  xyouts, x1, 0.92, 'MEAN', color=1, charsize=tcharsize, $
    charthick=charthick, /normal, alignment=0.5
  xyouts, x2, 0.44, 'STANDARD DEVIATIION', color=1, charsize=tcharsize, $
    charthick=charthick, /normal, alignment=0.5

;  xyouts, 0.43, 0.94, 'DECIVIEW (2001)', color=1, charsize=tcharsize,$
;    charthick=charthick, /normal, alignment=0.5


 end


;=======================================================================

pro obs_map_dist, obs, sim, fac=fac, pos=pos

 if n_elements(fac) eq 0 then fac = 1.

  COMMON SHARE, SPEC

  @define_plot_size
  @calc_bext

  ; Data selecting 

  CASE SPEC OF
   'SO4' : obs_fld = ammso4_bext
   'NO3' : obs_fld = ammno3_bext
   'EC'  : obs_fld = ec_bext
   'OMC' : obs_fld = omc_bext
   'ALL2': obs_fld = ammso4_bext+ammno3_bext
   'ALL4': obs_fld = ammso4_bext+ammno3_bext+ec_bext+omc_bext
   'ALL' : obs_fld = ammso4_bext+ammno3_bext+ec_bext+omc_bext+soil_bext+cm_bext
  END

  ; Convert from Bext to deciview index
  obs_fld  = 10. * Alog( (obs_fld+10.) / 10. )
  obs_stat = stat( obs, obs_fld )

  CASE SPEC OF
   'SO4' : begin
           Min_avg = 1.
           Max_avg = 80.

           Min_std = 2.
           Max_std = 60.
           end
   'NO3' : begin
           Min_avg = 1.
           Max_avg = 20.

           Min_std = 2.
           Max_std = 30.
           end 
   'EC'  : begin
           Min_avg = 1.
           Max_avg = 10.

           Min_std = 1.
           Max_std = 5.
           end
   'OMC' : begin
           Min_avg = 1.
           Max_avg = 20.

           Min_std = 2.
           Max_std = 15.
           end
   'ALL4': begin
           Min_avg = 1.
           Max_avg = 90.

           Min_std = 2.
           Max_std = 70.
           end
   'ALL2': begin
           Min_avg = 1.
           Max_avg = 80.

           Min_std = 2.
           Max_std = 60.
           end
   'ALL' : begin
           Min_avg = 1.
           Max_avg = 80.

           Min_std = 2.
           Max_std = 60.
           end
   'VIS' : begin
           Min_avg = 6.
           Max_avg = 24.

           Min_std = 2.
           Max_std = 7.
           end
  END

           Min_avg = 6.
           Max_avg = 24.

           Min_std = 2.
           Max_std = 7.

  ;---------------Plotting----------------------;

 C      = Myct_defaults()
 Bottom = C.Bottom
; Bottom = 1.
 Ncolor = 255L-Bottom
 Ndiv   = 6
 Format = '(F4.1)'
 Unit = ''
 csfac = 1.2

 C_obs_avg = bytscl( obs_stat.avg, Min=Min_avg, Max=Max_avg, $
      	         Top = Ncolor) + Bottom

 C_obs_std = bytscl( obs_stat.std, Min=Min_std, Max=Max_std, $
                     Top = Ncolor) + Bottom

  ;=========================
  ; Distribution of mean 
  ;========================
  limit = [25., -130., 50., -60.]
  LatRange = [ Limit[0], Limit[2] ]
  LonRange = [ Limit[1], Limit[3] ]

  ;---- observation----
  position = reform(pos[*,0])
  map_set, 0, 0, color=1, /contine, limit=limit, /usa,$
    position=pos[*,0], /noerase

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

;  XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
;          Align=1.0, Color=1, /Normal, charsize=csfac 

;  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
;          Align=0.5, Color=1, /Normal, charsize=csfac


  plots, obs_stat.lon, obs_stat.Lat, color=c_obs_avg, psym=8, $
         symsize=symsize*fac

  ; colorbar
  b = (position[2]-position[0])*0.8
  a = (position[0]+position[2])*0.5
  x2 = (2.*a+b)/2.
  x1 = 2.*a-x2
  dy = (position[3]-position[1])*0.15
  y1 = position[1] - dy
  y2 = y1 + 0.5*dy
  CBPosition = [x1,y1,x2,y2]

  ColorBar, Max=max_avg,     Min=min_avg,    NColors=Ncolor,     $
    	      Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition, $
    		Unit=Unit,       Divisions=Ndiv, Log=Log,             $
	      Format=Format,   Charsize=csfac,       $
    	      C_Colors=CC_Colors, C_Levels=C_Levels, $
            Charthick=charthick, _EXTRA=e


  ;==========================
  ; Distribution of std
  ;==========================

  ;------observation----------
  position = reform(pos[*,1])
  map_set, 0, 0, color=1, /contine, limit=limit, /usa,$
    position=position, /noerase

  plots, obs_stat.lon, obs_stat.Lat, color=c_obs_std, psym=8, $
        symsize=symsize*fac

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

;  XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
;          Align=1.0, Color=1, /Normal, charsize=csfac 
;  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
;          Align=0.5, Color=1, /Normal, charsize=csfac

  ;------colorbar---------------
  b = (position[2]-position[0])*0.8
  a = (position[0]+position[2])*0.5
  x2 = (2.*a+b)/2.
  x1 = 2.*a-x2
  dy = (position[3]-position[1])*0.15
  y1 = position[1] - dy
  y2 = y1 + 0.5*dy
  CBPosition = [x1,y1,x2,y2]
 
  ColorBar, Max=max_std,     Min=min_std,    NColors=Ncolor,     $
     	      Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition, $
     		Unit=Unit,       Divisions=Ndiv, Log=Log,             $
	      Format=Format,   Charsize=csfac,       $
     	      C_Colors=CC_Colors, C_Levels=C_Levels, $
            Charthick=charthick, _EXTRA=e

;  xyouts, 0.17, 0.92, 'IMPROVE', color=1, charsize=tcharsize, $
;    charthick=charthick, /normal, alignment=0.5
;  xyouts, 0.65, 0.92, 'GEOS-CHEM', color=1, charsize=tcharsize, $
;    charthick=charthick, /normal, alignment=0.5

;  xyouts, 0.86, 0.73, 'MEAN', color=1, charsize=tcharsize, $
;    charthick=charthick, /normal, alignment=0.
;  xyouts, 0.86, 0.27, 'STANDARD!CDEVIATIION', color=1, charsize=tcharsize, $
;    charthick=charthick, /normal, alignment=0.

;  xyouts, 0.43, 0.94, 'DECIVIEW (2001)', color=1, charsize=tcharsize,$
;    charthick=charthick, /normal, alignment=0.5


 end

;=======================================================================


 pro plot_histo, obs=obs, sim=sim, cumulative=cumulative, $
     deciview=deciview, position=position

  COMMON SHARE, SPEC

  @define_plot_size
  @calc_bext

  Nbins = 150.

  p    = [0.1,0.9]

  Xtitle = 'B!dext!n (Mm!u-1!n)'

  CASE SPEC OF
   'SO4' : begin
           MinD=0.
           MaxD=200.
           yrange = [0.,3.]
           Xtitle = '(dv)'
           end
   'NO3' : begin
           MinD=0.
           MaxD=200.
           yrange = [0.,3.]
           Xtitle = '(dv)'

           end 
   'EC'  : begin
           MinD=0.
           MaxD=200.
           yrange = [0.,3.]
           Xtitle = '(dv)'

           end
   'OMC' : begin
           MinD=0.
           MaxD=200.
           yrange = [0.,3.]
           end
   'ALL4': begin
;           MaxD=100.
;           MinD=0.
;           yrange = [0.,200]
           xrange = [1., 100.]
           end
   'ALL' : begin
           xrange = [1., 100.]
           end
   'VIS' : begin
           MaxD=50.
           MinD=1
           yrange = [0.,1.]
           Xtitle = '(dv)'
           end
  END

;  ; Light extinction from IMPROVE obs
;  ammso4_bext = makevector(obs.ammso4_bext)
;  ammno3_bext = makevector(obs.ammno3_bext)
;  ec_bext     = makevector(obs.ec_bext)
;  omc_bext    = makevector(obs.omc_bext)
;  soil_bext   = makevector(obs.soil_bext)
;  cm_bext     = makevector(obs.cm_bext)
;;  obs_frh     = chk_undefined(obs.frhgrid)
;;  obs_rh      = chk_undefined(obs.rhgrid)
;
;  ; Light extinction from GEOS-CHEM simulation
;  ; Mass 
;  ammno3      = makevector(sim.nit)*1.29
;  ammso4      = makevector(sim.so4)*1.375 ; +makevector(sim.nh4)-ammno3
;  EC          = makevector(sim.ec)
;  OMC         = makevector(sim.omc)
;  sim_frh     = makevector(sim.frho)
;
;  ; Reconstructed light extinction
;  rbext_ammso4 = 3.*sim_frh*ammso4
;  rbext_ammno3 = 3.*sim_frh*ammno3
;  rbext_omc    = 4.*omc
;  rbext_ec     = 10.*ec

  CASE SPEC OF
   'SO4' : obs_bext = chk_undefined(ammso4_bext)
   'NO3' : obs_bext = chk_undefined(ammno3_bext)
   'EC'  : obs_bext = chk_undefined(ec_bext)
   'OMC' : obs_bext = chk_undefined(omc_bext)
   'ALL4': obs_bext = chk_undefined(ammso4_bext+ammno3_bext+ec_bext+omc_bext)
   'ALL' : obs_bext = chk_undefined(ammso4_bext+ammno3_bext+ec_bext+omc_bext+soil_bext+cm_bext)
  END

  CASE SPEC OF
   'SO4' : sim_bext = chk_undefined(rbext_ammso4)
   'NO3' : sim_bext = chk_undefined(rbext_ammno3)
   'EC'  : sim_bext = chk_undefined(rbext_ec)
   'OMC' : sim_bext = chk_undefined(rbext_omc)
   'ALL4': sim_bext = chk_undefined(rbext_ammso4+rbext_ammno3+rbext_ec+rbext_omc)
   'ALL' : sim_bext = chk_undefined(rbext_ammso4+rbext_ammno3+rbext_ec+rbext_omc+rbext_soil+rbext_cm)
  END

  if keyword_set(deciview) then begin
     obs_vis = 10. * Alog( (obs_bext+10.) / 10. )
     sim_vis = 10. * Alog( (sim_bext+10.) / 10. )

     obs_d = obs_vis
     sim_d = sim_vis
  endif
   
     MaxD = Max(obs_d) < 35.
;     MaxD=35.
     MinD = Min(obs_d) < Min(sim_d)
;     yrange = [MinD,MaxD]
     Xtitle = '(dv)'
     yrange = [0., 3]
     xrange = [0., 40.]


;  out = nan_chk(obs_bext, sim_bext)
;  check, out

;xrange = [-4., 4.]

; title = 'B!dext!n ('+SPEC+') at IMPROVE in the West (<95!uo!nW)'
 title = 'Frequency distribution of B!dext!n at IMPROVE sites'
 title = ' '
 o = histo( obs_d, p, MinD=MinD, MaxD=MaxD, Nbins=Nbins, pos=Position, $
        color=1, line=0, Xtitle=Xtitle, $
        Title=title, yrange=yrange, xrange=xrange, $
        xticks=5, cumulative=cumulative)


 ; Simulation (blue dotted)
 s = histo( sim_d, p, MinD=MinD, MaxD=MaxD, Nbins=Nbins,  /Oplot, $
        color=4, line=1, cumulative=cumulative, yrange=yrange )

;=======Label=========
 format='(f5.1)'
 xrange=[-2.,3.]
 yval  = yrange[1]*1.25
 dy    = yrange[1]/15.
 plots, xrange, [yval,yval]-0.9*dy, color=1, line=1, thick=thick, symsize=symsize
 plots, xrange, [yval,yval]-1.9*dy, color=4, line=1, thick=thick, symsize=symsize

  label = 'B!dext!n for Sulfate, Nitrate, OMC, EC';, !8Soil, CM!3'
  label = ' '
  xyouts, xrange[1]*0.6, yval+dy, label,$
          color=1, charsize=charsize, charthick=charthick

  charsize=1.
  xyouts, xrange[1]*1.1, yval, '(Mean, STD, p10, p90)', color=1, $
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



 return

 end

;============================================================================

 res = 2

 if n_elements(obs) eq 0 then begin
    sim    = get_model_day_improve(res=res)
    obs    = get_improve_dayly()
    newsim = syncro( sim, obs )
 endif

  id = group( obs )

  COMMON SHARE, SPEC
  SPEC = 'ALL4'

  comment = 'Eastern site (>95W),!C!C #3, Mean<18, STD>5'
;  comment = 'Eastern site (>95W)'
  figfile = 'E3_vis_dist_2x25.ps'

  @define_plot_size

  !P.multi=[0,3,2,0,0]
  Pos = cposition(3,2,xoffset=[0.05,0.12],yoffset=[0.1,0.1], $
        xgap=0.01,ygap=0.15,order=0)
  if !D.name eq 'PS' then $
    open_device, file=figfile, /color, /ps, /landscape
 
  erase

  mapid = id.e3

  newpos = fltarr(4,4)
  newpos[*,0:1] = pos[*,0:1]
  newpos[*,2:3] = pos[*,3:4]

  map_dist, obs(mapid), newsim(mapid), pos=newpos

  position = pos[*,2]
  dx = 0.04
  dy = 0.25
  position = [position[0]+dx,position[1]-dy,position[2]+dx*2.4,position[3]-dy]

  deciview=1
  plot_histo, obs=obs(mapid), sim=newsim(mapid), $
    deciview=deciview, position=position;, /cumulative

  print, mean(obs[mapid].elev), ptz(mean(newsim[mapid].pres)), '  Mean altitude'


  xyouts, 0.65, 0.2, comment, color=1, alignment=0., /normal, $
    charsize=charsize, charthick=charthick

 if !D.name eq 'PS' then close_device

End
