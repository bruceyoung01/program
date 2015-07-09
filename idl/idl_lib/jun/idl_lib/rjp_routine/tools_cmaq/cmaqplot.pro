pro cmaqplot,fd,Level=level,Pos=pos,Vertical=vertical,Noerase=noerase,Title=title,$
    twait=twait,format=format,Grid=grid,lat=lat,lon=lon,cline=cline,shade=shade,$
    unit=unit,colorT=colorT

if n_elements(lat) eq 0 then return
if n_elements(lon) eq 0 then return
if n_elements(POS) eq 0 then pos = [0.15,0.2,0.85,0.85]
if n_elements(title) eq 0 then title=''
if n_elements(unit) eq 0 then unit=''
if n_elements(twait) eq 0 then twait = 0.
if n_elements(colorT) eq 0 then colorT = 13

if n_elements(level) eq 0 then begin
 nl = 10
 inc = (max(fd)-min(fd))/float(nl-1)
 level = fltarr(nl)
 for i = 0, nl-1 do begin
  level[i] = min(fd)+float(i)*inc
 end
endif else begin
 nl = n_elements(level)
end


if KEYWORD_SET(shade) then begin
  loadct, colorT, ncolors=nl+1, bottom=0
; loadct_rjp, ncolors=nl+1
 ctable = indgen(nl)+1
endif

if(!D.name ne 'PS') then device, decomposed=0

!p.position = pos

 dim = size(lat,/dim)
lat0 = lat(0,0) & lon0 = lon(0,0)
lat1 = lat(0,dim(1)-1) & lon1 = lon(0,dim(1)-1)
lat2 = lat(dim(0)-1,dim(1)-1) & lon2 = lon(dim(0)-1,dim(1)-1)
lat3 = lat(dim(0)-1,0) & lon3 = lon(dim(0)-1,0)

 latmin = min(lat)
 latmax = max(lat)
 lonmin = min(lon)
 lonmax = max(lon)

;map_set,45.,-90.,/noerase,title=Title,     $
;        Limit=[latmin,lonmin,latmax,lonmax],charsize=2.0,/cyl

 map_set,45.,-90.,/noerase,title=Title,    $
 Limit=[lat0,lon0,lat1,lon1,lat2,lon2,lat3,lon3],charsize=1.2,/cyl,color=0

 if keyword_set(shade) then $
  contour,fd,lon,lat,/cell_fill,c_colors=ctable,levels=level, $
  xstyle=1,ystyle=1,/overplot,/normal
 if keyword_set(cline) then $
  contour,fd,lon,lat,levels=level,xstyle=1,ystyle=1,$
  /overplot,/normal,/follow,c_thick=1.5,color=0

 if keyword_set(grid) then $
  map_grid, label=1, latlab=lon[0,0],latalign=0.0,lonlab=lat[0,0], $
  lonalign=0.5, londel=2,color=0

 map_continents,/usa,color=0

 if keyword_set(shade) then begin

 if KEYWORD_SET(vertical) then begin
  cbar, clevel=level,/vertical,format=format, unit=unit
 endif else begin
  cbar, clevel=level,format=format, unit=unit
 endelse

 endif

wait, twait

end
