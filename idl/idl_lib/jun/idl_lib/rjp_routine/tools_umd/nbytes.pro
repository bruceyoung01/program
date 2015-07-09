function nbytes,ilmm=ilmm,ijmm=ijmm,ikmm=ikmm,ncon=ncon,hd=hd,nobs=nobs,$
 f77=f77

if n_elements(ilmm) eq 0 then ilmm = 144.
if n_elements(ijmm) eq 0 then ijmm = 91.
if n_elements(ikmm) eq 0 then ikmm = 20.
if n_elements(ncon) eq 0 then ncon = 1 
if n_elements(hd) eq 0 then hd = 50.
if n_elements(nobs) eq 0 then nobs = 1
if n_elements(f77) eq 0 then f77 = 0 

case f77 of 
0: nbytes = (hd+float(ilmm)*ijmm+float(ilmm)*ijmm*ikmm*ncon)*4.*nobs
else: nbytes = (hd+2.+float(ilmm)*ijmm+2 + float(ilmm)*ijmm*ikmm*ncon+2*ncon)*4.*nobs
endcase
return,nbytes 
end 
