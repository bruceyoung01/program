pro plotburden,out=out,mon=mon,gas=gas,graph=graph

if n_elements(out) eq 0 then return
if n_elements(mon) eq 0 then return
if n_elements(gas) eq 0 then return
if n_elements(graph) eq 0 then graph = 'x'

s = size(out)
nspec = s(2)
corr = fltarr(nspec)

case mon of
1 : cap = ' [JAN]'
2 : cap = ' [FEB]'
3 : cap = ' [MAR]'
4 : cap = ' [APR]'
5 : cap = ' [MAY]'
6 : cap = ' [JUN]'
7 : cap = ' [JUL]'
8 : cap = ' [AUG]'
9 : cap = ' [SEP]'
10: cap = ' [OCT]'
11: cap = ' [NOV]'
12: cap = ' [DEC]'
else : cap = '     '
end

if graph eq 'ps' then begin
set_plot,'ps'
device,filename='burden.ps',xoffset=1.5,yoffset=1.5,xsize=18, ysize=23 
end

!p.multi = [0,2,6]

for i = 0 , nspec-1 do begin
corr(i) = correlate(out(*,9),out(*,i))
plot, out(*,i), /ynozero, title=gas(i)+cap+string(corr(i)), charsize = 1.5
end

if graph eq 'ps' then begin
device, /close
set_plot,'x'
end

openw,jlun,'burden_out.dat_grads',/get
writeu,jlun,out
free_lun,jlun

return
end
