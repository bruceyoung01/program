 function group, obs, id=id

   tag = tag_names(obs[0])
   ntg = n_tags(obs[0])

   ; Light extinction from IMPROVE obs
   ammso4_bext = make_zero(obs.ammso4_bext, val='NaN')
   ammno3_bext = make_zero(obs.ammno3_bext, val='NaN')
   ec_bext     = make_zero(obs.ec_bext,     val='NaN')
   omc_bext    = make_zero(obs.omc_bext,    val='NaN')
   soil_bext   = make_zero(obs.soil_bext,   val='NaN')
   cm_bext     = make_zero(obs.cm_bext,     val='NaN')

;   ext = ammso4_bext+ammno3_bext+ec_bext+omc_bext+soil_bext+cm_bext+10.
   ext = ammso4_bext+ammno3_bext+ec_bext+omc_bext+10.

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
     epa_p10 = epa_avg - (1.28 * sd)
     epa_p90 = epa_avg + (1.28 * sd)
      
     ; mean and stddev and EPA default values
     a_str = create_struct('ID', D, 'MEAN',avg[D], 'STD',std[D],  $ 
                           'EPA_AVG', epa_avg, 'EPA_p10', epa_p10,$
                           'EPA_p90', epa_p90) 

     info = obs[D]
     for n = 0, ntg-1 do begin
         d1    = info.(N)
         a_str = create_struct(a_str, tag[N], d1)
     end

     if D eq 0 then fld = a_str else fld = [fld, a_str]

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

   newobs = fld
   undefine, fld

   ID = {W:W, E:E, W1:W1, W2:W2, W3:W3, W4:W4, E1:E1, E2:E2, E3:E3, E4:E4}

   return, newobs

 end
