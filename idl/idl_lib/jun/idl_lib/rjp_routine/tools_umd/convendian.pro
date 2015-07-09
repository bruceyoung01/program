pro convendian, file, dim=dim, cord=cord

if n_elements(file) eq 0 then return
if n_elements(dim)  eq 0 then return
if n_elements(cord) eq 0 then cord = 1

ndim = n_elements(dim)
check, dim
case ndim of 
1:  data = fltarr(dim(0))
2:  data = fltarr(dim(0),dim(1))
3:  data = fltarr(dim(0),dim(1),dim(2))
else: return
endcase

openr,ilun,file,/xdr,/get
openw,jlun,file+'b',/f77,/swap_endian,/get

if cord eq 1 then begin
 lon = fltarr(dim(0)) & lat = fltarr(dim(1))
 readu,ilun,lon,lat
 check, lon
 check, lat
 writeu,jlun,lon,lat
end

i = 0
while (not eof(ilun)) do begin
i = i+1
 readu,ilun,data
 print, i
 check, data
writeu,jlun,data
end

free_lun,ilun
free_lun,jlun

end

 

