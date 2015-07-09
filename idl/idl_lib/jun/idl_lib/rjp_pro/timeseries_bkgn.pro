
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
   'ALL' : sim_fld = rbext_ammso4+rbext_ammno3+rbext_ec+rbext_omc+rbext_soil+rbext_cm
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

           Min_avg = 1.
           Max_avg = 24.

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
 Ndiv   = 6
 Format = '(F4.1)'
 Unit   = '[dv]'
 csfac  = 1.2

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
          Align=1.0, Color=1, /Normal, charsize=csfac, charthick=charthick

  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick


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

  plots, obs_stat.lon, obs_stat.Lat, color=c_obs_std, psym=8, symsize=symsize

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

  plots, sim_stat.lon, sim_stat.Lat, color=c_sim_std, psym=8, symsize=symsize

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

  xyouts, x1, y1, 'IMPROVE', color=1, charsize=charsize, $
    charthick=charthick, /normal, alignment=0.5
  xyouts, x2, y1, 'GEOS-CHEM', color=1, charsize=charsize, $
    charthick=charthick, /normal, alignment=0.5

  x1 = 0.5*(pos[2,0]+pos[0,1])
  x2 = 0.5*(pos[2,2]+pos[0,3])
  y2 = pos[3,2]+0.01
  xyouts, x1, y1, 'MEAN', color=1, charsize=tcharsize, $
    charthick=charthick, /normal, alignment=0.5
  xyouts, x2, y2, 'STANDARD DEVIATION', color=1, charsize=tcharsize, $
    charthick=charthick, /normal, alignment=0.5


  x = pos[0,0]
  str = string(mean(obs_stat.avg),format='(f4.1)')
  xyouts, x, y1, str, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

  x = pos[2,1]
  str = string(mean(sim_stat.avg),format='(f4.1)')
  xyouts, x, y1, str, color=1, charsize=charsize, /normal, alignment=1, $
    charthick=charthick

  x3 = pos[0,2]
  str = string(mean(obs_stat.std),format='(f3.1)')
  xyouts, x3, y2, str, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

  x4 = pos[2,3]
  str = string(mean(sim_stat.std),format='(f3.1)')
  xyouts, x4, y2, str, color=1, charsize=charsize, /normal, alignment=1, $
    charthick=charthick

;  xyouts, 0.43, 0.94, 'DECIVIEW (2001)', color=1, charsize=tcharsize,$
;    charthick=charthick, /normal, alignment=0.5


 end


;======================================================================

 function anomal, data, jday=jday, mean=mobs

 jmon = tau2month(jday)
 mm   = jmon(uniq(jmon)) & time=mm
 nmon = n_elements(mm)
 mobs = fltarr(nmon)
 anom = fltarr(n_elements(jday))

 ; compute monthly mean
 For M = 0, nmon  - 1L do begin
     p = where(jmon eq mm[M])  ; search for the same month

     if p[0] eq -1 then begin
        mobs[mm[M]-1L] = 'NaN'
        goto, jump
     end

     s = reform(Data[P])    ; sample data for the same month
     p = where(s gt 0.)     ; remove missing data

     if p[0] eq -1 then begin
        mobs[mm[M]-1L] = 'NaN'
        goto, jump
     end

     mobs[mm[M]-1L] = mean(s[p]) ; taking mean

     jump:
 end

 for M = 0, N_elements(jday)-1 do $
     anom[m] = data[m]-mobs[jmon[m]-1L]
 
 return, anom

 end

;-------------------------------------------------------------------

 function composite, data

 ; make 2d data into 1d array
 ndim=size(data)
 mean=fltarr(ndim[1])
 std =mean

 for d = 0, ndim[1]-1 do begin
    mean[d]=mean(data[d,*],/NaN)
    if ndim[0] gt 1. then  std[d] =stddev(data[d,*],/NaN) else $
       std[*] = 0.
 end

 return, {mean:mean,std:std}
 end

;======================================================================

 function anom_composite, data, jday=jday

 ; calculate anomaly first and then make composite

   dim = size(data)
   if dim[0] eq 2 then nsite = dim[2] else nsite = 1L

   anom = data
   mean = fltarr(12,nsite)
   std  = fltarr(nsite)
   astd = std
   mstd = std
   cmean= fltarr(12)
   canom= fltarr(dim[1])
   comp = canom
   for d = 0, nsite-1 do begin
       anom[*,d] = anomal(reform(data[*,d]),jday=jday,mean=avg) ; anomly from monthly mean
       mean[*,d] = avg                                  ; monthly mean
       std[d] = stddev(data[*,d],/NaN)
       astd[d]= stddev(anom[*,d],/NaN)
       mstd[d]= stddev(mean[*,d],/NaN)
   endfor

   ; make composite of total sites for each day
   if nsite ge 2 then begin
      for d = 0, 11 do $
        cmean[d] = mean(mean[d,*],/NaN)

      for d = 0, dim[1]-1 do begin
        canom[d] = mean(anom[d,*],/NaN)
        comp[d]  = mean(data[d,*],/NaN)   
      end
   end else begin
      cmean = mean
      canom = anom
      comp  = data
   end

  return, {data:comp, mean:cmean, anom:canom,  $
           std:mean(std),std_m:mean(mstd),std_d:mean(astd)}
 end

;============================================================================

 pro tseries, obs=obs, sim=sim, bkg=bkg, $
     deciview=deciview, position=position, maxD=maxD

  COMMON SHARE, SPEC

  @define_plot_size
  @calc_bext

  Nbins = 150.

  print, spec

  p    = [0.1,0.9]

  Xtitle = 'B!dext!n (Mm!u-1!n)'

  CASE SPEC OF
   'ALL4': begin
           obs_bext = ammso4_bext+ammno3_bext+ec_bext+omc_bext
           sim_bext = rbext_ammso4+rbext_ammno3+rbext_ec+rbext_omc
           bkg_bext = bbext_ammso4+bbext_ammno3+bbext_ec+bbext_omc
           end
   'ALL' : begin
           obs_bext = ammso4_bext+ammno3_bext+ec_bext+omc_bext+soil_bext+cm_bext
           sim_bext = rbext_ammso4+rbext_ammno3+rbext_ec+rbext_omc+rbext_soil+rbext_cm
           bkg_bext = bbext_ammso4+bbext_ammno3+bbext_ec+bbext_omc+bbext_soil+bbext_cm
           end
   'SO4' : begin
           obs_bext = ammso4_bext
           sim_bext = rbext_ammso4
           bkg_bext = bbext_ammso4
           end
   'OMC' : begin
           obs_bext = omc_bext
           sim_bext = rbext_omc
           bkg_bext = bbext_omc
           end
   'NO3' : begin
           obs_bext = ammno3_bext
           sim_bext = rbext_ammno3
           bkg_bext = bbext_ammno3
           end
   'EC' : begin
           obs_bext = ec_bext
           sim_bext = rbext_ec
           bkg_bext = bbext_ec
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
   

;     MinD = Min(obs_d) < Min(sim_d)
;     yrange = [MinD, MaxD]
;     Xtitle = '(dv)'
;     xrange = [0., 100.]
;     yrange = [0., maxD]

 jday = obs[0].jday
 jmon = tau2month( jday )
 tau0_mon = indgen(12)*100L + 20010115L
 for d = 0, 11 do tau0_mon[d] = nymd2tau(tau0_mon[d]) - nymd2tau(20001231L) 
 jday_mon = tau0_mon/24L

; title = 'B!dext!n ('+SPEC+') at IMPROVE in the West (<95!uo!nW)'
 title = 'Frequency distribution of B!dext!n at IMPROVE sites'
 title = ' '
 
 xrange=[1.,365.]
 yrange=[-10.,maxD]
 xticks=6
 format='(f3.1)'

; o = composite(obs_d) 
; anom=anomal( o.mean, jday=jday, mean=avg )

  o = anom_composite(obs_d, jday=jday)

; print, stddev(avg),   ' std for month'
; print, stddev(anom),  ' std for day'
; print, stddev(o.mean),' std'

 std_m = string(o.std_m,format=format)
 std_d = string(o.std_d,format=format)
 std   = string(o.std,format=format)

 plot,  jday, o.data, color=1, position=position[*,0], thick=thick, $
        xstyle=1, yrange=yrange, xticks=xticks, xrange=xrange, $
        xtickformat='(i3)', xcharsize=charsize, ycharsize=charsize, $
        charthick=charthick
 
; for d = 0, n_elements(jday)-1 do $
;     oplot, [jday[d],jday[d]], [o.mean[d]-o.std[d], o.mean[d]+o.std[d]], $
;     color=12, thick=thin

; oplot, jday, o.mean, color=1, thick=thick

 oplot, jday,     o.anom, color=11, thick=dthin
 oplot, jday_mon, o.mean, color=4, thick=dthick, psym=-2

 xlabel=['J','F','M','A','M','J','J','A','S','O','N','D']

 xyouts, jday_mon, -8, xlabel, color=1, alignment=0.5, charsize=charsize

 dy = (yrange[1]-yrange[0])*0.05
 xyouts, 0, yrange[1]+dy, 'IMPROVE', color=1, charsize=charsize, $
 charthick=charthick, alignment=0.
 str = 'STDDEV '+std+'!CSTDDEV(DAY) '+std_d+'!CSTDDEV(MON) '+std_m
 xyouts, 365, yrange[1]+5*dy, str, color=1, charsize=charsize, $
 charthick=charthick, alignment=1
 
; MODEL plot
; m = composite(sim_d)
; anom=anomal( m.mean, jday=jday, mean=avg )
 m = anom_composite(sim_d, jday=jday)

; print, stddev(avg),    ' std for month'
; print, stddev(anom),   ' std for day'
; print, stddev(m.mean), ' std'

 std_m = string(m.std_m,format=format)
 std_d = string(m.std_d,format=format)
 std   = string(m.std,format=format)

 plot,  jday, m.data, color=1, position=position[*,1], thick=thick, $
    xstyle=1, yrange=yrange, xrange=xrange, xticks=xticks, $
    xtickformat='(i3)', xcharsize=charsize, ycharsize=charsize, $
    xtitle='Julian day', charthick=charthick
; for d = 0, n_elements(jday)-1 do $
;     oplot, [jday[d],jday[d]], [m.mean[d]-m.std[d], m.mean[d]+m.std[d]], $
;          color=12, thick=thin
; oplot, jday, m.mean, color=1, thick=thick

 oplot,  jday, m.anom, color=11, thick=dthin
 oplot,  jday_mon, m.mean, color=4, thick=dthick, psym=-2

 xyouts, jday_mon, -8, xlabel, color=1, alignment=0.5, charsize=charsize

 xyouts, 0, yrange[1]+dy, 'GEOS-CHEM', color=1, charsize=charsize, $
 charthick=charthick, alignment=0.
 str = 'STDDEV '+std+'!CSTDDEV(DAY) '+std_d+'!CSTDDEV(MON) '+std_m
 xyouts, 365, yrange[1]+5*dy, str, color=1, charsize=charsize, $
 charthick=charthick, alignment=1.

 corr = string(correlate(o.data,m.data),format='(F4.2)')
 str = 'CORR = '+corr
 xyouts, 1, yrange[1]+5*dy, str, color=1, charsize=charsize, $
 charthick=charthick, alignment=0.

 print, correlate(o.data,m.data)

 return

 end


;========================================================================

 if n_elements(obs) eq 0 then begin
    sim    = get_model_day_improve(res=1)
    bkg    = get_model_day_improve(res=11)
    obs    = get_improve_dayly()
    newsim = syncro( sim, obs )
    newbkg = syncro( bkg, obs )
    id     = group( obs )
 endif

  @ctl

  comment = 'Western site (<95W),!C!C #1, Mean<9, STD<3.5'
  comment = 'Estern site(>95W), !C!C #3, Mean<18, STD>5'
;  comment = 'Western site (<95W)'
  figfile = SPEC+'_'+'E_vis_time_1x1.ps'


  newpos = fltarr(4,4)
  newpos[*,0:1] = pos[*,0:1]
  newpos[*,2:3] = pos[*,3:4]

  map_dist, obs(mapid), newbkg(mapid), pos=newpos

  position = pos[*,2]
  dx = 0.04
  dy = 0.0
  dxx= 0.13
  position = [position[0]+dx,position[1]-dy,position[2]+dxx,position[3]-dy]

  newpos = fltarr(4,2)
  newpos[*,0] = position

  position = pos[*,5]
  dx = 0.04
  dy = 0.0
  position = [position[0]+dx,position[1]-dy,position[2]+dxx,position[3]-dy]
  newpos[*,1] = position

  deciview=1
  tseries, obs=obs(mapid), sim=newbkg(mapid), bkg=newbkg(mapid), $
     deciview=deciview, position=newpos, maxD=maxD

;  xyouts, 0.66, 0.4, comment, color=1, alignment=0., /normal, $
;    charsize=charsize, charthick=charthick

 if !D.name eq 'PS' then close_device

End
