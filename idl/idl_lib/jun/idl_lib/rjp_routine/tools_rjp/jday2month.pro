;------------------------------------------------------------------

 function jday2month, jday, base=base

 if N_elements(base) eq 0 then base = 20010101L

 tau0 = nymd2tau(base) ; base year 2001
 jhour= (jday-1L)*24L + tau0[0]
 date = tau2yymmdd(jhour)
 return, reform(date.month)

 end
