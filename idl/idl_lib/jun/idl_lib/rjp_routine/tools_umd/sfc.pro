;+
; NAME:  
;   sfc.pro
;         
; PURPOSE: 
;   Contour plot is made at desired level 
;   
; CALLING SEQUENCE:  
;   pro sfc,title='',lons=lons,lats=lats,map_color=map_color,$
;
;   
; KEYWORD PARAMETERS:  
;        
;    lons       String array containing longitude (degs) for western and eastern edges of
;                contour plot  (def: loncen(0),loncen(ilmm-1))
;    lats       String array containing latitude (degs) for southern and northern edges of
;                contour plot (def: latcen(0),latcen(ijmm-1))
;    nwait      seconds to wait between contour plots (default = 3) 
;    levelscon  Array containing desired contour levels for Rn-222               
;    title      String array containing title of plot
;    xtitle     String array containing abscissa title
;    ytitle     String array containing ordinate title 
;    map_color  Color of background map 
;    con_color  Color of background continents. 
;    londel     Spacing in degrees between longitude grid
;    latdel     Spacing in degrees between latitude grid 
;
; OPTIONAL OUTPUT KEYWORD PARAMETERS: 
;
; WARNINGS:
;    Procedure assumes data aligned from 0 to 360E. 
;    charsize is not working! 
; 
; MODIFICATION HISTORY:  
;   Initial version  8 April 1994
;
;  
;-
pro sfc,fd=fd,lons=lons,title=title,lats=lats,xtitle=xtitle,ytitle=ytitle,$
 levelscon=levelscon,map_color=map_color,con_color=con_color,usa=usa,$
 ikmm=ikmm,nlevels=nlevels,spt=spt,closed=closed,$
 charsize=charsize,multi=multi,noerase=noerase,levdef=levdef,$
 charthick=charthick,loncen=loncen,latcen=latcen,c_linestyle=c_linestyle,$
 xmargin=xmargin,ymargin=ymargin,xpt=xpt,ypt=ypt,c_thick=c_thick,$
 xticks=xticks,yticks=yticks,max_value=max_value,min_value=min_value,$
 c_charsize=c_charsize,latdel=latdel,londel=londel,fill=fill,$
 c_colors=c_colors,cell_fill=cell_fill,c_orientation=c_orientation,$
 c_spacing=c_spacing,countries=countries,nsposlonlab=nsposlonlab,$
 xcharsize=xcharsize,ycharsize=ycharsize,ticklen=ticklen  

if n_elements(ticklen) eq 0 then ticklen = 0.02
if n_elements(closed) eq 0 then closed = 0 
if n_elements(nsposlonlab) eq 0 then nsposlonlab = 8. 
if n_elements(countries) eq 0 then countries = 0 
if n_elements(spt) eq 0 then spt = '' 
if n_elements(cell_fill) eq 0 then cell_fill = 0  
if n_elements(fill) eq 0 then fill = 0 
if n_elements(max_value) eq 0 then max_value = 1.e20 
if n_elements(min_value) eq 0 then min_value = -1.e20 
if n_elements(c_linestyle) eq 0 then c_linestyle=[-1]   
if n_elements(xpt) eq 0 then xpt = 1000.
if n_elements(ypt) eq 0 then ypt = 1000.
if n_elements(c_linestyle) eq 0 then c_linestyle = 0 
if n_elements(levdef) eq 0 then levdef = 0  
if n_elements(multi) eq 0 then multi = 0  
if n_elements(charsize) eq 0 then charsize = 1
if n_elements(charthick) eq 0 then charthick = 1 
if n_elements(ikmm) eq 0 then ikmm = 20 
if n_elements(noerase) eq 0 then noerase = 0 
if n_elements(lons) eq 0 then lons = [-180.,180.] 
if n_elements(xmargin) eq 0 then xmargin = [8,6] 
if n_elements(ymargin) eq 0 then ymargin = [6,6]
if n_elements(title) eq 0 then title = '' 
if n_elements(xticks) eq 0 then xticks = 6
if n_elements(yticks) eq 0 then yticks = 6 
if n_elements(c_charsize) eq 0 then c_charsize = 0.75*charsize  
if n_elements(c_thick) eq 0 then c_thick = 2. 
if n_elements(c_orientation) eq 0 then c_orientation = [45,90,135]
if n_elements(c_spacing) eq 0 then c_spacing = 0.025 
if n_elements(xcharsize) eq 0 then xcharsize = 1
if n_elements(ycharsize) eq 0 then ycharsize = 1

!p.multi = multi 

case 1 of
(n_elements(fd) gt 0): begin
                        nnn = size(fd) & ilmm = nnn(1) & ijmm = nnn(2) 
                       end
else:                  begin
                        ilmm = 144 & ijmm = 91 
                       end
endcase                        

if n_elements(latcen) eq 0 then latcen=-90.+findgen(ijmm)*180./(ijmm-1) 
if n_elements(loncen) eq 0 then loncen=findgen(ilmm)*360./ilmm 

case ikmm of 
20: press = $ 
    [9.94000E+02,9.71590E+02,9.30630E+02,8.75400E+02,8.09750E+02, $
     7.37140E+02, 6.60540E+02,5.82610E+02, 5.05500E+02, 4.30500E+02,$ 
     3.58480E+02, 2.90910E+02, 2.30520E+02,1.80430E+02,1.40880E+02, $
     1.09050E+02, 8.22700E+01, 5.92500E+01, 3.87100E+01, 1.94100E+01]
25: press=[922.,771.,648.,548.,447.,346.,274.,224.,187.,162.,$
      140.,122.,107.,92.2,77.1,64.8,54.8,44.7,34.6,24.5,14.1,$
      7.1,3.1,1.4,0.63]
else:  
endcase 

if n_elements(lats) eq 0 then lats=[latcen(0),latcen(ijmm-1)] 

minlat = lats(0) & maxlat = lats(1)
minlon = lons(0) & maxlon = lons(1)
if n_elements(latdel) eq 0 then latdel = (maxlat-minlat)/yticks 
if n_elements(londel) eq 0 then londel = (maxlon-minlon)/xticks   
!p.position=[0.2,0.8,0.2,0.8] 

if n_elements(lonlab) eq 0 then lonlab = (minlat+maxlat)*0.5 
if n_elements(latlab) eq 0 then latlab = (minlon+maxlon)*0.5 

mlinethick=1.0  ;Thickness used for continental boundaries
map_set,0.,(maxlon+minlon)/2.,lim=[minlat,minlon,maxlat,maxlon],/cont,/cyl,$ 
title=title,usa=usa,londel=londel,latdel=latdel,charsize=charsize,$
 xmargin=xmargin,ymargin=ymargin,mlinethick=mlinethick,/advance

loncen2 = loncen - 360. & loncen2 = [loncen2,loncen,loncen(0)+360.] 
i1 = fix((minlon-loncen2(0))*ilmm/360.) & i2 = fix((maxlon-loncen2(0))*ilmm/360.)

i1 = where(minlon le loncen2,count) & i1 = i1(0) 
i2 = where(maxlon le loncen2,count) & i2 = i2(0) 
j1 = where(minlat le latcen,count)  & j1 = j1(0) 
j2 = where(maxlat le latcen,count)  & j2 = j2(0) 

;if (2*ilmm-i2 eq 1) then x2 = 360. else x2 = loncen2(i2)
if (2*ilmm-i2 eq 1) then x2 = 360. else x2 = lons(1)
;dy = latcen(j2)-latcen(j1) & dx = x2 - loncen2(i1)
dy = lats(1)-lats(0) & dx = x2 - lons(0)

;xyouts,0.5*(lons(0)+lons(1)),latcen(j2)+dy/nsposlonlab,title,charsize=charsize,charthick=2.5,alignment=0.5 
;print longitudes
aa = lons(0)+ findgen(xticks+1) * (x2-lons(0)) / xticks 
slon = strtrim(fix(aa),2) 
case 1 of 
(lons(0) eq -180.):
(lons(1) eq 180.):
(lats(1) gt -85.): for i=0,xticks do xyouts,aa(i),latcen(j1)-dy/nsposlonlab,slon(i),alignment=0.5,charsize=xcharsize*charsize,charthick=2.5
else:      for i=0,xticks do xyouts,aa(i),latcen(j1),slon(i),alignment=0.,charsize=xcharsize*charsize,charthick=2.5
endcase
 
;print latitudes 
aa = lats(0) + findgen(yticks+1) * (lats(1)-lats(0)) / yticks 
slat = strtrim(fix(aa),2) 
;Will dx/100 work always? 
if (dx eq 360.) then dxx = 0. else dxx = dx / 100. 
;for i=0,yticks do xyouts,lons(0)-dxx,aa(i),slat(i),alignment=1.,charsize=ycharsize*charsize,charthick=2.5

case 1 of
(lons(0) eq -180.): for i=0,yticks do xyouts,lons(0),aa(i),slat(i),alignment=1.,charsize=ycharsize*charsize,charthick=2.5
else:               for i=0,yticks do xyouts,lons(0)-dx*0.05,aa(i),slat(i),alignment=0.5,charsize=ycharsize*charsize,charthick=2.5
endcase 
xyouts,xpt,ypt,spt,alignment=0.5,charsize=2.5,charthick=2.5

if n_elements(fd) eq 0 then return
fd2 = [fd,fd,fd(0,*)]  

if n_elements(levelscon) eq 0 then levdef=1 
case levdef of
1: begin
    fd3 = fd2(i1:i2,j1:j2)
    aa = where((fd3 lt max_value) and (fd3 gt min_value)) 
    fd3 = fd3(aa) 
    zmin = min(fd3) 
    zmax = max(fd3) 
    if n_elements(nlevels) eq 0 then nlevels = 8 & levelscon=fltarr(nlevels)                 
    levelscon(0)=zmin+(findgen(nlevels)+1)*(zmax-zmin) / (nlevels+1) 
    ddlev = (zmax-zmin)/(nlevels+1)
    print,ddlev,nlevels
   end
else:
endcase 

vv = size(levelscon) & n1 = vv(1) & c_labels=findgen(n1)+1. 
if n_elements(c_colors) eq 0 then c_colors = findgen(n1)*40. 

case 1 of 
(fill eq 1):      begin
;contour,fd2(i1:i2,j1:j2),loncen2(i1:i2),latcen(j1:j2),/overplot,/follow,$
 ;ystyle=1,xstyle=1,levels=levelscon,c_labels=c_labels,charsize=charsize,$
 ;charthick=charthick,c_linestyle=c_linestyle,xrange=[loncen2(i1),x2],$
 ;yrange=[latcen(j1),latcen(j2)],max_value=max_value,c_charsize=c_charsize,$
 ;c_thick=c_thick ,fill=fill,c_colors=c_colors,min_value=min_value,$
 ;xcharsize=xcharsize,ycharsize=ycharsize
contour,fd2(i1:i2,j1:j2),loncen2(i1:i2),latcen(j1:j2),/overplot,$
 levels=levelscon,fill=1,closed=closed,ticklen=ticklen
 
                  end
(cell_fill eq 1): begin
contour,fd2(i1:i2,j1:j2),loncen2(i1:i2),latcen(j1:j2),/overplot,$
 ystyle=1,xstyle=1,levels=levelscon,charsize=charsize,$
 charthick=charthick,xrange=[loncen2(i1),x2],ticklen=ticklen,$
 yrange=[latcen(j1),latcen(j2)],max_value=max_value,$
 cell_fill=cell_fill,c_colors=c_colors,min_value=min_value,$
 xcharsize=xcharsize,ycharsize=ycharsize,closed=closed  
                  end 
else:             begin 
contour,fd2(i1:i2,j1:j2),loncen2(i1:i2),latcen(j1:j2),/overplot,/follow,$
 ystyle=1,xstyle=1,levels=levelscon,c_labels=c_labels,charsize=charsize,$
 charthick=charthick,c_linestyle=c_linestyle,xrange=[loncen2(i1),x2],$
 yrange=[latcen(j1),latcen(j2)],max_value=max_value,c_charsize=c_charsize,$
 c_thick=c_thick ,fill=fill,min_value=min_value,closed=closed,$
 xcharsize=xcharsize,ycharsize=ycharsize,ticklen=ticklen 
                  end 
endcase 

map_continents,countries=countries
 
return 
end 
