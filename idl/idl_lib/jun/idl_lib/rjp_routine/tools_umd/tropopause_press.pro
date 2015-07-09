pro tropopause_press,yymm=yymm

if n_elements(yymm) eq 0 then yymm = '9707' 
iyr = long(strmid(yymm,0,2)) 
imon = long(strmid(yymm,2,2)) -1 

ndays = [31,28,31,30,31,30,31,31,30,31,30,31] 
ndays2 = [3,0,3,2,3,2,3,3,2,3,2,3] 
ihr = [0,6,12,18]
aa = iyr mod 4 
if (aa eq 0) then ndays(1) = 29
if (aa eq 0) then ndays2(1) = 1 

yymmdd = long(yymm)*100 + indgen(ndays(imon)) +1
syymmdd = strtrim(yymmdd,2)   

hd = fltarr(3) & hd(0) = 55.
dd = '~allen/tropopause/'
dsn = strarr(4) 
for i=0,2 do dsn(i) = 'stratf.b'+syymmdd(i*7)+'.e'+syymmdd((i+1)*7-1)+'.trpps_xdr'
i = 3 & dsn(i) = 'stratf.b'+syymmdd(i*7)+'.e'+syymmdd((i+1)*7-1+ndays2(imon))+'.trpps_xdr'

ndayswk = [7,7,7,7+ndays2(imon)] 

iday = -1  
for iweek=0,3 do begin 
   openw,ilun,dd+dsn(iweek),/xdr,/get_lun  
   for i=0,ndayswk(iweek)-1 do begin
   iday = iday + 1
   for iobs=0,3 do begin
      tropopause,yymmdd(iday),ihr(iobs),'stratf',trpps,lon=lon,lat=lat,badval=badval
      hd(1) = yymmdd(iday)
      hd(2) = ihr(iobs)*10000.
      writeu,ilun,hd,trpps 
   endfor
   endfor 
   free_lun,ilun
endfor 

return
end 
