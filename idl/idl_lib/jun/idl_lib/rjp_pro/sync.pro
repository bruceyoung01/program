 function sync, obs, sim

   for D = 0, n_elements(sim)-1 do begin
       P = where(sim[D].siteid eq obs.siteid)

       if P[0] ne -1 then begin
          if n_elements(newdata) eq 0 then $
             newdata = sim(D) else $
             newdata = [newdata, sim(D)]
       end
   end

   return, newdata
 end
