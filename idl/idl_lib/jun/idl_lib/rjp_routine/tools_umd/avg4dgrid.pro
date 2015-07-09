function avg4dgrid,ddconst=ddconst,ddgrid=ddgrid,dsnconst=dsnconst,dsngrid=$
dsngrid,hd=hd,psf=psf,iskip=iskip,low=low,fudge = fudge,iread=iread,ilun=ilun,$
date=date,f77dsn=f77dsn,f77grid=f77grid,ilmm=ilmm,ijmm=ijmm,ikmm=ikmm,ncon=ncon,$
dprecision=dprecision,phimin=phimin,phimax=phimax,lonmin=lonmin,lonmax=lonmax,$
dphimn=dphimn,dphimx=dphimx,dlmdmn=dlmdmn,dlmdmx=dlmdmx,diff=diff,$
wellmix=wellmix,convection=convection,chem=chem,transport=transport,$
alpha=alpha,fill=fill,tdt=tdt,dloncen=dloncen,dlatcen=dlatcen,dlonedge=$
dlonedge,dlatedge=dlatedge,nobs=nobs

if n_elements(ddconst) eq 0 then ddconst = ''
if n_elements(ddgrid) eq 0 then ddgrid = '/data/eos1/allen/ctm/grid/'
if n_elements(dsnconst) eq 0 then dsnconst = 'e001.dat001'
if n_elements(dsngrid) eq 0 then dsngrid = 'hgrid310213.input'
if n_elements(f77grid) eq 0 then f77grid = 1
if n_elements(f77dsn) eq 0 then f77dsn = 1

if n_elements(nobs) eq 0 then nobs = 1

dloncen = rdgrid(dd=ddgrid,dsn=dsngrid,f77=f77grid,ilmm=ilmm,ijmm=ijmm,$
 phimin=phimin,phimax=phimax,lonmin=lonmin,lonmax=lonmax,dphimn=dphimn,$
 dphimx=dphimx,dlmdmn=dlmdmn,dlmdmx=dlmdmx,dlonedge=dlonedge,$
 dlatcen=dlatcen,dlatedge=dlatedge) 
 
for i=0,nobs-1 do begin  

   case i of 
   0: iread = 1      
   nobs-1: iread = 3       
   else: iread = 2 
   endcase 
   
   const1 = rd4d(hd=hd1,psf=ps1,iskip=iskip,dsn=dsnconst,low=low,dd=ddconst,$
    fudge = fudge,iread=iread,ilun=ilun,date=date1,f77=f77dsn,ilmm=ilmm1,$
    ijmm=ijmm1,ikmm=ikmm,ncon=ncon,dprecision=dprecision,phimin=phimin1,$
    phimax=phimax1,lonmin=lonmin1,lonmax=lonmax1,dphimn=dphimn1,dphimx=dphimx1,$
    dlmdmn=dlmdmn1,dlmdmx=dlmdmx1,diff=diff,wellmix=wellmix,convection=$
    convection,chem=chem,transport=transport,alpha=alpha,fill=fill,tdt=tdt)
 
   if (ilmm1 ne ilmm) then print,'Wrong grid! Check ilmm',ilmm1,ilmm  
   if (ijmm1 ne ijmm) then print,'Wrong grid! Check ijmm',ijmm1,ijmm   
   if (phimin1 ne phimin) then print,'Wrong grid! Check phimin',phimin1,phimin

   case i of 
   0: begin
         const = fltarr(ilmm1,ijmm1,ikmm,ncon) 
	 psf = fltarr(ilmm1,ijmm1) 
	 hd = fltarr(50,nobs) 
	 date = fltarr(nobs) 
      end  
   else: 
   endcase 
      
   const = const + const1 / nobs 
   psf = psf + ps1 / nobs 
   hd(0,i) = hd1
   date(i) = date1  

endfor

return,const 
end     
    
 
 
