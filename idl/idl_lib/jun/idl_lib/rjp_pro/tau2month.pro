;------------------------------------------------------------------

 function tau2month, jday

 tau0 = nymd2tau(20010101L) ; base year 2001
 jhour= (jday-1L)*24L + tau0[0]
 date = tau2yymmdd(jhour)
 return, reform(date.month)

 end
