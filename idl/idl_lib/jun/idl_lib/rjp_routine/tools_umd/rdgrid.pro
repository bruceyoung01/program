function rdgrid,dd=dd,dsn=dsn,f77=f77,ilmm=ilmm,ijmm=ijmm,phimin=phimin,$
 phimax=phimax,lonmin=lonmin,lonmax=lonmax,dphimn=dphimn,dphimx=dphimx,$
 dlmdmn=dlmdmn,dlmdmx=dlmdmx,dlonedge=dlonedge,dlatcen=dlatcen,$
 dlatedge=dlatedge  

if n_elements(dd) eq 0 then dd = '' 
if n_elements(dsn) eq 0 then dsn = 'hgrid_aeroce.input'
if n_elements(f77) eq 0 then f77 = 1 

case f77 of 
0: openr,ilun,dd+dsn,xdr,/get_lun 
else: openr,ilun,dd+dsn,/f77_unformatted,/get_lun 
endcase

ilmm = 1. & ijmm = 1. & readu,ilun,ilmm,ijmm

rloncen = fltarr(ilmm) & rlonedge = rloncen 
rlatcen = fltarr(ijmm) & rlatedge = rlatcen 
readu,ilun,rloncen,rlonedge,rlatcen,rlatedge
dtr = !pi / 180. 
dloncen = rloncen / dtr & dlonedge = rlonedge / dtr
dlatcen = rlatcen / dtr & dlatedge = rlatedge / dtr 

phimin = 1. & phimax = 1. & lonmin = 1. & lonmax = 1. 
dphimn = 1. & dphimx = 1. & dlmdmn = 1. & dlmdmx = 1. 
readu,ilun,phimin,phimax,lonmin,lonmax,dphimn,dphimx,dlmdmn,dlmdmx 

free_lun,ilun   

return,dloncen
end
