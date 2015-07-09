function julian,yymmdd

;yymmdd: String array containing dates in yymmdd format. (Y2k compatible)

nobs = size(yymmdd) & nobs = nobs(1)

slen = strlen(yymmdd) 

days = lonarr(13,2) 
days(0,0) = [0,31,29,31,30,31,30,31,31,30,31,30,31] 
days(0,1) = [0,31,28,31,30,31,30,31,31,30,31,30,31]

syr = strarr(nobs) & smon = syr & sday = syr 
for i=0l,nobs-1 do begin
   case slen(i) of 
   6: begin  
      syr(i)  = long(strmid(yymmdd(i),0,2))
      smon(i) = long(strmid(yymmdd(i),2,2))
      sday(i) = long(strmid(yymmdd(i),4,2))
      end
   8: begin  
      syr(i)  = long(strmid(yymmdd(i),0,4))
      smon(i) = long(strmid(yymmdd(i),4,2))
      sday(i) = long(strmid(yymmdd(i),6,2))
      end
   else:
   endcase
endfor 
syr_index = 1 < (syr mod 4) 

jday = lonarr(nobs) 
for i=0l,nobs-1 do jday(i) = total(days(0:smon(i)-1,syr_index(i))) + sday(i) 

return,jday
end 


