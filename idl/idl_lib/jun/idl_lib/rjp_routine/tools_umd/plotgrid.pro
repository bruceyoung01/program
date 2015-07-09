pro plotgrid,dd=dd,dsn=dsn,f77=f77,inc=inc,dloncen=dloncen,dlatcen=dlatcen,$
 im1=im1,jm1=jm1

if n_elements(dd) eq 0 then dd = ''
if n_elements(dsn) eq 0 then dsn = 'hgrid_aeroce.input'
if n_elements(f77) eq 0 then f77 = 1
if n_elements(inc) eq 0 then inc = 1 

!p.multi = 0. 

case f77 of 
1: openr,ilun,dd+dsn,/f77_unformatted,/get_lun 
else: openr,ilun,dsn,/xdr,/get_lun
endcase 
im1 = 1. & jm1 = 1. 
readu,ilun,im1,jm1
print,'im1 = ', im1, ' jm1 = ',jm1 
title = '!5Stretch grid ' + strtrim(fix(im1),2) + ' longitudes ' + $
 strtrim(fix(jm1),2) + ' latitudes' 
rloncen = fltarr(im1) & rlonedge = rloncen 
rlatcen = fltarr(jm1) & rlatedge = rlatcen 
readu,ilun,rloncen,rlonedge,rlatcen,rlatedge
phimin = 1. & phimax = 1. & lonmin = 1. & lonmax = 1. 
dphimn = 1. & dphimx = 1. & dlmdmn = 1. & dlmdmx = 1. 
readu,ilun,phimin,phimax,lonmin,lonmax,dphimn,dphimx,dlmdmn,dlmdmx 
free_lun,ilun   
print,'Latitude range of hi-res region',phimin,phimax
print,'Longitude range of hi-res region', lonmin,lonmax
print,'Min and max dy',dphimn,dphimx
print,'Min and max dx',dlmdmn,dlmdmx

sdphimn = format(dphimn,sformat='4.2') 
sdphimx = format(dphimx,sformat='4.2') 
sdlmdmn = format(dlmdmn,sformat='4.2') 
sdlmdmx = format(dlmdmx,sformat='4.2') 
slonmin = format(lonmin,sformat='6.1')
slonmax = format(lonmax,sformat='6.1') 
sphimin = format(phimin,sformat='5.1')
sphimax = format(phimax,sformat='5.1') 

case inc of 
1: spt = ''
2: spt = '2nd'
3: spt = '3rd'
4: spt = '4th' 
8: spt = '8th'
else: spt = strtrim(inc,2)
endcase 


xtitle='!5['+sdlmdmn+'-'+sdlmdmx+']E-W  ['+$
 sdphimn+'-'+sdphimx+']N-S (Every '+spt+' pt shown)'

xtitle1='!5High Resolution Area ['+$
 slonmin+'W to'+slonmax+'W]  ['+sphimin+'N to'+sphimax+'N]'

dtr = !pi / 180. 
dloncen = rloncen / dtr & dlonedge = rlonedge / dtr
dlatcen = rlatcen / dtr & dlatedge = rlatedge / dtr 

fd = fltarr(im1,jm1)

sfc,loncen=dloncen,latcen=dlatcen,lons=[-180.,180.],lats=[-90.,90.],title=title,charsize=1.5,$
 xticks=0,yticks=0
xyouts,0.5,0.15,xtitle,alignment=0.5,charsize=1.3,/normal
xyouts,0.5,0.10,xtitle1,alignment=0.5,charsize=1.3,/normal
;contour,fd,dloncen,dlatcen,$
;    xrange=[-180.,180.],xstyle=1,xticks=6,charthick=2.5,charsize=1.3,$
;    yrange=[-90.,90.],ystyle=1,yticks=6,/nodata,title=title
    
for j=0,jm1-1,inc do for i=0,im1-1,inc do xyouts,dloncen(i),dlatcen(j),'+',alignment=0.5,$
 charsize=0.40   

return
end
