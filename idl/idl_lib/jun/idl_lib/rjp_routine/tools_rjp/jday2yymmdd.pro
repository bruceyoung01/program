;------------------------------------------------------------------

 function jday2yymmdd, jday, base=base

 if N_elements(base) eq 0 then base = 20010101L

 tau0 = nymd2tau(base) ; base year 2001
 jhour= (jday-1L)*24L + tau0[0]
 date = tau2yymmdd(jhour)
 yyyy = strtrim(string(date.year,format='(I4)'),2)
 mm   = strtrim(string(date.month,format='(I2)'),2)
 dd   = strtrim(string(date.day,format='(I2)'),2)

 if strlen(mm) eq 1 then mm = '0'+mm
 if strlen(dd) eq 0 then dd = '0'+dd

 return, yyyy+'/'+mm+'/'+dd

 end
