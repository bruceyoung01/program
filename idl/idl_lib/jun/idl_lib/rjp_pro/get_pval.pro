
 function get_pval, obs=obs, sim=sim, baseline=baseline

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

     if keyword_set(baseline) then begin
       ; use EPA default soil and cm ext 
;       ext = 3.*frh*(obs[D].so4*1.375+obs[D].no3*1.29) $
;           + obs[D].omc*4. + obs[D].ec*10. + 10. + 0.5 + 1.8 ;+ soil_bext + cm_bext

       ; use IMPROVE obs for soil and cm
       ext = 3.*frh*(obs[D].so4*1.375+obs[D].no3*1.29) $
           + obs[D].omc*4. + obs[D].ec*10. + 10. + soil_bext + cm_bext
     end else begin
       ; use EPA default soil and cm ext 
;       ext = 3.*frh*(sim[D].so4*1.375+sim[D].nit*1.29) $
;           + sim[D].omc*4. + sim[D].ec*10. + 10. + 0.5 + 1.8 ;+ soil_bext + cm_bext

       ; use IMPROVE obs for soil and cm
       ext = 3.*frh*(sim[D].so4*1.375+sim[D].nit*1.29) $
           + sim[D].omc*4. + sim[D].ec*10. + 10. + soil_bext + cm_bext
     end

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
