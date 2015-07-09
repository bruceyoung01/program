;------------------------------------------------------------------

 function tau2month, tau, base=base

 if N_elements(base) eq 0 then base = 20010101L

 D    = where(tau lt 0.)
 date = tau2yymmdd(tau)
 date.month[D] = -999.
 return, reform(date.month)

 end
