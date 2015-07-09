

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
       mean[*,d] = avg

       samp      = chk_undefined(data[*,d])     ; monthly mean
       if n_elements(samp) gt 1 then  std[d] = stddev(samp) else  std[d] = 'NaN'

       samp      = chk_undefined(anom[*,d])     ; monthly mean
       if n_elements(samp) gt 1 then  astd[d] = stddev(samp) else astd[d] = 'NaN'

       samp      = chk_undefined(mean[*,d])     ; monthly mean
       if n_elements(samp) gt 1 then  mstd[d] = stddev(samp) else mstd[d] = 'NaN'
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
           std:mean(std,/NaN),std_m:mean(mstd,/NaN),std_d:mean(astd,/NaN)}
 end

;============================================================================

 pro tseries, obs=obs, sim=sim, bkg=bkg, $
     deciview=deciview, position=position

  COMMON SHARE, SPEC, MAXD, MAXP

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
 yrange=[0.,maxD]
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
        charthick=charthick, ystyle=1
 
; for d = 0, n_elements(jday)-1 do $
;     oplot, [jday[d],jday[d]], [o.mean[d]-o.std[d], o.mean[d]+o.std[d]], $
;     color=12, thick=thin

; oplot, jday, o.mean, color=1, thick=thick

; oplot, jday,     o.anom, color=11, thick=dthin
 oplot, jday_mon, o.mean, color=4, thick=dthick, psym=-2

 xlabel=['J','F','M','A','M','J','J','A','S','O','N','D']

 dy = (yrange[1]-yrange[0])*0.05
 xyouts, jday_mon, yrange[0]+dy, xlabel, color=1, alignment=0.5, $
  charsize=charsize, charthick=charthick

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
    xtitle='Julian day', charthick=charthick, ystyle=1
; for d = 0, n_elements(jday)-1 do $
;     oplot, [jday[d],jday[d]], [m.mean[d]-m.std[d], m.mean[d]+m.std[d]], $
;          color=12, thick=thin
; oplot, jday, m.mean, color=1, thick=thick

; oplot,  jday, m.anom, color=11, thick=dthin
 oplot,  jday_mon, m.mean, color=4, thick=dthick, psym=-2

 xyouts, jday_mon, yrange[0]+dy, xlabel, color=1, alignment=0.5, $
 charsize=charsize, charthick=charthick

 xyouts, 0, yrange[1]+dy, 'GEOS-CHEM', color=1, charsize=charsize, $
 charthick=charthick, alignment=0.

 str = 'STDDEV '+std+'!CSTDDEV(DAY) '+std_d+'!CSTDDEV(MON) '+std_m
 xyouts, 365, yrange[1]+5*dy, str, color=1, charsize=charsize, $
 charthick=charthick, alignment=1.

 corr = string(correlate(o.data,m.data),format='(F4.2)')
 str = 'R = '+corr
 xyouts, 1, yrange[1]+5*dy, str, color=1, charsize=charsize, $
 charthick=charthick, alignment=0.

 print, correlate(o.data,m.data)

 return

 end


;========================================================================

  @ctl

;  comment = 'Western site (<95W),!C!C #1, Mean<9, STD<3.5'
;  comment = 'Estern site(>95W), !C!C #3, Mean<18, STD>5'
;  comment = 'Western site (<95W)'
;  figfile = SPEC+'_'+'E_vis_time_1x1.ps'


  newpos = fltarr(4,4)
  newpos[*,0:1] = pos[*,0:1]
  newpos[*,2:3] = pos[*,3:4]

  map_dist, newobs(mapid), newsim(mapid), pos=newpos

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
  tseries, obs=newobs(mapid), sim=newsim(mapid), bkg=newbkg(mapid), $
     deciview=deciview, position=newpos

;  xyouts, 0.66, 0.4, comment, color=1, alignment=0., /normal, $
;    charsize=charsize, charthick=charthick

 if !D.name eq 'PS' then close_device

End
