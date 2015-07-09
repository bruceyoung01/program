
pro map_dist, obs, sim, bkg, nat, pos=pos

  COMMON SHARE, SPEC, MAXD, MAXP

  @define_plot_size
  @calc_bext

  ; Data selecting 

  CASE SPEC OF
   'SO4' : begin
             bkg_fld = bbext_ammso4
             nat_fld = nbext_ammso4
           end
   'NO3' : begin
             bkg_fld = bbext_ammno3
             nat_fld = nbext_ammno3
           end
   'EC'  : begin
             bkg_fld = bbext_ec
             nat_fld = nbext_ec
           end
   'OMC' : begin
             bkg_fld = bbext_omc
             nat_fld = nbext_omc
           end
   'ALL4': begin
             bkg_fld = bbext_ammso4+bbext_ammno3+bbext_ec+bbext_omc
             nat_fld = nbext_ammso4+nbext_ammno3+nbext_ec+nbext_omc
           end
   'ALL' : begin
        ;     bkg_fld = bbext_ammso4+bbext_ammno3+bbext_ec+bbext_omc+0.5+1.8
        ;     nat_fld = nbext_ammso4+nbext_ammno3+nbext_ec+nbext_omc+0.5+1.8
             bkg_fld = bbext_ammso4+bbext_ammno3+bbext_ec+bbext_omc+soil_bext+cm_bext
             nat_fld = nbext_ammso4+nbext_ammno3+nbext_ec+nbext_omc+soil_bext+cm_bext
           end
  END

  ; Convert extinction into visibility
  bkg_fld = 10. * Alog( (bkg_fld + 10.) / 10. )
  nat_fld = 10. * Alog( (nat_fld + 10.) / 10. )

  bkg_stat  = stat( bkg, bkg_fld )
  nat_stat  = stat( nat, nat_fld )

  Min_avg = 1.
  Max_avg = 13.

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

 C_bkg_avg = bytscl( bkg_stat.avg, Min=Min_avg, Max=Max_avg, $
      	         Top = Ncolor) + Bottom

 C_nat_avg = bytscl( nat_stat.avg, Min=Min_avg, Max=Max_avg, $
      	         Top = Ncolor) + Bottom

 C_bkg_std = bytscl( bkg_stat.std, Min=Min_std, Max=Max_std, $
                     Top = Ncolor) + Bottom

 C_nat_std = bytscl( nat_stat.std, Min=Min_std, Max=Max_std, $
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


  plots, bkg_stat.lon, bkg_stat.Lat, color=c_bkg_avg, psym=8, symsize=symsize

  ;----simulation------
  map_set, 0, 0, color=1, /contine, limit = [25., -130., 50., -60.], /usa, $
   /noerase, position=pos[*,1]
  plots, nat_stat.lon, nat_stat.Lat, color=c_nat_avg, psym=8, symsize=symsize

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick

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

  plots, bkg_stat.lon, bkg_stat.Lat, color=c_bkg_std, psym=8, symsize=symsize

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

  plots, nat_stat.lon, nat_stat.Lat, color=c_nat_std, psym=8, symsize=symsize

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick

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
  y1 = pos[3,0]+0.01

  xyouts, 0.07, 0.95, spec, color=1, charsize=tcharsize, $
   charthick=charthick, /normal, alignment=0.5

  xyouts, x1, y1, 'Background', color=1, charsize=charsize, $
    charthick=charthick, /normal, alignment=0.5
  xyouts, x2, y1, 'Natural', color=1, charsize=charsize, $
    charthick=charthick, /normal, alignment=0.5

  x1 = 0.5*(pos[2,0]+pos[0,1])
  x2 = 0.5*(pos[2,2]+pos[0,3])
  y2 = pos[3,2]+0.01
  xyouts, x1, y1, 'MEAN', color=1, charsize=tcharsize, $
    charthick=charthick, /normal, alignment=0.5
  xyouts, x2, y2, 'STANDARD DEVIATION', color=1, charsize=tcharsize, $
    charthick=charthick, /normal, alignment=0.5


  x = pos[0,0]
  str = string(mean(bkg_stat.avg),format='(f4.1)')
  xyouts, x, y1, str, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

  x = pos[2,1]
  str = string(mean(nat_stat.avg),format='(f4.1)')
  xyouts, x, y1, str, color=1, charsize=charsize, /normal, alignment=1, $
    charthick=charthick

  x3 = pos[0,2]
  str = string(mean(bkg_stat.std),format='(f3.1)')
  xyouts, x3, y2, str, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

  x4 = pos[2,3]
  str = string(mean(nat_stat.std),format='(f3.1)')
  xyouts, x4, y2, str, color=1, charsize=charsize, /normal, alignment=1, $
    charthick=charthick

;  xyouts, 0.43, 0.94, 'DECIVIEW (2001)', color=1, charsize=tcharsize,$
;    charthick=charthick, /normal, alignment=0.5


 end

;==============================================================================

 function take_avg, val

  NN  = n_elements(val)
  dat = reform(val, NN)

  avg = 0.
  fac = 0.

  For d = 0L, NN-1 do begin
    if dat[d] gt 0. then begin
       avg = avg + dat[d]
       fac = fac + 1.
    end
  end

 return, avg/fac

 end

;===============================================================================

 pro value, obs, sim, bkg, nat, asi

  bdlon = -95.
  bdlat = 35.

  idnw = where(obs.lon le bdlon and obs.lat gt bdlat and obs.lon gt -130.)
  idne = where(obs.lon gt bdlon and obs.lat gt bdlat )
  idsw = where(obs.lon le bdlon and obs.lat le bdlat and obs.lon gt -130. and obs.lat gt 20.)
  idse = where(obs.lon gt bdlon and obs.lat le bdlat and obs.lat gt 20.)

  print, '================================================='
  print, 'sulfate, nitrate, ec, omc'
  print, 'improve(2001)'
  format = '(5x,4(1x,4F5.2))'
  print, mean(make_zero(obs[idnw].so4,val='NaN'),/NaN), $
         mean(make_zero(obs[idsw].so4,val='NaN'),/NaN), $
         mean(make_zero(obs[idne].so4,val='NaN'),/NaN), $
         mean(make_zero(obs[idse].so4,val='NaN'),/NaN), $
         mean(make_zero(obs[idnw].no3,val='NaN'),/NaN), $
         mean(make_zero(obs[idsw].no3,val='NaN'),/NaN), $
         mean(make_zero(obs[idne].no3,val='NaN'),/NaN), $
         mean(make_zero(obs[idse].no3,val='NaN'),/NaN), $      
         mean(make_zero(obs[idnw].ec,val='NaN'),/NaN), $
         mean(make_zero(obs[idsw].ec,val='NaN'),/NaN), $
         mean(make_zero(obs[idne].ec,val='NaN'),/NaN), $
         mean(make_zero(obs[idse].ec,val='NaN'),/NaN), $
         mean(make_zero(obs[idnw].omc,val='NaN'),/NaN), $
         mean(make_zero(obs[idsw].omc,val='NaN'),/NaN), $
         mean(make_zero(obs[idne].omc,val='NaN'),/NaN), $
         mean(make_zero(obs[idse].omc,val='NaN'),/NaN), $
         format=format

  print, 'baseline (2001)'
  print, mean(sim[idnw].so4), mean(sim[idsw].so4), mean(sim[idne].so4), mean(sim[idse].so4),$
         mean(sim[idnw].nit), mean(sim[idsw].nit), mean(sim[idne].nit), mean(sim[idse].nit),$
         mean(sim[idnw].ec), mean(sim[idsw].ec), mean(sim[idne].ec), mean(sim[idse].ec),   $
         mean(sim[idnw].omc), mean(sim[idsw].omc), mean(sim[idne].omc), mean(sim[idse].omc),$
         format=format

  print, 'background'
  print, mean(bkg[idnw].so4), mean(bkg[idsw].so4), mean(bkg[idne].so4), mean(bkg[idse].so4), $               
         mean(bkg[idnw].nit), mean(bkg[idsw].nit), mean(bkg[idne].nit), mean(bkg[idse].nit), $               
         mean(bkg[idnw].ec), mean(bkg[idsw].ec), mean(bkg[idne].ec), mean(bkg[idse].ec),     $            
         mean(bkg[idnw].omc), mean(bkg[idsw].omc), mean(bkg[idne].omc), mean(bkg[idse].omc), $
         format=format

  print, 'natural'
  print, mean(nat[idnw].so4), mean(nat[idsw].so4), mean(nat[idne].so4), mean(nat[idse].so4), $
         mean(nat[idnw].nit), mean(nat[idsw].nit), mean(nat[idne].nit), mean(nat[idse].nit), $
         mean(nat[idnw].ec), mean(nat[idsw].ec), mean(nat[idne].ec), mean(nat[idse].ec),     $
         mean(nat[idnw].omc), mean(nat[idsw].omc), mean(nat[idne].omc), mean(nat[idse].omc), $
         format=format

  print, 'canada and mexico'
  print, mean(bkg[idnw].so4)-mean(asi[idnw].so4), mean(bkg[idsw].so4)-mean(asi[idsw].so4), $
         mean(bkg[idne].so4)-mean(asi[idne].so4), mean(bkg[idse].so4)-mean(asi[idse].so4), $
         mean(bkg[idnw].nit)-mean(asi[idnw].nit), mean(bkg[idsw].nit)-mean(asi[idsw].nit), $
         mean(bkg[idne].nit)-mean(asi[idne].nit), mean(bkg[idse].nit)-mean(asi[idse].nit), $
         mean(bkg[idnw].ec)-mean(asi[idnw].ec), mean(bkg[idsw].ec)-mean(asi[idsw].ec), $
         mean(bkg[idne].ec)-mean(asi[idne].ec), mean(bkg[idse].ec)-mean(asi[idse].ec), $
         mean(bkg[idnw].omc)-mean(asi[idnw].omc), mean(bkg[idsw].omc)-mean(asi[idsw].omc), $
         mean(bkg[idne].omc)-mean(asi[idne].omc), mean(bkg[idse].omc)-mean(asi[idse].omc), $
         format=format

  print, 'Asia'
  print, mean(asi[idnw].so4)-mean(nat[idnw].so4), mean(asi[idsw].so4)-mean(nat[idsw].so4), $
         mean(asi[idne].so4)-mean(nat[idne].so4), mean(asi[idse].so4)-mean(nat[idse].so4), $
         mean(asi[idnw].nit)-mean(nat[idnw].nit), mean(asi[idsw].nit)-mean(nat[idsw].nit), $
         mean(asi[idne].nit)-mean(nat[idne].nit), mean(asi[idse].nit)-mean(nat[idse].nit), $
         mean(asi[idnw].ec)-mean(nat[idnw].ec), mean(asi[idsw].ec)-mean(nat[idsw].ec), $
         mean(asi[idne].ec)-mean(nat[idne].ec), mean(asi[idse].ec)-mean(nat[idse].ec), $
         mean(asi[idnw].omc)-mean(nat[idnw].omc), mean(asi[idsw].omc)-mean(nat[idsw].omc), $
         mean(asi[idne].omc)-mean(nat[idne].omc), mean(asi[idse].omc)-mean(nat[idse].omc), $
         format=format

 end

;===============================================================================

 pro value2, obs, sim, bkg, nat, asi

; ammonium sulfate, ammonium nitrate

  bdlon = -95.
  bdlat = 35.

  idw = where(obs.lon le bdlon and obs.lon gt -130.)
  ide = where(obs.lon gt bdlon and obs.lat gt   20.)

  print, '================================================='
  print, 'sulfate, nitrate, ec, omc'
;  print, 'improve(2001)'
  format = '(5x,4(1x,2F5.2))'
;  print, mean(make_zero(obs[idw].so4,val='NaN'),/NaN), $
;         mean(make_zero(obs[ide].so4,val='NaN'),/NaN), $
;         mean(make_zero(obs[idw].no3,val='NaN'),/NaN), $
;         mean(make_zero(obs[ide].no3,val='NaN'),/NaN), $
;         mean(make_zero(obs[idw].ec,val='NaN'),/NaN), $
;         mean(make_zero(obs[ide].ec,val='NaN'),/NaN), $
;         mean(make_zero(obs[idw].omc,val='NaN'),/NaN), $
;         mean(make_zero(obs[ide].omc,val='NaN'),/NaN), $
;         format=format

;  print, 'baseline (2001)'
;  print, mean(sim[idw].so4)+mean(sim[idw].nh4)-mean(sim[idw].nit)*0.29, $
;         mean(sim[ide].so4)+mean(sim[ide].nh4)-mean(sim[ide].nit)*0.29, $
;         mean(sim[idw].nit)*1.29, mean(sim[ide].nit)*1.29, $
;         mean(sim[idw].ec),  mean(sim[ide].ec),  $
;         mean(sim[idw].omc), mean(sim[ide].omc), $
;         format=format

  print, 'background'
  print, mean(bkg[idw].so4)+mean(bkg[idw].nh4)-mean(bkg[idw].nit)*0.29, $
         mean(bkg[ide].so4)+mean(bkg[ide].nh4)-mean(bkg[ide].nit)*0.29, $               
         mean(bkg[idw].nit)*1.29, mean(bkg[ide].nit)*1.29, $               
         mean(bkg[idw].ec),  mean(bkg[ide].ec),  $            
         mean(bkg[idw].omc), mean(bkg[ide].omc), $
         format=format

  print, 'natural'
  print, mean(nat[idw].so4)+mean(nat[idw].nh4)-mean(nat[idw].nit)*0.29, $
         mean(nat[ide].so4)+mean(nat[ide].nh4)-mean(nat[ide].nit)*0.29, $
         mean(nat[idw].nit)*1.29, $
         mean(nat[ide].nit)*1.29, $
         mean(nat[idw].ec),       $
         mean(nat[ide].ec),       $
         mean(nat[idw].omc),      $
         mean(nat[ide].omc),      $
         format=format

  print, 'canada and mexico'
  print, (mean(bkg[idw].so4)-mean(asi[idw].so4)) + $
         (mean(bkg[idw].nh4)-mean(asi[idw].nh4)) - $
         (mean(bkg[idw].nit)-mean(asi[idw].nit))*0.29, $
         (mean(bkg[ide].so4)-mean(asi[ide].so4)) + $
         (mean(bkg[ide].nh4)-mean(asi[ide].nh4)) - $
         (mean(bkg[ide].nit)-mean(asi[ide].nit))*0.29, $
         (mean(bkg[idw].nit)-mean(asi[idw].nit))*1.29, $
         (mean(bkg[ide].nit)-mean(asi[ide].nit))*1.29, $
         mean(bkg[idw].ec) -mean(asi[idw].ec),  $
         mean(bkg[ide].ec) -mean(asi[ide].ec),  $
         mean(bkg[idw].omc)-mean(asi[idw].omc), $
         mean(bkg[ide].omc)-mean(asi[ide].omc), $
         format=format

  print, 'Asia'
  print, (mean(asi[idw].so4)-mean(nat[idw].so4)) + $
         (mean(asi[idw].nh4)-mean(nat[idw].nh4)) - $
         (mean(asi[idw].nit)-mean(nat[idw].nit))*0.29, $

         (mean(asi[ide].so4)-mean(nat[ide].so4)) + $
         (mean(asi[ide].nh4)-mean(nat[ide].nh4)) - $
         (mean(asi[ide].nit)-mean(nat[ide].nit))*0.29, $

         (mean(asi[idw].nit)-mean(nat[idw].nit))*1.29, $
         (mean(asi[ide].nit)-mean(nat[ide].nit))*1.29, $
         mean(asi[idw].ec)-mean(nat[idw].ec),   $
         mean(asi[ide].ec)-mean(nat[ide].ec),   $
         mean(asi[idw].omc)-mean(nat[idw].omc), $
         mean(asi[ide].omc)-mean(nat[ide].omc), $
         format=format

 end

;============================================================================

  @ctl

  SPEC    = 'ALL4'
  figfile = 'figure06.ps'


;  bad = ['MEVE1','PEFO1']
;  m   = search_index(bad, obs[mapid].siteid, COMPLEMENT=ip) 
;  mapid = reform(mapid[ip])


;  map_dist, newobs(mapid), newsim(mapid), newbkg(mapid), newnat(mapid), pos=newpos
;  value, newobs, newsim, newbkg, newnat, newasi
  value2, obs, sim, bkg, nat, asi

;  print, '==========Mean altitude============'
;  print, mean(newobs[mapid].elev), ptz(mean(newsim[mapid].pres))


End
