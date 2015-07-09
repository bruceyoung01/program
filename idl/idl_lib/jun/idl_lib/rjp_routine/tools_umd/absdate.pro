function absdate,datets  

yy = long(datets) / 10000 
frac = datets - long(datets)
mm = long(datets - yy*10000) / 100 
 
dd = long(datets - yy*10000)
dd = dd - 100 * (dd/100)
dd = dd - 1 

vv = size(datets) & nobs = vv(1)
absdatets = dblarr(nobs) 

for iobs = 0,nobs-1 do begin 
   case yy(iobs) of 
   85: d0 = 2497 
   86: d0 = 2497 + 365 
   87: d0 = 2497 + 365*2 
   88: d0 = 2497 + 365*3
   89: d0 = 2497 + 365*4 + 1 
   90: d0 = 2497 + 365*5 + 1 
   91: d0 = 2497 + 365*6 + 1
   92: d0 = 2497 + 365*7 + 1
   93: d0 = 2497 + 365*8 + 2 
   94: d0 = 2497 + 365*9 + 2 
   95: d0 = 2497 + 365*10+ 2
   96: d0 = 2497 + 365*11+ 2
   97: d0 = 2497 + 365*12+ 3
   98: d0 = 2497 + 365*13+ 3
   99: d0 = 2497 + 365*14+ 3
    0: d0 = 2497 + 365*15+ 3
   else: print,'Please double check year', yy(iobs)
   endcase 
   
   case mm(iobs) of 
    1: m0 = 0 
    2: m0 = 31 
    3: m0 = 59 
    4: m0 = 90 
    5: m0 = 120
    6: m0 = 151
    7: m0 = 181
    8: m0 = 212
    9: m0 = 243 
   10: m0 = 273 
   11: m0 = 304 
   12: m0 = 334 
   else:
   endcase 
   
   if (mm(iobs) gt 2) and (yy(iobs) eq 88) then m0 = m0 + 1
   if (mm(iobs) gt 2) and (yy(iobs) eq 92) then m0 = m0 + 1 
   if (mm(iobs) gt 2) and (yy(iobs) eq 96) then m0 = m0 + 1 
   if (mm(iobs) gt 2) and (yy(iobs) eq  0) then m0 = m0 + 1 
  
   absdatets(iobs) = d0 + m0 + dd(iobs) + frac(iobs) 
endfor

return,absdatets 
end 
   
    
   
   
