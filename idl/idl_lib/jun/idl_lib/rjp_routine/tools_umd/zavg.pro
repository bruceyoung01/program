function zavg,fd3d,dlonedge

aa = size(fd3d)
ilmm = aa(1) & ijmm = aa(2) & ikmm = aa(3) 
dx = -(dlonedge - shift(dlonedge,-1)) 
dx(ilmm-1) = dlonedge(0) - dlonedge(ilmm-1) + 360.

tot = fltarr(ijmm,ikmm) 
for ik=0,ikmm-1 do begin
for ij=0,ijmm-1 do begin
for il=0,ilmm-1 do begin 
   tot(ij,ik)= tot(ij,ik) + fd3d(il,ij,ik)*dx(il) 
endfor
endfor
endfor

tot = tot / 360. 
return,tot
end  
