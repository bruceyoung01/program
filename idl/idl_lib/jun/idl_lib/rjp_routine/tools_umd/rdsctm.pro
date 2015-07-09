function rdsctm,dd=dd,dsn=dsn,xmom=xmom,ymom=ymom,fdcross=fdcross,$
crx=crx,cry=cry,fdx=fdx,fdy=fdy,ps1=ps1,ps2=ps2,totfluxy=totfluxy,$
dpiy=dpiy,totfluxx=totfluxx,dpix=dpix,u=u,v=v,fd2=fd2,delp1=delp1,$
delp2=delp2,dpi3d=dpi3d,w=w,dx=dx,cosp=cosp,cose=cose,$
im1=im1,jm1=jm1,fd1=fd1,nsteps=nsteps,mconv=mconv,xmass=xmass,mcorc=mcorc,$
mcore=mcore,dpx=dpx,dloncen=dloncen,dy=dy,ikmm=ikmm,ikk=ikk,$
fdz=fdz,fdfill=fdfill,delpnew=delpnew,dt=dt,dlonedge=dlonedge,$
dlatedge=dlatedge

if n_elements(dsn) eq 0 then dsn = 'fort.98'
if n_elements(dd) eq 0 then dd = '' 
if n_elements(nsteps) eq 0 then nsteps = 1 


;dd   :INPUT --> directory debugging data set located in
;dsn  ;INPUT --> name of debugging data set
;xmom ;OUTPUT --> 
;ymom
;fdcross
;crx=
;cry
;fdx       ;output --> field on level ikk after x advection
;fdy       ;output --> field on level ikk after y advection
;ps1       ;output --> surface pressure before advection
;ps2       ;output --> surface pressure after advection
;totfluxy  ;output --> bkgn mass flux in y direction on level ikk 
;dpiy      ;output --> dt*d(PI*v)/dy on level ikk 
;totfluxx  ;output --> bkgn mass flux in x direction on level ikk 
;dpix      ;output --> dt*d(PI*x)/dx on level ikk 
;u         ;output --> u component of wind
;v         ;output --> v component of wind
;fd2       ;output --> field after advection
;delp1     ;output --> dp at time t before advection. 
;delp2     ;output --> dp at time t+dt/2 
;dpi3d     ;output --> dt*[d(PI*x)/dx+d(PI*y)/dy] 
;w         ;output --> Vertical mass flux during dt in hPa 
;dx        ;output --> dx (meters)
;cosp      ;output --> cos of latitude at center of boxes. 
;cose      ;output --> cos of latitude at edge of boxes
;im1       ;output --> number of longitudes in stretch grid
;jm1       ;output --> number of latitudes in stretch grid
;ikmm      ;output --> number of vertical layers
;ikk       ;output --> layer debugging output written out on 
;fd1       ;output --> field before advection
;nsteps    ;output --> number of integration steps
;mconv     ;output --> Vertical integral of dpi3d
;xmass     ;output --> bkgn mass flux in y direction on level ikk 
;mcorc     ;output --> Area of grid boxes 
;mcore     ;output --> Area of grid boxes centered about n-s edges (not used) 
;dpx       ;output --> dp after x advection. 
;dloncen   ;output --> longitude at box centers
;dy        ;output --> dy (meters)
;fdz       ;output --> field on level ikk after z advection
;fdfill    ;output --> field on level ikk after filling negatives
;delpnew   ;output --> dp after advection. 
;dt        ;output --> timestep
;dlonedge  ;output --> longitude at e-w edges of boxes.
;dlatedge  ;output --> latitude at n-s edges of boxes.  


openr,ilun,dd+dsn,/f77_unformatted,/get_lun

im1 = 1. & jm1 = 1. & ikmm = 1. & ikk = 1. & ncon = 1. & dt = 1. 
readu,ilun,im1,jm1,ikmm,ikk 

xmom = fltarr(im1,jm1) & mconv = xmom & ps1 = xmom
ps2 = xmom & ymom = xmom & fdcross = xmom & fdx = xmom & fdy = xmom 
cry = xmom & xmass = xmom & crx = xmom & mcorc = xmom & mcore = xmom 
resfluxx = xmom & pv = xmom 
jindex = xmom & totfluxx = xmom & totfluxy = xmom 
dpiy = xmom & u = xmom & v = xmom & dx = xmom & dpix = xmom & dpx = xmom

dy = fltarr(jm1) & rlatedge = dy & cose = dy & cosp = dy 

dpi3d = fltarr(im1,jm1,ikmm) & w = dpi3d & delp1 = dpi3d & delp2 = dpi3d 
delpnew = delp2

rloncen = fltarr(im1) & rlonedge = rloncen 

rlatcen = fltarr(jm1) 
fdz = fdx & fdfill = fdx 
fd1 = fltarr(im1,jm1,ikmm,ncon) & fd2 = fd1 
readu,ilun,fd1
for icount=1,nsteps do begin
   readu,ilun,dpix,dpx,dpiy,totfluxy,totfluxx
   readu,ilun,dt,dx,dy,rloncen,rlatcen,rlonedge,rlatedge,cose,cosp
   cose(jm1-1) = 0. 
   readu,ilun,mcorc,mcore,crx,cry,xmom,ymom,fdcross 
   readu,ilun,xmass,delp1,delp2
   readu,ilun,fdx
   readu,ilun,fdy 
   readu,ilun,u
   readu,ilun,v 
   readu,ilun,dpi3d,mconv,ps1,ps2,w,delpnew
   readu,ilun,fdz
   readu,ilun,fdfill
   readu,ilun,fd2 
endfor  
free_lun,ilun

dloncen = rloncen * 180. / !pi
dlatcen = rlatcen * 180. / !pi
dlonedge = rlonedge * 180. / !pi 
dlatedge = rlatedge * 180. / !pi 
cosedge = cos(rlatedge)
ncoscen = cos(rlatcen) 

return,dlatcen 
end 
