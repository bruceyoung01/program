pro plpol,fd=fd,polat=polat,polon=polon,orthographic=orthographic,$
 stereographic=stereographic,charsize=charsize,continents=continents,$
 grid=grid,label=label,dloncen=dloncen,dlatcen=dlatcen,multi=multi,$
 countries=countries,title=title,max_value=max_value,xmargin=xmargin,$
 ymargin=ymargin

if n_elements(polat) eq 0 then polat = 90. 
if n_elements(polon) eq 0 then polon = -90. 
if n_elements(stereograhic) eq 0 then stereographic = 1
if n_elements(orthographic) eq 0 then orthographic = 0 
if n_elements(charsize) eq 0 then charsize = 1. 
if n_elements(continents) eq 0 then continents = 1. 
if n_elements(grid) eq 0 then grid = 1
if n_elements(label) eq 0 then label = 0 
if n_elements(multi) eq 0 then multi = 0. 
if n_elements(title) eq 0 then title = ''
if n_elements(countries) eq 0 then countries = 0 
if n_elements(max_value) eq 0 then max_value = max(fd) 
if n_elements(xmargin) eq 0 then xmargin = [6,6]
if n_elements(ymargin) eq 0 then ymargin = [6,6] 

aa = where(fd gt max_value,nsize) 
if (nsize gt 0) then fd(aa) = max_value

!p.multi = multi 
nsize = size(fd) & ilmm = nsize(1) & ijmm = nsize(2) 

case n_elements(dlatcen) of
0: dlatcen = -90. + findgen(ijmm)*180./(ijmm-1) 
else:
endcase     
case n_elements(dloncen) of
0: dloncen = -180. + findgen(ilmm)*360./ilmm  
else:
endcase 

if (orthographic eq 1) then stereographic = 0 
map_set,polat,polon,orthographic=orthographic,stereographic=stereographic,$
 charsize=charsize,continents=continents,grid=grid,label=label,title=title,$
 /advance

nsize = size(fd) & ilmm = nsize(1) & ijmm = nsize(2) 

result = map_patch(fd,dloncen,dlatcen,max_value=max_value,$
 xsize=xsize,ysize=ysize,xstart=x0,ystart=y0)

tvscl,result
;tvscl,map_patch(fd,dloncen,dlatcen,max_value=max_value,$
; xsize=xsize,ysize=ysize,xstart=x0,ystart=y0)

map_grid
map_continents,countries=countries
map_horizon

return
end 
