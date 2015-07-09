;+
; NAME:  
;   zonalpanel.pro
;         
; PURPOSE:
;   Create 4 surface panel
;   
; KEYWORD PARAMETERS:  
;        
;
; WARNINGS:
;    Procedure assumes data aligned from 0 to 360E. 
; 
; MODIFICATION HISTORY:  
;   Initial version  10 June 1998 
;
;  
;-
pro zonalpanel,fd,dlatcen,ht,c_colors=c_colors,levels=levels,xrange=xrange,yrange=yrange,$
 charthick=charthick,charsize=charsize,lformat=lformat,title=title,bartitle=bartitle,$
 htscale=htscale

if n_elements(xrange) eq 0 then xrange = [-90.,90.]

aa = size(ht) & nhts = aa(1) & htmax = ht(nhts-1)  
if n_elements(yrange) eq 0 then yrange = [0.,htmax] 
if n_elements(charthick) eq 0 then charthick = 2.5
if n_elements(charsize) eq 0 then charsize = 1.2 
if n_elements(lformat) eq 0 then lformat = '(i4)'
if n_elements(xticks) eq 0 then xticks = 6 
if n_elements(bartitle) eq 0 then bartitle = '' 
if n_elements(htscale) eq 0 then htscale = 8. 

aa = size(fd) 

case aa(0) of 
3: begin  
ijmm = aa(1) & ikmm = aa(2) & ncon = aa(3) 
   end
2: begin
ijmm = aa(1) & ikmm = aa(2) & ncon = 1 
   end
else:
endcase 

if n_elements(levels) eq 0 then levels = findgen(11)*max(fd)/10.
nlevels = size(levels) & nlevels = nlevels(1)-1  

amax = max(fd,min=amin)
levels1 = levels
levels1(0) = amin & levels1(nlevels) = amax > levels1(nlevels)   



if n_elements(c_colors) eq 0 then c_colors=[255,255./(2.*nlevels)+findgen(nlevels-1)*255./(nlevels-1)]
case n_elements(title) of
0: begin
    title = strarr(ncon) & title(*) = ''
   end
else:
endcase 

noerase = lonarr(ncon) & multi = lonarr(3,ncon) 

xmargin=[6,6] 
ymargin = [0,6]

case ncon of 
1: !p.multi = [0,0,2] 
2: !p.multi = [0,2,2] 
3: !p.multi = [0,2,3]
4: !p.multi = [0,2,3]  
5: !p.multi = [0,3,3] 
6: !p.multi = [0,3,3] 
else:
endcase 

nn = size(levels1) & nn = nn(1) 
c_labels = replicate(1,nn) 

pmin = 1000.*exp(-yrange(1)/htscale) 
string2 = string(format=lformat,levels1) & string2 = strtrim(string2,2) 
c_annotation = string2
for iobs=0,ncon-1 do begin 
   contour,fd(*,*,iobs),dlatcen,ht,fill=1,c_colors=c_colors,charsize=charsize,charthick=charthick,$
    xrange=xrange,yrange=yrange,levels=levels1,title=title(iobs),ystyle=8,xstyle=1,$
    xticks=xticks,xmargin=[9,9],yticklen=-0.02,ytitle='Ht (km)',xtitle='Latitude',$
    ymargin=[4,4]  
   axis,yaxis=1,yrange=[1000.,pmin],ystyle=1,ytitle='Pressure (hPa)',charsize=charsize,$
    charthick=2.5,/ylog,yticklen=-0.02 
   contour,fd(*,*,iobs),dlatcen,ht,/overplot,levels=levels1,/follow,$
    c_labels = c_labels,charthick=2.5,charsize=1.5,c_annotation=c_annotation
endfor 

!p.multi = [1,0,3]
field = fltarr(nlevels+1,nlevels+1)
for i=0,nlevels do field(i,*) = levels1(i) 

contour,field,fill=1,levels=levels1,c_colors=c_colors,ymargin=[12,12],xticks=1,yticks=1,$
 ticklen=0,xmargin=[8,8],xstyle=5,ystyle=4 


for i=0,nlevels do xyouts,i,-5,string2(i),charthick=2.5,charsize=1.2,alignment=0.5
xyouts,nlevels*0.5,-15,bartitle,alignment=0.5,charsize=1.2,charthick=2.5
return 
end
