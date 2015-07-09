
 function obs_pval, obs=obs, sim=sim

   tag = tag_names(sim[0])
   ntg = n_tags(sim[0])

   ; 10th and 90th quantile as averages of best and worst 20%
   s_p10 = fltarr(N_elements(sim.siteid))
   s_p90 = s_p10

   ; average over best and worst 20% values
   s_a20 = s_p10
   s_a80 = s_p10

   For D = 0, N_elements(sim.siteid)-1L do begin
       soil_bext = make_zero(obs[D].soil_bext,   val='NaN')
       cm_bext   = make_zero(obs[D].cm_bext,     val='NaN')

     ; calculate annual frh following the RHR recommendation
       frh = mean(make_zero(obs[D].frhgrid,val='NaN'),/NaN) ; annual frh
;       frh = make_zero(sim[D].frho,val='NaN')

       ; use EPA default soil and cm ext 
       ext = 3.*frh*(sim[D].so4*1.375+sim[D].no3*1.29) $
           + sim[D].omc*4. + sim[D].ec*10. + 10. + 0.5 + 1.8 ;+ soil_bext + cm_bext

       vis = 10. * Alog( ext / 10. )
       vis = chk_undefined(vis)

       if n_elements(vis) gt 80. and $  ; number of data availabel 2/3 of year
          obs[D].lat      gt 20.  then begin   
          out = quantile(vis, [0.1,0.2,0.8,0.9]) 
          s_p10[D] = out[0]
          s_p90[D] = out[3]

          dat = vis[sort(vis)]
          p1  = where(dat le out[1])  ; best 20%
          p2  = where(dat ge out[2])  ; worst 20%
          s_a20[D] = mean(dat[p1])
          s_a80[D] = mean(dat[p2])

;          print, dat, '****'
;          print, dat[p1], '*****'
;          print, dat[p2], '*****'
;          print, s_a80[D], s_p90[D]
;          if D eq 10 then stop

       end else begin
          s_p10[D] = 'NaN'
          s_p90[D] = 'NaN'
          s_a20[D] = 'NaN'
          s_a80[D] = 'NaN'
       end

     ; mean and stddev and EPA default values
     a_str = create_struct('p10', s_p10[D], 'p90', s_p90[D], $
                           'a20', s_a20[D], 'a80', s_a80[D] ) 

     info = sim[D]
     for n = 0, ntg-1 do begin
         d1    = info.(N)
         a_str = create_struct(a_str, tag[N], d1)
     end

     if D eq 0 then fld = a_str else fld = [fld, a_str]

   end

   return, fld

 end

;============================================================================

 pro showme, obs=obs, bkg=bkg, nat=nat, pos=pos, cbposition=cbposition

    @define_plot_size

    min=3.
    max=30.
    cformat = '(I3)'

    print, mean(obs.epa_p90,/nan)
    print, mean(bkg.p90,/nan)
    
    idw = where(obs.lon le -95.)
    ide = where(obs.lon gt -95.) 

   ;1)
    data = obs.a80
    title= 'Baseline (IMPROVE)'
    map_plot, data, lon=obs.lon, lat=obs.lat, position=pos[*,0], $
        min=min, max=max


    x = pos[0,0]
    y = pos[3,0]+0.01
    str = string(mean(data[idw],/nan),format='(f4.1)')
;    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=0, $
;    charthick=charthick

    x = pos[2,0]
    y = pos[3,0]+0.01
    str = string(mean(data[ide],/nan),format='(f4.1)')
;    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=1, $
;    charthick=charthick

    x = (pos[0,0]+pos[2,0])*0.5
    xyouts, x, y, title, color=1, charsize=charsize, charthick=charthick, $
    /normal, alignment=0.5

   ;2)
    data = nat.a80
    title= 'Natural'
    map_plot, data, lon=obs.lon, lat=obs.lat, position=pos[*,1], $
        min=min, max=max, /nogylabel

    x = pos[0,1]
    y = pos[3,0]+0.01
    str = string(mean(data(idw),/nan),format='(f4.1)')
;    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=0, $
;    charthick=charthick

    x = pos[2,1]
    y = pos[3,0]+0.01
    str = string(mean(data(ide),/nan),format='(f4.1)')
;    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=1, $
;    charthick=charthick

    x = (pos[0,1]+pos[2,1])*0.5
    xyouts, x, y, title, color=1, charsize=charsize, charthick=charthick, $
    /normal, alignment=0.5

    ;3)
    data = bkg.a80
    title= 'Background'
    map_plot, data, lon=obs.lon, lat=obs.lat, position=pos[*,2],    $
        min=min, max=max, /nogylabel, /cbar, cbposition=cbposition, $
        ndiv=5, cformat=cformat

    x = pos[0,2]
    y = pos[3,0]+0.01
    str = string(mean(data[idw],/nan),format='(f4.1)')
;    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=0, $
;    charthick=charthick

    x = pos[2,2]
    y = pos[3,0]+0.01
    str = string(mean(data[ide],/nan),format='(f4.1)')
;    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=1, $
;    charthick=charthick

    x = (pos[0,2]+pos[2,2])*0.5
    xyouts, x, y, title, color=1, charsize=charsize, charthick=charthick, $
    /normal, alignment=0.5

    return

    ;4)
    min=0.
    max=1.5

    data = bkg.a80-obs.epa_p90
    map_plot, data, lon=obs.lon, lat=obs.lat, position=pos[*,3], $
        min=min, max=max
    x = pos[0,3]
    y = pos[3,3]+0.01
    str = string(mean(data,/nan),format='(f4.1)')
;    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=0, $
;    charthick=charthick

    ;5)
    ; difference between worst 20 and p90
    data = bkg.a80-bkg.p90
    map_plot, data, lon=obs.lon, lat=obs.lat, position=pos[*,4], $
        min=min, max=max, /nogylabel
    x = pos[0,4]
    y = pos[3,3]+0.01
    str = string(mean(data,/nan),format='(f4.1)')
;    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=0, $
;    charthick=charthick

    ;6)
    data = nat.a80-nat.p90
    map_plot, data, lon=obs.lon, lat=obs.lat, position=pos[*,5], $
        min=min, max=max, /nogylabel, /cbar, cbposition=[0.2,0.08,0.8,0.11]
    x = pos[0,5]
    y = pos[3,3]+0.01
    str = string(mean(data,/nan),format='(f4.1)')
    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

    min=1.
    max=5.

;    map_plot, obs.epa_p10, lon=obs.lon, lat=obs.lat, position=pos[*,3], $
;        min=min, max=max

;    map_plot, bkg.p10, lon=obs.lon, lat=obs.lat, position=pos[*,4], $
;        min=min, max=max, /nogylabel

;    map_plot, nat.p10, lon=obs.lon, lat=obs.lat, position=pos[*,5], $
;        min=min, max=max, /nogylabel, /cbar, cbposition=[0.2,0.08,0.8,0.11]

 end

;============================================================================

 @ctl
 erase

 if n_elements(pbkg) eq 0 then begin
    pobs = obs_pval(obs=newobs, sim=newobs)
    pcur = get_pval(obs=newobs, sim=newsim)
    pbkg = get_pval(obs=newobs, sim=newbkg)
    pnat = get_pval(obs=newobs, sim=newnat)
    pbkg1 = get_pval(obs=newobs, sim=newbkg1)
    pnat1 = get_pval(obs=newobs, sim=newnat1)
 endif

  @define_plot_size


  !P.multi=[0,3,2,0,0]
  Pos = cposition(3,2,xoffset=[0.07,0.05],yoffset=[0.15,0.15], $
        xgap=0.01,ygap=0.16,order=0)

  if !D.name eq 'PS' then $
    open_device, file='p90_obs_nat_bkg.ps', /color, /ps, /landscape

  ; W1 (clean but high variability)
  idw = where(newobs.lon lt -95. and newobs.lat gt 40. and newobs.std gt 3. and newobs.mean gt 8.)
  ide = where(newobs.lon gt -95. and newobs.lat gt 35. and newobs.std gt 5. and newobs.mean gt 18.)
  showme, obs=pobs, bkg=pbkg, nat=pnat, pos=pos[*,0:2],  cbposition=[0.2,0.51,0.8,0.54]
;  showme, obs=newobs, bkg=pbkg1, nat=pnat1, pos=pos[*,3:5],cbposition=[0.2,0.08,0.8,0.11]

  if !D.name eq 'PS' then close_device

 End
