 function nan_chk, obs, sim

   i = where(obs gt 0.)

   return, {obs:obs[i], sim:sim[i]}

 end
