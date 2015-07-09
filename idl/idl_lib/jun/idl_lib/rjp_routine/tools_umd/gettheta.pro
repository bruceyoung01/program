function gettheta,kel=kel,psf=psf,press=press 

if n_elements(kel) eq 0 then print,'Please specify kel' 

aa = size(kel) 
ilmm = aa(1) & ijmm = aa(2) & ikmm = aa(3) 

case n_elements(psf) of 
0: begin
    psf = fltarr(ilmm,ijmm) & psf(*,*) = 1000. 
   end
else:
endcase 

case n_elements(press) of 
0: begin
    case ikmm of 
    28: press = grid_28(psf=psf) 
    35: press = grid_35(psf=psf) 
    else: press = grid(psf=psf,ikmm=ikmm) 
    endcase
   end 
else: 
endcase 

R = 287. ; J K-1 kg-1
cp = 1004; J K-1 kg-1 

theta = fltarr(ilmm,ijmm,ikmm) 
for ik=0,ikmm-1 do theta(0,0,ik) = kel(*,*,ik)*(psf/press(*,*,ik)) ^ (R/cp) 

return,theta
end 
