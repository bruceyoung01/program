
;=========================================================================

pro map_dist, obs, sim, bkg, nat, asi, pos=pos

  COMMON SHARE, SPEC, MAXD, MAXP

  @define_plot_size
  @calc_bext

  ; Data selecting 

  CASE SPEC OF
   'SO4' : obs_fld = ammso4_bext
   'NO3' : obs_fld = ammno3_bext
   'EC'  : obs_fld = ec_bext
   'OMC' : obs_fld = omc_bext
   'CARB': obs_fld = omc_bext + ec_bext
   'IOA' : obs_fld = ammso4_bext+ammno3_bext
   'ALL4': obs_fld = ammso4_bext+ammno3_bext+ec_bext+omc_bext
   'ALL' : obs_fld = ammso4_bext+ammno3_bext+ec_bext+omc_bext+soil_bext+cm_bext
  END

  CASE SPEC OF
   'SO4' : sim_fld = rbext_ammso4
   'NO3' : sim_fld = rbext_ammno3
   'EC'  : sim_fld = rbext_ec
   'OMC' : sim_fld = rbext_omc
   'CARB': sim_fld = rbext_omc + rbext_ec
   'IOA' : sim_fld = rbext_ammso4+rbext_ammno3
   'ALL4': sim_fld = rbext_ammso4+rbext_ammno3+rbext_ec+rbext_omc
   'ALL' : sim_fld = rbext_ammso4+rbext_ammno3+rbext_ec+rbext_omc+soil_bext+cm_bext
  END

  ; Convert extinction into visibility
  obs_fld = 10. * Alog( (obs_fld + 10.) / 10. )
  sim_fld = 10. * Alog( (sim_fld + 10.) / 10. )

  fld_stat    = sync_stat( obs, obs_fld, sim_fld )
;  sim_stat    = stat( sim, sim_fld )

  Min_avg = 1.
  Max_avg = 25.

  Min_std = 1.
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
 Ndiv   = 7
 Format = '(I3)'
 Unit   = '[dv]'
 csfac  = 1.2

 C_obs_avg = bytscl( fld_stat.obs_avg, Min=Min_avg, Max=Max_avg, $
      	         Top = Ncolor) + Bottom

 C_sim_avg = bytscl( fld_stat.sim_avg, Min=Min_avg, Max=Max_avg, $
      	         Top = Ncolor) + Bottom

 C_obs_std = bytscl( fld_stat.obs_std, Min=Min_std, Max=Max_std, $
                     Top = Ncolor) + Bottom

 C_sim_std = bytscl( fld_stat.sim_std, Min=Min_std, Max=Max_std, $
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
          Align=1.0, Color=1, /Normal, charsize=csfac, charthick=charthick

  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick


  plots, fld_stat.lon, fld_stat.Lat, color=c_obs_avg, psym=8, symsize=symsize

  ;----simulation------
  map_set, 0, 0, color=1, /contine, limit = [25., -130., 50., -60.], /usa, $
   /noerase, position=pos[*,1]
  plots, fld_stat.lon, fld_stat.Lat, color=c_sim_avg, psym=8, symsize=symsize

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick

  ; colorbar
  dx = pos[2,1]-pos[2,1]*0.8
  CBPosition = [pos[0,0]+dx,pos[1,0]-0.06,pos[2,1]*0.8,pos[1,0]-0.03]
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

  plots, fld_stat.lon, fld_stat.Lat, color=c_obs_std, psym=8, symsize=symsize

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
          Align=1.0, Color=1, /Normal, charsize=csfac , charthick=charthick
  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick

  ;------simulation----------
  map_set, 0, 0, color=1, /contine, limit = [25., -130., 50., -60.], /usa,$
    position=pos[*,3], /noerase

  plots, fld_stat.lon, fld_stat.Lat, color=c_sim_std, psym=8, symsize=symsize

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick

  ;------colorbar---------------
  dx = pos[2,3]-pos[2,3]*0.8
  CBPosition = [pos[0,2]+dx,pos[1,2]-0.06,pos[2,3]*0.8,pos[1,2]-0.03]
 
  ColorBar, Max=max_std,     Min=min_std,    NColors=Ncolor,     $
     	      Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition, $
     		Unit=Unit,       Divisions=Ndiv, Log=Log,             $
	      Format=Format, Charsize=csfac,       $
     	      C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick, _EXTRA=e

  x1 = 0.5*(pos[0,0]+pos[2,0])
  x2 = 0.5*(pos[0,1]+pos[2,1])
  y1 = pos[3,0]+0.01

  xyouts, 0.07, 0.95, spec, color=1, charsize=tcharsize, $
   charthick=charthick, /normal, alignment=0.5

  xyouts, x1, y1, 'IMPROVE', color=1, charsize=tcharsize, $
    charthick=charthick, /normal, alignment=0.5
  xyouts, x2, y1, 'GEOS-CHEM', color=1, charsize=tcharsize, $
    charthick=charthick, /normal, alignment=0.5

  x1 = 0.5*(pos[2,0]+pos[0,1])
  x2 = 0.5*(pos[2,2]+pos[0,3])
  y2 = pos[3,2]+0.01
  xyouts, x1, y1, 'MEAN', color=1, charsize=charsize, $
    charthick=charthick, /normal, alignment=0.5
  xyouts, x2, y2, 'STANDARD DEVIATION', color=1, charsize=charsize, $
    charthick=charthick, /normal, alignment=0.5


  x = pos[0,0]
  str = string(mean(fld_stat.obs_avg),format='(f4.1)')
  xyouts, x, y1, str, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

  x = pos[2,1]
  str = string(mean(fld_stat.sim_avg),format='(f4.1)')
  xyouts, x, y1, str, color=1, charsize=charsize, /normal, alignment=1, $
    charthick=charthick

  x3 = pos[0,2]
  str = string(mean(fld_stat.obs_std),format='(f3.1)')
  xyouts, x3, y2, str, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

  x4 = pos[2,3]
  str = string(mean(fld_stat.sim_std),format='(f3.1)')
  xyouts, x4, y2, str, color=1, charsize=charsize, /normal, alignment=1, $
    charthick=charthick

;  xyouts, 0.43, 0.94, 'DECIVIEW (2001)', color=1, charsize=tcharsize,$
;    charthick=charthick, /normal, alignment=0.5


 end
