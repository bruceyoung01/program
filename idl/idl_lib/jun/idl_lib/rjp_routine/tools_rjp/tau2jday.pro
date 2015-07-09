;------------------------------------------------------------------

 function tau2jday, tau, base=base

 if N_elements(base) eq 0 then base = 20010101L

 tau0 = nymd2tau(base)
 D    = where(tau lt 0.)
 jday = fix(tau - tau0[0])/24L + 1L

 if D[0] ne -1 then jday[D] = -999.
 return, reform(jday)

 end
