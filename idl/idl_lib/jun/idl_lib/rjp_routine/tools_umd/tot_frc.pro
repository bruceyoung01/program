;+
; NAME:
;   
; PURPOSE:
;
; POSITIONAL PARAMETERS: 
;   fd1_ran:  3-d array containing ROVLP cloud fractions
;   fd1_max:  3-d array containing MOVLP cloud fractions
   
; INPUT KEYWORD PARAMETERS:
;  psf:  surface pressure
;  p_above:  pressure below which clear sky probs. are calc.
;  ikmm:   Vertical layers in DAO run (used to calculated pressures)   
 
; OUTPUTS:
;  frc_tot:  Total cloud cover 
;  frc_max:  Clear sky probability from maximum overlap clouds
;  frc_ran:  Clear sky probability from random overlap clouds 

; MODIFICATION HISTORY: 
;-
function tot_frc,fd1_ran,fd1_max,p_above=p_above,psf=psf,frc_max=frc_max,$
 frc_ran=frc_ran,ikmm=ikmm 
 
if n_elements(ikmm) eq 0 then ikmm = 20  
if n_elements(p_above) eq 0 then p_above = 440. 

aaa = size(fd1_ran)  & ilmm = aaa(1) & ijmm = aaa(2) & ikmm2 = aaa(3) 
case n_elements(psf) of
0: begin 
   psf = fltarr(ilmm,ijmm) 
   psf(*,*) = 1000.
   end
else:
endcase 
frc_max = fltarr(ilmm,ijmm) & frc_ran = frc_max & frc_tot = frc_max
frc_ran(*,*) = 1. 

press = grid(sigma=sigma,pint=pint,ikmm=ikmm) 
for ij=0,ijmm-1 do begin
for il=0,ilmm-1 do begin
   press = sigma * (psf(il,ij)-pint) + pint 
   press = press(0:ikmm2-1) 
   aaa = where(p_above gt press) 
   ikk = aaa(0) 
;  Calculate clear sky probability from max overlap clouds. 
   frc_max(il,ij) = 1.-max(fd1_max(il,ij,ikk:ikmm2-1)) 
;  Calculate clear sky probability from random overlap clouds. 
   for ik=ikk,ikmm2-1 do frc_ran(il,ij) = frc_ran(il,ij)*(1.-fd1_ran(il,ij,ik))
;  Total cloud cover = 1. - (clear_sky_max)*(clear_sky_ran)
   frc_tot(il,ij) = 1.-(frc_max(il,ij)*frc_ran(il,ij))
endfor
endfor

for ij=0,ijmm-1 do begin
for il=0,ilmm-1 do begin
   frc_max(il,ij) = 1.-frc_max(il,ij) 
   frc_ran(il,ij) = 1.-frc_ran(il,ij)
endfor
endfor

return,frc_tot
end 
