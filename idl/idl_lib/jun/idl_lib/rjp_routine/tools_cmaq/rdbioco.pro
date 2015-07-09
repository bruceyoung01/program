function rdbioco, tco=tco, ratio=ratio, file=file

if n_elements(file) eq 0 then file = $
 '/data/eos3/stone/data/biomass/biomassco.dat_mbair_14491_12rec'

co  = fltarr(144,91,12) & ratio = co
dat = fltarr(144,91) & tco = dat

tvar = fltarr(360,180,12)

openr,il,file,/f77_unformatted,/get_lun

mcor = setmcor()
mcor = mcor*1.e15

for i = 0 , 11 do begin
readu,il, dat
dat = (86400.*365.24/12.)*dat*mcor*28.*1.e5/(9.8*28.97) ; convert hpa air/s into g co/mon
co(*,*,i) = dat
end
 tco = total(co,3)

for i = 0 , 143 do begin
for j = 0 , 90  do begin
 if tco(i,j) eq 0 then tco(i,j) = 1.
end
end

xout = -179.5 + findgen(360)
yout = -89.5  + findgen(180)
xin  = -180   + findgen(144)*2.5
yin  = -90    + findgen(91)*2.0

for i = 0 , 11 do begin
ratio(*,*,i) = co(*,*,i)/tco
dataout = interp2d(ratio(*,*,i),xout,yout,xin,yin,badval=badval)
tvar(*,*,i) = dataout
end

tsum = total(tvar,3)

for i = 0 , 359 do begin
for j = 0 , 179  do begin
 if tsum(i,j) eq 0. then begin
    tsum(i,j) = 1.
    tvar(i,j,*) = 1./12.
 end
end
end

for i = 0 , 11 do begin
tvar(*,*,i) = tvar(*,*,i)*1.0/tsum
end

free_lun,il

return, tvar
end
