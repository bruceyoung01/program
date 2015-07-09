pro cmaqplot,fd,Level=level,Pos=pos,Vertical=vertical,Noerase=noerase,Title=title,$
    twait=twait,format=format


if n_elements(POS) eq 0 then pos = [0.15,0.2,0.85,0.85]
if n_elements(title) eq 0 then title=''
 dim = size(fd,/dim)

if n_elements(twait) eq 0 then twait = 0.

if n_elements(level) eq 0 then begin
 nl = 13
 inc = (max(fd)-min(fd))/float(nl-1)
 level = fltarr(nl)
 for i = 0, nl-1 do begin
  level[i] = min(fd)+float(i)*inc
 end
endif else begin
 nl = n_elements(level)
end

loadct_rjp, ncolors=nl+1
;device, decomposed=0
ctable = indgen(nl)+1

!p.position = pos
erase

lat = rdcmaq('/data/storm1/stone/data/cmaq/mcip/GRIDCRO2D_G1','LAT')
lon = rdcmaq('/data/storm1/stone/data/cmaq/mcip/GRIDCRO2D_G1','LON')

lat0 = lat(0,0) & lon0 = lon(0,0)
lat1 = lat(0,dim(1)-1) & lon1 = lon(0,dim(1)-1)
lat2 = lat(dim(0)-1,dim(1)-1) & lon2 = lon(dim(0)-1,dim(1)-1)
lat3 = lat(dim(0)-1,0) & lon3 = lon(dim(0)-1,0)

;map_set,40.,-90.,/noerase,title=Title,/cyl,     $
;        Limit=[35.5,-89.7,45.5,-72.0],charsize=2.0

map_set,40.,-90.,/noerase,title=Title,/merca,     $
        Limit=[lat0,lon0,lat1,lon1,lat2,lon2,lat3,lon3],charsize=2.0


contour,fd,lon,lat,/cell_fill,c_colors=ctable,levels=level, $
xstyle=1,ystyle=1,/normal,/overplot

;map_grid,/label
map_continents,/usa

if KEYWORD_SET(vertical) then begin
 cbar, clevel=level,/vertical,format=format
endif else begin
 cbar, clevel=level,format=format
endelse

wait, twait

end
