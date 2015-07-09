;PROGRAM: 
;  plotuv
;PURPOSE: 
; Calculate streamlines 
pro plotuv,u1,v1,lats=lats,lons=lons,nplots=nplots,remframes=remframes,$
 latdel=latdel,londel=londel,title=title,xmargin=xmargin,ymargin=ymargin,$
 xpt1=xpt1,ypt1=ypt1,xticks=xticks,yticks=yticks,charthick=charthick,$
 charsize1=charsize1,ymaxprime=ymaxprime,spt1=spt1,loncen=loncen,latcen=latcen,$
 i1=i1,i2=i2,j1=j1,j2=j2,charsizept=charsizept,xpt2=xpt2,ypt2=ypt2,spt2=spt2 

if n_elements(loncen) eq 0 then loncen = -180. + findgen(144)*2.5
if n_elements(latcen) eq 0 then latcen = -90. + findgen(91)*2. 
if n_elements(spt1) eq 0 then spt1 = ''  
if n_elements(spt2) eq 0 then spt2 = ''  
if n_elements(charthick) eq 0 then charthick=2.5
if n_elements(charsize1) eq 0 then charsize1=1.5
if n_elements(charsizept) eq 0 then charsizept = charsize1
if n_elements(xpt1) eq 0 then xpt1 = 0.
if n_elements(ypt1) eq 0 then ypt1 = 0. 
if n_elements(xpt2) eq 0 then xpt2 = 0.
if n_elements(ypt2) eq 0 then ypt2 = 0. 
if n_elements(xticks) eq 0 then xticks = 6 
if n_elements(yticks) eq 0 then yticks = 6 
if n_elements(latdel) eq 0 then latdel = 15.
if n_elements(londel) eq 0 then londel = 15. 
if n_elements(xmargin) eq 0 then xmargin = [6,6]
if n_elements(ymargin) eq 0 then ymargin = [6,6] 
if n_elements(lats) eq 0 then lats = [-90.,90.]
if n_elements(lons) eq 0 then lons = [-180.,180.]
if n_elements(nplots) eq 0 then nplots = 1  
if n_elements(remframes) eq 0 then remframes = 1   
if n_elements(title) eq 0 then title = '' 

case nplots of 
4: begin & xstack=2 & ystack=2 & end 
9: begin & xstack=3 & ystack=3 & end 
1: begin & xstack=0 & ystack=0 & end 
2: begin & xstack=0 & ystack=2 & end 
else: begin & print,'Please respecify nplots' & stop & end
endcase 

aa = size(u1) & ilmm = aa(1) & ijmm = aa(2) 


u11 = [u1,u1] & v11 = [v1,v1] & loncen2 = [loncen-360.,loncen] 
i1 = where(loncen2 ge lons(0)) & i1 = i1(0) 
i2 = where(loncen2 ge lons(1)) & i2 = i2(0) & if (i2 eq -1) then i2 = ilmm-1 
j1 = where(latcen ge lats(0)) & j1 = j1(0) 
j2 = where(latcen ge lats(1)) & j2 = j2(0) 
dx = loncen2(i2) - loncen2(i1)
iii = 0 

uu = u11(i1:i2,j1:j2)
vv = v11(i1:i2,j1:j2) 
aa = where(uu lt 200.) & zz = sqrt(abs(uu(aa)*vv(aa))) & zz = max(zz)
if n_elements(ymaxprime) eq 0 then ymaxprime = zz 
length = zz / ymaxprime  

!p.multi = [remframes,xstack,ystack]   
  
;Suppress labels.      
ytickn= replicate(' ',yticks+1) & xtickn=replicate(' ',xticks+1)
    
;  Draw map  
mlinethick=1.0  ;Thickness used for continental boundaries
maxlon = lons(1) & minlon = lons(0)
maxlat = lats(1) & minlat = lats(0)
case 1 of 
(remframes eq nplots): map_set,0.,(maxlon+minlon)/2.,/cyl,/cont,/usa,/grid,$
 lim=[minlat,minlon,maxlat,maxlon],latdel=latdel,londel=londel,$
 xmargin=xmargin,ymargin=ymargin,mlinethick=mlinethick 
(remframes ne nplots): map_set,0.,(maxlon+minlon)/2.,/cyl,/cont,/usa,/grid,$
 lim=[minlat,minlon,maxlat,maxlon],latdel=latdel,londel=londel,$
 xmargin=xmargin,ymargin=ymargin,mlinethick=mlinethick,/noerase 
else:
endcase

!p.multi = [remframes,xstack,ystack]                  
;  Draw wind vectors 
if (ilmm-i2 eq 1) then x2 = loncen2(0)+360. else x2 = loncen2(i2) 

dy = latcen(j2)-latcen(j1) 
!p.thick=2.5 
velovect,uu,vv,loncen2(i1:i2),latcen(j1:j2),length=length,/noerase,xstyle=1,$
 xrange=[loncen2(i1),x2],yrange=[latcen(j1),latcen(j2)],xtickn=xtickn,ytickn=ytickn,$
 ymargin=ymargin,xmargin=xmargin,xticks=xticks,yticks=yticks,$
 title ='',missing=200.,thick=2.5 
xyouts,xpt1,ypt1,spt1,alignment=0.5,charsize=charsizept,charthick=2.5 
xyouts,xpt2,ypt2,spt2,alignment=0.5,charsize=charsizept,charthick=2.5

aa = loncen2(i1)+ findgen(xticks+1) * (x2-loncen2(i1)) / xticks 
slon = strtrim(fix(aa),2) 
for i=0,xticks do xyouts,aa(i),latcen(j1)-dy/8.,slon(i),alignment=0.5,charsize=1.5,charthick=2.5

aa = lats(0) + findgen(yticks+1) * (lats(1)-lats(0)) / yticks 
slat = strtrim(fix(aa),2) 
for i=0,yticks do xyouts,loncen2(i1)-dx/40.,aa(i),slat(i),alignment=1.,charsize=1.5,charthick=2.5
xyouts,(loncen2(i1)+loncen2(i2))*0.5,latcen(j2)+dy/10.,title,alignment=0.5,charsize=1.5,charthick=2.5

title2 = 'Max wind = ' + strtrim(fix(zz+0.5),2) + ' m/s' 
xyouts,(loncen2(i1)+loncen2(i2))*0.5,latcen(j1)-dy/4.,title2,alignment=0.5,charsize=1.2,charthick=2.5 

return 
end 
