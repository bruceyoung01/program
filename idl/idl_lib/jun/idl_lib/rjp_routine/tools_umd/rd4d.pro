;+
;NAME:
;      rd4d.pro
;PURPOSE:
;      Read in 4-D fields from model (lon,lat,ht,constituent) 
;
;KEYWORD PARAMETERS
;      low:  0: Input (high) Output(low)
;            1: Input (low)  Output (low)
;            2: Input (high) Output (high) 
;      iread 0: open, read, and close
;            1: open and read 
;            2: read only
;            3: read and close 
;
;- 
function rd4d,hd=hd,psf=psf,iskip=iskip,dsn=dsn,low=low,dd=dd,$
 fudge = fudge,iread=iread,ilun=ilun,date=date,f77=f77,ilmm=ilmm,$
 ijmm=ijmm,ikmm=ikmm,ncon=ncon,dprecision=dprecision,phimin=phimin,$
 phimax=phimax,lonmin=lonmin,lonmax=lonmax,dphimn=dphimn,dphimx=dphimx,$
 dlmdmn=dlmdmn,dlmdmx=dlmdmx,diff=diff,wellmix=wellmix,convection=convection,$
 chem=chem,transport=transport,alpha=alpha,fill=fill,tdt=tdt

if n_elements(dprecision) eq 0 then dprecision = 0
if n_elements(f77) eq 0 then f77 = 0 
if n_elements(iread) eq 0 then iread = 0 
if n_elements(dsn) eq 0 then dsn = 'e731.co.jan92.lowres' 
if n_elements(iskip) eq 0 then iskip = 0 
if n_elements(low) eq 0 then low = 2  
if n_elements(dd) eq 0 then dd = '' 


case 1 of 
((f77 eq 1) and (iread lt 2)) : openr,ilun,dd+dsn,/f77_unformatted,/get_lun 
((f77 ne 1) and (iread lt 2)) : openr,ilun,dd+dsn,/xdr,/get_lun
else:
endcase 
print,'Reading from ', dd+dsn

if (dprecision eq 1) then hd = dblarr(50) else hd = fltarr(50) 
readu,ilun,hd 
ilmm = hd(8) & ilmm2 = ilmm / 2
ijmm = hd(9) & ijmm2 = (ijmm-1) / 2 + 1  
ikmm = hd(10) 
ncon = hd(11) 
phimin=hd(16)
phimax=hd(17)
lonmin=hd(18)
lonmax=hd(19)
dphimn=hd(20)
dphimx=hd(21)
dlmdmn=hd(22)
dlmdmx=hd(23)
diff=hd(24)
wellmix=hd(25)
convection=hd(26)
chem=hd(27)
transport=hd(28)
alpha=hd(29)
fill=hd(30)
tdt=hd(12) 
if n_elements(fudge) eq 0 then fudge = replicate(1.,ncon)

case low of 
0: begin
      psf2  = fltarr(ilmm, ijmm) 
      const2= fltarr(ilmm,ijmm,ikmm) 
      psf = fltarr(ilmm2,ijmm2) 
      const =fltarr(ilmm2,ijmm2,ikmm,ncon) 
   end
1: begin 
      psf = fltarr(ilmm2,ijmm2)
      const =fltarr(ilmm2,ijmm2,ikmm,ncon)
      psf2 = psf
      const2 = const
   end
2: begin       
      psf2  = fltarr(ilmm, ijmm) 
      const2= fltarr(ilmm,ijmm,ikmm) 
      psf = fltarr(ilmm,ijmm) 
      const =fltarr(ilmm,ijmm,ikmm,ncon)
   end
else:
endcase 

case dprecision of
1: begin
    psf2 = double(psf2)
    const2 = double(const2)
    psf = double(psf)
    const = double(const)
   end
else:
endcase 
case low of 
0:  begin
     for i=0,iskip-1 do begin
        if (i gt 0) then readu,ilun,hd
        readu,ilun,psf2
        for ic=0,ncon-1 do readu,ilun,const2
     endfor  
     fd = fltarr(ilmm2,ijmm) 
     for ic=0,ncon-1 do begin
        ii = indgen(ilmm2)*2 & jj = indgen(ijmm2)*2
        case ic of
        0: begin 
           if (iskip ne 0) then readu,ilun,hd
           readu,ilun,psf2
           readu,ilun,const2
           end 
        else: readu,ilun,const2 
        endcase  
   
        case ic of 
        0: begin 
              for ij=0,ijmm-1 do fd(0,ij) = psf2(indgen(ilmm2)*2,ij) 
              for il=0,ilmm2-1 do begin
                 fd2 = reform(fd(il,indgen(ijmm2)*2))  
                 for ij=0,ijmm2-1 do psf(il,ij)= fd2(ij) 
              endfor
           end 
        else: 
        endcase 
 
        for iz=0,ikmm-1 do begin 
           for ij=0,ijmm-1 do fd(0,ij) = const2(indgen(ilmm2)*2,ij,iz) 
           for il=0,ilmm2-1 do begin
              fd2 = reform(fd(il,indgen(ijmm2)*2))  
              for ij=0,ijmm2-1 do const(il,ij,iz,ic)= fd2(ij) 
           endfor
        endfor 
     endfor 
    end
1:  for i=0,iskip do begin
       if (i gt 0) then readu,ilun,hd
       readu,ilun,psf
       for ic=0,ncon-1 do readu,ilun,const
    endfor 
2:  begin
      for i=0,iskip-1 do begin
         if (i gt 0) then readu,ilun,hd
         readu,ilun,psf2
         for ic=0,ncon-1 do readu,ilun,const2
      endfor  

      if (iskip ne 0) then readu,ilun,hd
      readu,ilun,psf2 
      psf = psf2 
      for ic=0,ncon-1 do begin
         readu,ilun,const2 
         const(0,0,0,ic) = const2
      endfor 
     end 
else:
endcase 

for ic=0,ncon-1 do const(0,0,0,ic) = const(*,*,*,ic)*fudge(ic)

date = hd(5) 

if ((iread eq 0) or (iread eq 3)) then free_lun,ilun
return,const
end 
