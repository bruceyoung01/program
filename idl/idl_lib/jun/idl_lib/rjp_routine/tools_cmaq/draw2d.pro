pro draw2d,fd2d,lon=lon,lat=lat,level=level

if n_elements(level) eq 0 then begin
 nl = 10
endif else begin
 nl = n_elements(level)
end

if n_elements(lon) eq 0 then begin
 dim = size(data,/dimensions)
 dx  = 360./dim(0)
 dy  = 180./dim(1)
 lon = -180.+ dx*indgen(dim(0))
 lat = (-90.+dy/2.) + dy*indgen(dim(1))
endif

map_set, 0, 0,/isotropic,/continent,/grid,/label,mlinestyle=1,/noerase
contour,fd2d,lon,lat,nlevels=nl,levels=level,/overplot,c_thick=1.5,c_labels=replicate(1,nl)

end
