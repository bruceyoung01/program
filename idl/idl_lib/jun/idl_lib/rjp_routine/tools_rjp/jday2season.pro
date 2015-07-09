;------------------------------------------------------------------

 function jday2season, jday

 tau0 = nymd2tau(20010101L) ; base year 2001
 jhour= (jday-1L)*24L + tau0[0]
 date = tau2yymmdd(jhour)

 L = (date.month / 3L) mod 4L
   
 return, (reform(date.month)/3L mod 4L)

 end
