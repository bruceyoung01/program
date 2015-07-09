pro mapimage,fd,lon,lat,level=level,POS=pos,VERTICAL=vertical,twait=twait,$
    Title=title,xlon=xlon,ylat=ylat,Shaded=shaded,Cline=cline,Grid=grid,$
    maxval=maxval,minval=minval,divisions=divisions

 if n_elements(POS) eq 0 then pos = [0.10,0.10,0.85,0.85]
 if n_elements(twait) eq 0 then twait = 0.1
 if n_elements(title) eq 0 then title=''
 if n_elements(divisions) eq 0 then divisions = 11
 if n_elements(maxval) eq 0 then maxval = max(fd)
 if n_elements(minval) eq 0 then minval = min(fd)

 barpos = [pos[2]+0.02,pos[1],pos[2]+0.06,pos[3]]

if n_elements(level) eq 0 then begin

 dim = size(fd, /dimension)
 inc = (max(fd)-min(fd))/float(divisions-1)
 level = fltarr(divisions)
 for i = 0, divisions-1 do begin
  level[i] = min(fd)+float(i)*inc
 end
endif else begin
 divisions = n_elements(level)
end

if n_elements(lon) eq 0 then begin
 dim = size(fd,/dimensions)
 dx  = 360./dim(0)
 dy  = 180./(dim(1)-1)
 lon = -180.+ dx*findgen(dim(0))
 lat = -90.+ dy*findgen(dim(1))
endif

if n_elements(xlon) eq 0 then xlon= [min(lon),max(lon)]
if n_elements(ylat) eq 0 then ylat= [min(lat),max(lat)]

if KEYWORD_SET(shaded) then begin
 ncolors = !d.table_size-2
 loadct, 13, ncolors=ncolors, bottom=0
endif

!p.position = pos

 lonst = [lon, lon(0)+360.]
 fdst = [fd,fd(0,*)]
 nx = where( lonst ge xlon(0) and lonst le xlon(1) )
 ny = where( lat ge ylat(0) and lat le ylat(1) )
 i1 = min(nx) & i2 = max(nx)
 j1 = min(ny) & j2 = max(ny)
 limit = [ylat[0],xlon[0],ylat[1],xlon[1]]

 map_set,/cylindrical,0.,0.,/continent,title=Title, $
        charsize=1.8, /noerase, Limit=limit, color=!p.color

 if keyword_set(shaded) then begin 
  image = bytscl(fdst(i1:i2,j1:j2),min=minval,max=maxval,top=ncolors)
  projec= map_patch(image,lonst(i1:i2),lat(j1:j2),xstart=x0,ystart=y0,xsize=xs,ysize=ys)
;  tv, projec, x0, y0, xsize=xs,ysize=ys
  tvimage, projec, /overplot

  colorbar, position=barpos,range=[minval,maxval],/vertical,$
  format='(f5.3)',/right,ncolors=ncolors,color=!p.color,charsize=1.8,$
  divisions=divisions
 endif
 if keyword_set(cline) then $
  contour,fdst(i1:i2,j1:j2),lonst(i1:i2),lat(j1:j2),levels=level,xstyle=1,ystyle=1,$
  /overplot,/normal,/follow,c_thick=1.8,max_value=maxval
  
 if keyword_set(grid) then map_grid, /label, latlab=xlon[0],latalign=0.0,lonlab=ylat[0],lonalign=0.5, $
   charsize = 1.0

 map_set,/cylindrical,0.,0.,/continent,/noerase, Limit=limit,color=!p.color,/usa

wait, twait

end
