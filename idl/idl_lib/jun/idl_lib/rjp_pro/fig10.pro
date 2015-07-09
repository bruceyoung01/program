 function epa_default, obs

   tag = tag_names(obs[0])
   ntg = n_tags(obs[0])

   ; Light extinction from IMPROVE obs
   ammso4_bext = make_zero(obs.ammso4_bext, val='NaN')
   ammno3_bext = make_zero(obs.ammno3_bext, val='NaN')
   ec_bext     = make_zero(obs.ec_bext,     val='NaN')
   omc_bext    = make_zero(obs.omc_bext,    val='NaN')
   soil_bext   = make_zero(obs.soil_bext,   val='NaN')
   cm_bext     = make_zero(obs.cm_bext,     val='NaN')

   ext = ammso4_bext+ammno3_bext+ec_bext+omc_bext+soil_bext+cm_bext+10.
;   ext = ammso4_bext+ammno3_bext+ec_bext+omc_bext+10.

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

     ; calculate default natural values using EPA method 
     frh = mean(make_zero(obs[D].frhgrid,val='NaN'),/NaN) ; annual frh
     if obs[D].lon le -95. then begin ; west
        bext = 3.*frh*0.21 + 4.*0.47 + 10.*0.02 + 0.5 + 1.8 + 10.
        sd   = 2.
     end else begin  ; east
        bext = 3.*frh*0.33 + 4.*1.4  + 10.*0.02 + 0.5 + 1.8 + 10.
        sd   = 3.
     end

     epa_avg = 10.*alog(bext/10.)  ; EPA default mean natural visibilty
     epa_p8  = epa_avg - (1.42 * sd)
     epa_p92 = epa_avg + (1.42 * sd)
      
     ; mean and stddev and EPA default values
     a_str = create_struct('ID', D, 'MEAN',avg[D], 'STD',std[D],  $ 
                           'EPA_AVG', epa_avg, 'EPA_p8', epa_p8,$
                           'EPA_p92', epa_p92) 

     info = obs[D]
     for n = 0, ntg-1 do begin
         d1    = info.(N)
         a_str = create_struct(a_str, tag[N], d1)
     end

     if D eq 0 then fld = a_str else fld = [fld, a_str]

  End

   newobs = fld
   undefine, fld

   return, newobs

 end

;========================================================================

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

    min=4.
    max=16.
    cformat = '(I3)'

    print, mean(obs.epa_p92,/nan)
;    print, mean(bkg.p90,/nan)
    
    idw = where(obs.lon le -95.)
    ide = where(obs.lon gt -95.) 
    id  = where(obs.lat gt 25.)
    charsize = 1.1
   ;1)
    data = obs.epa_p92
    title= 'EPA default'
    map_plot, data[id], lon=obs[id].lon, lat=obs[id].lat, position=pos[*,0], $
        min=min, max=max


    x = pos[0,0]
    y = pos[3,0]+0.01
    str = string(mean(data[idw],/nan),format='(f4.1)')
    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

    x = pos[2,0]
    y = pos[3,0]+0.01
    str = string(mean(data[ide],/nan),format='(f4.1)')
    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=1, $
    charthick=charthick

    x = (pos[0,0]+pos[2,0])*0.5
    xyouts, x, y, title, color=1, charsize=charsize, charthick=charthick, $
    /normal, alignment=0.5

   ;2)
    id   = where( finite(nat.a80) eq 1 )
    data = nat.a80
    title= 'Natural (this work)'
    map_plot, data[id], lon=obs[id].lon, lat=obs[id].lat, position=pos[*,1], $
        min=min, max=max, /nogylabel

    x = pos[0,1]
    y = pos[3,0]+0.01
    str = string(mean(data(idw),/nan),format='(f4.1)')
    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

    x = pos[2,1]
    y = pos[3,0]+0.01
    str = string(mean(data(ide),/nan),format='(f4.1)')
    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=1, $
    charthick=charthick

    x = (pos[0,1]+pos[2,1])*0.5
    xyouts, x, y, title, color=1, charsize=charsize, charthick=charthick, $
    /normal, alignment=0.5

    ;3)
    id   = where( finite(bkg.a80) eq 1 )
    data = bkg.a80
    title= 'Background (this work)'
    map_plot, data[id], lon=obs[id].lon, lat=obs[id].lat, position=pos[*,2],    $
        min=min, max=max, /nogylabel, /cbar, cbposition=cbposition, $
        ndiv=5, cformat=cformat

    x = pos[0,2]
    y = pos[3,0]+0.01
    str = string(mean(data[idw],/nan),format='(f4.1)')
    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

    x = pos[2,2]
    y = pos[3,0]+0.01
    str = string(mean(data[ide],/nan),format='(f4.1)')
    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=1, $
    charthick=charthick

    x = (pos[0,2]+pos[2,2])*0.5
    xyouts, x, y, title, color=1, charsize=charsize, charthick=charthick, $
    /normal, alignment=0.5

    xyouts, x+0.02, 0.5, '[dv]', /normal, color=1, charsize=charsize, charthick=charthick
    return

    ;4)
;    min=0.
;    max=1.5
;
;    data = bkg.a80-obs.epa_p90
;    map_plot, data, lon=obs.lon, lat=obs.lat, position=pos[*,3], $
;        min=min, max=max
;    x = pos[0,3]
;    y = pos[3,3]+0.01
;    str = string(mean(data,/nan),format='(f4.1)')
;    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=0, $
;    charthick=charthick

;    ;5)
;    ; difference between worst 20 and p90
;    data = bkg.a80-bkg.p90
;    map_plot, data, lon=obs.lon, lat=obs.lat, position=pos[*,4], $
;        min=min, max=max, /nogylabel
;    x = pos[0,4]
;    y = pos[3,3]+0.01
;    str = string(mean(data,/nan),format='(f4.1)')
;    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=0, $
;    charthick=charthick

;    ;6)
;    data = nat.a80-nat.p90
;    map_plot, data, lon=obs.lon, lat=obs.lat, position=pos[*,5], $
;        min=min, max=max, /nogylabel, /cbar, cbposition=[0.2,0.08,0.8,0.11]
;    x = pos[0,5]
;    y = pos[3,3]+0.01
;    str = string(mean(data,/nan),format='(f4.1)')
;    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=0, $
;    charthick=charthick


 end

;============================================================================

 @ctl
 erase

 if n_elements(pbkg) eq 0 then begin
    aobs = epa_default( obs )
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
    open_device, file='fig10_p10_p90.ps', /color, /ps, /landscape

  showme, obs=aobs, bkg=pbkg1, nat=pnat1, pos=pos[*,0:2], cbposition=[0.2,0.51,0.8,0.54] 
;  showme, obs=newobs, bkg=pbkg,  nat=pnat,  pos=pos[*,3:5], cbposition=[0.2,0.08,0.8,0.11]

  if !D.name eq 'PS' then close_device

 End
