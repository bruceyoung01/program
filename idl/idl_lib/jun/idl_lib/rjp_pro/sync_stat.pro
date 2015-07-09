 function sync_stat, str, obsfld, simfld

  Lat = 0.
  Lon = 0.
  v_avg = 0.
  v_std = 0.

  m_avg = 0.
  m_std = 0.

  For D = 0, N_elements(str.siteid)-1 do begin
;     data = chk_undefined(reform(fld[*,D]))

      data = reform(obsfld[*,D])

;      id   = where(data gt 0.)
;      mon  = tau2month(str[D].jday[id])
;      nuq  = uniq(mon)
;      if n_elements(nuq) lt 12 then goto, jump

;      For n = 1L, 12L do begin
;         nm = where(mon eq n)
;         if n_elements(nm) lt 5 then goto, jump
;      end

      data = chk_undefined(reform(obsfld[*,D]))
      conc = chk_undefined(reform(simfld[*,D]))

      if data[0]          ne -1   and $
         n_elements(data) gt 80.  and $
         str[D].lat       gt 20.  then begin

         v_avg  = [v_avg, Mean(Data)  ]  ; annual mean
         v_std  = [v_std, STDDEV(Data)]  ; daily std

         m_avg  = [m_avg, Mean(conc)  ]  ; annual mean model
         m_std  = [m_std, stddev(conc)]  ; std model

         lat    = [lat,   str[d].lat]
         lon    = [lon,   str[d].lon]   
      end

     jump:
  End

  obs_avg = v_avg[1:*]
  obs_std = v_std[1:*]
  mod_avg = m_avg[1:*]
  mod_std = m_std[1:*]

  obs_lat = lat[1:*]
  obs_lon = lon[1:*]

  return, {obs_avg:obs_avg, obs_std:obs_std, $
           sim_avg:mod_avg, sim_std:mod_std, $
           lat:obs_lat, lon:obs_lon }

 end
