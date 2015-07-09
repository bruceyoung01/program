;+
;NAME:
;      cp4df77toieee.pro
;PURPOSE:
;      Read in 4-D fields from model (lon,lat,ht,constituent) convert from
;      f77 to ieee or vice versa. 
;
;KEYWORD PARAMETERS
;
;- 
pro cp4df77toieee,hd=hd,psf=psf,dsnin=dsnin,dsnout=dsnout,ddin=ddin,$
 f77toieee=f77toieee,nobs=nobs,ilmm=ilmm,ijmm=ijmm,ikmm=ikmm,ddout=ddout

if n_elements(f77toieee) eq 0 then f77toieee = 1
if n_elements(dsnin) eq 0 then dsnin = 'e006.dat003' 
if n_elements(ddin) eq 0 then ddin = '/data/eos2/allen/ctm/output/' 
if n_elements(ddout) eq 0 then ddout = ddin 

case f77toieee of
1:    begin
         openr,ilun1,ddin+dsnin,/f77_unformatted,/get_lun
	 if n_elements(dsnout) eq 0 then dsnout = dsnin + '_xdr'
         openw,ilun2,ddout+dsnout,/xdr,/get_lun
      end  
else: begin
         openr,ilun1,ddin+dsnin,/xdr,/get_lun
	 if n_elements(dsnout) eq 0 then dsnout = dsnin + '_f77'
         openw,ilun2,ddout+dsnout,/f77_unformatted,/get_lun
      end  
endcase 
print,'Reading from ', ddin+dsnin
print,'Writing to ', ddout+dsnout 

hd = fltarr(50) 
nobs = 0 
while (not eof(ilun1)) do begin  
   readu,ilun1,hd
   nobs = nobs + 1 
   writeu,ilun2,hd 
   case nobs of 
   1: begin
      ilmm = hd(8) 
      ijmm = hd(9)
      ikmm = hd(10) 
      ncon = hd(11) 
      psf = fltarr(ilmm,ijmm) 
      fd3d = fltarr(ilmm,ijmm,ikmm) 
      end
   else:
   endcase 
   
   readu,ilun1,psf
   writeu,ilun2,psf
   for ic=0,ncon-1 do begin
      readu,ilun1,fd3d
      writeu,ilun2,fd3d
   endfor 
end
 
free_lun,ilun1
free_lun,ilun2

return
end 
