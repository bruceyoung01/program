function locate, datain, xx, cof=cof

if n_elements(xx) eq 0 then return, -1 
if n_elements(datain) eq 0 then return, -1

; This subroutine assume that the input data xx is monotonically
; increasing or decreasing

n1 = n_elements(xx)
n2 = n_elements(datain)

op = intarr(n2)
cof = fltarr(n2)

for i = 0, n2-1 do begin

 jl = 0 & ju = n1-1

 while (ju gt jl+1) do begin
  jm = (jl+ju)/2
   if (xx(n1-1) ge xx(0) xor datain(i) ge xx(jm)) then begin
      ju = jm
   endif else begin
      jl = jm
   endelse
 end

 op(i) = jl
 cof(i) = (datain(i)-xx(jl))/(xx(jl+1)-xx(jl))

 if (cof(i) lt 0.) then begin
  op(i) = 0
  cof(i) = 0.0
 endif 
 if (cof(i) gt 1.0) then begin
  op(i) = n1-2 
  cof(i) = 1.0
 endif

end

return, op

end
