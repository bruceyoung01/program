function rdphot, file, nz, spec, zen=zen, pres=pres

if n_elements(nz) eq 0 then return, 0
if n_elements(zen) eq 0 then zen = 0.
if n_elements(spec) eq 0 then spec = 'NO2'

nx = 10

head = ''
data = fltarr(nx)
pres = fltarr(nz)
szen = fltarr(nx)
spec = strupcase(spec)

phot = fltarr(nz)

openr, ilun, file, /get

for i = 0, nz/10-1 do begin
readf, ilun, data, format ='(14X,10(1X,F10.3))'
it = i*10
pres(it:it+9) = data
end

readf, ilun, head
readf, ilun, to3,  format ='(14X,1X,F10.3)'
readf, ilun, alb,  format ='(14X,1X,F10.3)'
readf, ilun, szen, format ='(14X,10(1X,F10.2))'

for i = 0 , nx-1 do begin
 if (zen eq szen(i)) then begin
  izen = i
  goto, continue
 endif
end
stop
continue : print, szen(izen)

while (not eof(ilun)) do begin
 readf, ilun, head, data, is, iz, format ='(a14,10(1x,e10.4),2(1X,I3))'
 if (strtrim(head) eq spec) then phot(iz-1) = data(izen)
end

free_lun, ilun

return, phot

end
