
PRO overlay3band_img, win_x, win_y, rred, ggreen, bblue, lat, lon, np, nl, filedir, filename

; mapping
; map limit
;  region_limit = [20, -158, 50, -120]
;  win_x = 800 
;  win_y = 700 

; don't change the input
 red = rred
 green = ggreen 
 blue = bblue 

; pixel after reprojection, default is while pixel  
  newred = bytarr(win_x, win_y)+255
  newgreen = bytarr(win_x, win_y)+255
  newblue = bytarr(win_x, win_y)+255

; MODIS only gives lat and lon not 1km resolution
; hence, interpolation is needed to have every 1km pixel
; has lat and lon 

  flat =  congrid(lat, np, nl, /interp)
  flon =  congrid(lon, np, nl, /interp)

; select region limit
  region_limit = [min(flat)-2, min(flon)-2, max(flat)+2, max(flon)+2]

; set plot position
  xa = 0.05
  ya = 0.05
  xb = 0.95
  ybb = 0.95
  xl = region_limit(1)
  yb = region_limit(0)
  xr = region_limit(3)
  yt = region_limit(2)


; set up window
  set_plot, 'x' 
  device, retain=2
  !p.background=255L + 256L * (255+256L *255)
  !p.multi = [0, 1, 2]
  
  window, 1, xsize=win_x, ysize=win_y  
  map_set, /continent, $
        charsize=0.8, mlinethick = 2,$
	limit = region_limit, color = 0, /USA, $
        position=[xa, ya, xb, ybb], /CYLINDRICAL

; ship coordinate
  imax = 0 
  imin = np 
  jmin = nl 
  jmax = 0 
  for i = 0, np-1 do begin
  for j = 0, nl-1 do begin
  result = convert_coord(flon(i,j), flat(i,j), /data, /to_device)
  newcoordx  = result(0)
  newcoordy  = result(1)
  if (newcoordx lt win_x and newcoordy lt win_y and $
      newcoordx gt 0 and newcoordy gt 0) then begin
  newred(newcoordx, newcoordy) = red(i,j)
  newgreen(newcoordx, newcoordy)=green(i,j)
  newblue(newcoordx, newcoordy) =blue(i,j)
  if ( imax lt i) then imax = i
  if ( imin gt i ) then imin = i
  if ( jmax lt j) then jmax = j
  if ( jmin gt j ) then jmin = j
  endif
  endfor
  endfor  
  print, 'i range', imax, imin  
  print, 'j range', jmax, jmin 

; display the reprojecte image
 tv, [[[newred]], [[newgreen]], [[newblue]]], true=3 

; redraw the map with noerase opition
  map_set, /noerase, /continent, $
         charsize=0.8, mlinethick = 2,$
	limit = region_limit, color = 0, /USA, $
       position =[xa, ya, xb, ybb], /CYLINDRICAL

   xyouts, win_x/2.,  win_y-18, '!6Visible   ' + strmid(filename, 0, 22), color=0, $
         charsize=1.5, charthick=1.5, align = 0.5, /device

 plot, [xl, xr], [yb, yt], /nodata, xrange = [xl, xr], $
       yrange = [yb, yt], position =[xa, ya, xb, ybb], $
       ythick = 1, charsize = 1.5, charthick=1, xstyle=1, ystyle=1,$
       xminor = 1, color=0, yminor=1, xtick_get=xv, ytick_get=yv
 xyouts, 200, 300, 'sea', /device
 xyouts, 100, 50, 'cloud', /device

; plot grid line
 nxv = n_elements(xv)
 nyv = n_elements(yv)
  for i = 0, nxv-1 do begin
    oplot,  [xv(i), xv(i)], [yb, yt], linestyle=1, color=0
  endfor

  for i = 0, nyv-1 do begin
    oplot,  [xl, xr], [yv(i), yv(i)], linestyle=1, color=0
  endfor
; xyouts, 200, 300, 'sea'
; xyouts, 100, 50, 'cloud'
; write image into the file
; read current window content 

; write to tiff or jpeg
 image = tvrd(true=3, order=1)
 write_tiff,  'projected.tif', image, $
             PLANARCONFIG=2
 write_jpeg, filedir + strmid(filename, 0, 22)+'.jpg', $
             image, true=3, /order, quality=100

; write to png
 image = tvrd(true=1, order=1)
 write_png, filedir + filename+'.png', $
            image, /order 


end

