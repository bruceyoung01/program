;+
;PROGRAM:
;        setmcor.pro
;PURPOSE:
;        Calculate surface area of grid boxes. 
;COMMENTS:
;        Surface area is scaled by fac before returning.
;        Polar caps are assumed to be wellmixed.  
;        note: dlatedge(0) gives latitude at northern edge of southernmost
;         grid box.  
      
;DATE:
;        January 15, 1998 
; 
;-
function setmcor,dlatedge=dlatedge,dlonedge=dlonedge,fac=fac 

if n_elements(fac) eq 0 then fac = 1.e-15
a = 6.371220e6     

case n_elements(dlatedge) of
0:    begin
         ijmm = 91
         ijmmm1 = ijmm -1 
         dlatedge = -90. + 90*0.5/ijmmm1 + indgen(ijmm)*ijmmm1  
      end
else: begin
         ijmm = size(dlatedge)
	 ijmm = ijmm(1)
      end 
endcase 

case n_elements(dlonedge) of
0:    begin
         ilmm = 144
         dlonedge = -180. + indgen(ilmm)*360./ilmm + 180./ilmm 
   end
else: begin
        ilmm = size(dlonedge) 
	ilmm = ilmm(1)
      end 
endcase 

dtr = !pi / 180. 
rlonedge = dlonedge * dtr
rlatedge = dlatedge * dtr
mcor =  fltarr(ilmm,ijmm)      

sp_area = -2.*!pi*a^2*fac*(cos(rlatedge(0)+!pi*0.5)-1.)/ilmm
np_area = -2.*!pi*a^2*fac*(-1.-cos(rlatedge(ijmm-2)+!pi*0.5))/ilmm
dy_area = -2.*!pi*a^2*fac*(cos(rlatedge(1:ijmm-2)+!pi*0.5)-cos(rlatedge(0:ijmm-3)+!pi*0.5))/ilmm

dx_area = ilmm*(rlonedge - shift(rlonedge,1))/(2.*!pi)
dx_area(0) = ilmm*(rlonedge(0) - rlonedge(ilmm-1) + 2.*!pi)/(2.*!pi) 

dy_area = [sp_area,dy_area,np_area]  

for ij=0,ijmm-1 do begin
for il=0,ilmm-1 do begin
   mcor(il,ij) = dy_area(ij)*dx_area(il)
endfor
endfor 

;print,'Estimated surface area of earth = ', total(mcor)/fac
;print,'Exact surface area of earth = ', 4.*!pi*a^2.*fac/fac 

return,mcor  
end 
