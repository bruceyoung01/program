function wrconc, conc, temp, jlun=jlun

;+
; NAME:
;   GETCONC
;
; PURPOSE :
;   RETRIEVE INDIVIDUAL SPECIES CONCENTRATION FROM ARCHIVED DATA
;
;-

 if n_elements(conc) eq 0 then begin
   print, 'no values for conc' 
   return, 0
 end
 if n_elements(temp) eq 0 then begin
   print, 'no values for temp' 
   return, 0
 end

 if n_elements(jlun) eq 0 then openw,jlun,'conc_spec_out.dat_grads',/get_lun

 dim = size(conc)
 ilmm = dim(1) & ijmm = dim(2) & ikmm = dim(3) & ns = dim(4)
 print, ilmm, ijmm, ikmm, ns
 out = conc

 writeu, jlun, reverse(temp,3)

 for i = 0, ns-1 do out(*,*,*,i) = reverse(conc(*,*,*,i),3)

 writeu, jlun, out

return, 1

end
