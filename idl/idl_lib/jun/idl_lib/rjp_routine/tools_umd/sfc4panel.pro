;+
; NAME:  
;   sfc4panel.pro
;         
; PURPOSE:
;   Create 4 surface panel
;   
; KEYWORD PARAMETERS:  
;        
;    lons       String array containing longitude (degs) for western and eastern edges of
;                contour plot  (def: loncen(0),loncen(ilmm-1))
;    lats       String array containing latitude (degs) for southern and northern edges of
;                contour plot (def: latcen(0),latcen(ijmm-1))
;    levelscon  Array containing desired contour levels  
;    title      String array containing title of plot
;
; WARNINGS:
;    Procedure assumes data aligned from 0 to 360E. 
; 
; MODIFICATION HISTORY:  
;   Initial version  10 June 1998 
;
;  
;-
pro sfc4panel,fd=fd,lons=lons,title=title,lats=lats,xtitle=xtitle,ytitle=ytitle,$
 levelscon=levelscon,map_color=map_color,con_color=con_color,usa=usa,$
 ikmm=ikmm,nlevels=nlevels,spt=spt,lformat=lformat,$
 charsize=charsize,noerase=noerase,levdef=levdef,$
 charthick=charthick,loncen=loncen,latcen=latcen,c_linestyle=c_linestyle,$
 xpt=xpt,ypt=ypt,c_thick=c_thick,stitle=stitle,$
 xticks=xticks,yticks=yticks,max_value=max_value,min_value=min_value,$
 c_charsize=c_charsize,latdel=latdel,londel=londel,$
 c_colors=c_colors,countries=countries,nsposlonlab=nsposlonlab,$
 xcharsize=xcharsize,ycharsize=ycharsize  

if n_elements(lformat) eq 0 then lformat = '(i4)'
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
if n_elements(charsize) eq 0 then charsize = 1
if n_elements(charthick) eq 0 then charthick = 1 
if n_elements(ikmm) eq 0 then ikmm = 20 
if n_elements(noerase) eq 0 then noerase = 0 
if n_elements(lons) eq 0 then lons = [-180.,180.]
if n_elements(lats) eq 0 then lats = [-90.,90.]  
if n_elements(title) eq 0 then title = '' 
if n_elements(xticks) eq 0 then xticks = 6
if n_elements(yticks) eq 0 then yticks = 6 
if n_elements(c_charsize) eq 0 then c_charsize = 0.75*charsize  
if n_elements(c_thick) eq 0 then c_thick = 2. 
if n_elements(stitle) eq 0 then stitle = ['','','','']  

xmargin=[6,6] 
ymargin = [0,6]
if n_elements(levelscon) eq 0 then levelscon = findgen(11)*max(fd)/10.
nlevels = size(levelscon) & nlevels = nlevels(1)-1  
if n_elements(c_colors) eq 0 then c_colors=[255,255./(2.*nlevels)+findgen(nlevels-1)*255./(nlevels-1)]

dx = lons(1)- lons(0)
dy = lats(1)- lats(0) 
fd = fd < levelscon(nlevels)*0.999
string2 = string(format=lformat,levelscon) & string2 = strtrim(string2,2) 
for iobs=0,3 do begin
   case iobs of
   0: begin & noerase = 0 & multi = [0,2,3]   & end
   1: begin & noerase = 1 & multi = [5,2,3] & end
   2: begin & noerase = 1 & multi = [4,2,3] & end
   3: begin & noerase = 1 & multi = [3,2,3] & end
   else:
   end
  
   sfc,fd=fd(*,*,iobs),levelscon=levelscon,title=stitle(iobs),xticks=xticks,yticks=yticks,$
      charsize=charsize,charthick=2.5,multi=multi,noerase=noerase,xmargin=xmargin,ymargin=ymargin,$
      lats=lats,lons=lons,fill=1,c_colors=c_colors,xcharsize=xcharsize,ycharsize=ycharsize,$
      loncen=loncen,latcen=latcen
   if (iobs eq 0) then xyouts,lons(1)+dx*0.2,lats(1)+dy*0.4,title,charthick=2.5,charsize=1.5,alignment=0.5
   !p.multi = [1,0,3]
   field = fltarr(nlevels+1,nlevels+1)
   for i=0,nlevels do field(i,*) = levelscon(i) 

   contour,field,fill=1,levels=levelscon,c_colors=c_colors,ymargin=[12,12],xticks=1,yticks=1,$
    ticklen=0,xmargin=[8,8],xstyle=5,ystyle=4 
   print,nlevels 
   for i=0,nlevels do xyouts,i,-5,string2(i),charthick=2.5,charsize=1.2,alignment=0.5
endfor

return 
end
