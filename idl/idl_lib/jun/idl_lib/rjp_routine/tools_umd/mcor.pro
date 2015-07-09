;+
;PROGRAM:
;        mcor.pro
;PURPOSE:
;        Calculate surface area of grid boxes. 
;COMMENTS:
;        Surface area is scaled by fac before returning.
;        Polar caps are assumed to be wellmixed.  
      
;DATE:
;        January 15, 1998 
; 
;-
function mcor,ijmm=ijmm,ilmm=ilmm

if n_elements(ijmm) eq 0 then ijmm = 91
if n_elements(ilmm) eq 0 then ilmm = 144

a = 6.371220e8     

         ijmmm1 = ijmm -1 
         rlatedge = -!pi*0.5 + !pi*0.5/ijmmm1 + indgen(ijmm)*!pi/ijmmm1  

         rlonedge = -!pi + indgen(ilmm)*2.*!pi/ilmm + !pi/ilmm 

area =  fltarr(ilmm,ijmm)      

sp_area = -2.*!pi*a^2*(cos(rlatedge(0)+!pi*0.5)-1.)/ilmm
np_area = -2.*!pi*a^2*(-1.-cos(rlatedge(ijmm-2)+!pi*0.5))/ilmm
dy_area = -2.*!pi*a^2*(cos(rlatedge(1:ijmm-2)+!pi*0.5)-cos(rlatedge(0:ijmm-3)+!pi*0.5))/ilmm

dx_area = ilmm*(rlonedge - shift(rlonedge,1))/(2.*!pi)
dx_area(0) = ilmm*(rlonedge(0) - rlonedge(ilmm-1) + 2.*!pi)/(2.*!pi) 

dy_area = [sp_area,dy_area,np_area]  

for ij=0,ijmm-1 do begin
for il=0,ilmm-1 do begin
   area(il,ij) = dy_area(ij)*dx_area(il)
endfor
endfor 

print,total(area),4.*!pi*a^2 

return, area 
end 
