function cmass, file, gas, time=time, mdiff=mdiff, burden=burden

if n_elements(file) eq 0 then file = pickfile()
if n_elements(time) eq 0 then time = 732
ispec = spec(gas,ncon=52)

openr,il,file,/xdr,/get

burden = fltarr(time) & dat = fltarr(52)
data = fltarr(52,5)
mdiff = fltarr(time-1,5) & tser = fltarr(time,5)

for i = 0 , time-1 do begin
readu, il, dat , data
tser(i,*) = data(ispec,*)
burden(i) = dat(ispec)
print, i
end

for j = 0 , 3 do begin
a = tser(*,j)
b = shift(a,-1)
c = b-a
mdiff(*,j) = [a(0),c(0:time-3)]
end

free_lun,il
return, tser
end

