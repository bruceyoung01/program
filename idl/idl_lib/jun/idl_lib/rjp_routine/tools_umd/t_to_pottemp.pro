function t_to_pottemp,t,plev,badval=badval,reverse=reverse
;
; function to return potential temperature given 3-d temperature field
;   (vertical is last dimension) and associated pressures or temperature 
;   given potential temperature and pressures
;

if(n_elements(reverse) eq 0) then reverse = 0   else reverse = 1

temp = size(t)
;print,temp
if(temp(0) ne 2 and temp(0) ne 3) then begin
  print,'t_to_pottemp for 2 or 3-d arrays only'
  return,-999
 end
if(temp(0) eq 2) then temp(3) = 1

r = 287.
cp = 1004.
p0 = t*0.0+1000.
for n=0,temp(3)-1 do p0(*,*,n) = p0(*,*,n)/plev(n)
;p0 = p0^(r/cp)
if(reverse eq 0) then p0 = p0^(r/cp)   else p0 = p0^(-r/cp)

;... check for badvals
if(n_elements(badval) ne 0) then begin
  indbad = where(t eq badval,cnt)
  if(cnt gt 0) then p0(indbad) = 1.
 end

return,t*p0
end
