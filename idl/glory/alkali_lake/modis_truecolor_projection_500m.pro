
pro overlay, ch1, ch2, ch3, lat, lon, np, nl, filename, OutPutName

  ; scale each channel from 0 ~ 255
    mag = 3
    ch1  = congrid(ch1, np*mag, nl*mag)
    ch2  = congrid(ch2, np*mag, nl*mag)
    ch3  = congrid(ch3, np*mag, nl*mag)

;    ch1=hist_equal(bytscl(ch1*1.0))
;    ch2=hist_equal(bytscl(ch2*1.0))
;    ch3=hist_equal(bytscl(ch3*1.0))

  ; set output device : ps file

    set_plot, 'ps'
    device, filename = OutPutName, xoffset=0.5, yoffset=0.5, $
          xsize=7, ysize=10, /color, /inches, bits =8

    rr = bytarr(256) & rr(255) = 255 & rr(254)=0 
    gg = bytarr(256) & gg(255) = 255 & gg(254)=0
    bb = bytarr(256) & bb(255) = 255 & bb(254)=0

  ; create color tables and color indices
        result = color_quan(ch1, ch2, ch3, r, g, b, colors=254)
        rr(0:253) = r(0:253) 
        gg(0:253) = g(0:253) 
        bb(0:253) = b(0:253) 
        tvlct, rr, gg, bb
        lat =  congrid(lat, np*mag, nl*mag, /interp)
        lon =  congrid(lon, np*mag, nl*mag, /interp)

      ; result = ch1
 ;set up map
;    region_limit = [min(lat)-2, min(lon)-2, max(lat)+2, max(lon)+2]
     region_limit = [40, -105, 45, -100]
     position = [0.05, 0.31, 0.95, 0.87]
     xl = region_limit(1)
     yb = region_limit(0)
     xr = region_limit(3)
     yt = region_limit(2)

     map_set, /continent,$
     charsize=1, mlinethick = 4, $
     position=position, $
     limit = region_limit,/usa, color=254,con_color=254


     color_imagemap, result, lat, lon, /current, missing = 255 

     map_set,  /continent, /USA, $
     charsize=1, mlinethick = 4, $
     position=position, $
     limit = region_limit,/noerase, color=254,con_color=254

   xyouts, (position(0)+position(2))/2.,  position(3)+0.02, $
           '!6Visible   ' + strmid(filename, 0, 22), color=254, $
         charsize=1.5, charthick=1.5, align = 0.5, /normal
   xyouts, (position(0)+position(2))/3.2,  position(3)-0.35, $
           '!6o', color=254, $
         charsize=1, charthick=12, align = 0.5, /normal

 plot, [xl, xr], [yb, yt], /nodata, xrange = [xl, xr], $
       yrange = [yb, yt], position =position, $
       ythick = 1, charsize = 1.0, charthick=1, xstyle=1, ystyle=1,$
       xminor = 1, color=254, yminor=1, xtick_get=xv, ytick_get=yv
 nxv = n_elements(xv)
 nyv = n_elements(yv)
  for i = 0, nxv-1 do begin
    oplot,  [xv(i), xv(i)], [yb, yt], linestyle=1, color=254
  endfor

  for i = 0, nyv-1 do begin
    oplot,  [xl, xr], [yv(i), yv(i)], linestyle=1, color=254
  endfor

  ; close device
        device, /close
    end

;
; Read HDF file 
;

filename = 'MOD02HKM.A2007145.1815.005.2007151023355.hdf'
filedir = '/home/bruce/data/modis/alkali_lake/aldata/' 

;
; Check if this file is a valid HDF file 
;
if not hdf_ishdf(filedir + filename) then begin
  print, 'Invalid HDF file ...'
  return
endif else begin
  print, 'Open HDF file : ' + filename
endelse

;
; The SDS var name we're interested in 
;
SDsvar = strarr(4)
SdSVar = ['Latitude', 'Longitude', $
         'EV_250_Aggr500_RefSB','EV_500_RefSB']

;
; get the SDS data
;

; get hdf file id 
FileID = Hdf_sd_start(filedir + filename, /read)

for i = 0, n_elements(SDSvar)-1 do begin
 thisSDSinx = hdf_sd_nametoindex(FileID, SDSVar(i))
 thisSDS = hdf_sd_select(FileID, thisSDSinx)
 hdf_sd_getinfo, thisSDS, NAME = thisSDSName, $
                 Ndims = nd, hdf_type = SdsType
   print, 'SDAname ', thisSDSname, ' SDS Dims', nd, $
          ' SdsType = ',  strtrim(SdsType,2)

  ; dimension information
   for kk = 0, nd-1 do begin		   
   DimID =   hdf_sd_dimgetid( thisSDS, kk)
   hdf_sd_dimget, DimID, Count = DimSize, Name = DimName  
   print, 'Dim  ', strtrim(kk,2), $
          ' Size = ', strtrim(DimSize,2), $
          ' Name  = ', strtrim(DimName)
	   
   if ( i eq 2 ) then begin
     if ( kk eq 0) then np = DimSize    ; dimension size
     if ( kk eq 1) then nl = DimSize    
   endif
      	  
   endfor
   
  ; end of entering SDS
  hdf_sd_endaccess, thisSDS 
  
  ; get data
   HDF_SD_getdata, thisSDS, Data
   if (i eq 0) then flat = data
   if (i eq 1) then flon = data
   if (i eq 2) then ref250 = data  ; 1km
   if (i eq 3) then ref500 = data ; 250 merged to 1km 
  
  ; print get one SDS var data is over
  print, '========= one SDS data is over ========='
  
endfor

; end the access to sd
  hdf_sd_end, FileID

; start color plot

red = bytarr(np,nl)
green = bytarr(np,nl)
blue = bytarr(np,nl)

; manupilate data and enhance the image
red(0:np-1,0:nl-1)   = hist_equal(bytscl(ref250(0:np-1, 0:nl-1, 0)))
green(0:np-1,0:nl-1) = hist_equal(bytscl(ref500(0:np-1, 0:nl-1, 1)))
blue(0:np-1,0:nl-1)  = hist_equal(bytscl(ref500(0:np-1, 0:nl-1, 0)))


; write the image into tiff , note Aqua images need reverse

;  write_tiff, 'overlay-new.tif', red=reverse(reverse(red,2),1), $
;               green= reverse(reverse(green,2), 1), $ 
;	       blue=reverse(reverse(blue,2), 1),$ 
;	       PLANARCONFIG=2


; mapping
; map limit
  win_x = 800 
  win_y = 700 

; pixel after reprojection, default is while pixel  
  newred = bytarr(win_x, win_y)+255
  newgreen = bytarr(win_x, win_y)+255
  newblue = bytarr(win_x, win_y)+255

; MODIS only gives lat and lon not 1km resolution
; hence, interpolation is needed to have every 1km pixel
; has lat and lon 

  flat =  congrid(flat, np, nl, /interp)
  flon =  congrid(flon, np, nl, /interp)

; select region limit
;  region_limit = [min(flat)-2, min(flon)-2, max(flat)+2, max(flon)+2]
     region_limit = [40, -105, 45, -100]
; set plot position

  xa = 0.05
  ya = 0.05
  xb = 0.95
  ybb = 0.95
  xl = region_limit(1)
  yb = region_limit(0)
  xr = region_limit(3)
  yt = region_limit(2)


;  set_up window
  set_plot, 'x' 
  device, retain=2
  !p.background=255L + 256L * (255+256L *255)
  !p.multi = [0, 1, 2]
  
  window, 1, xsize=win_x, ysize=win_y  
  map_set, /continent, $
        charsize=0.8, mlinethick = 2,$
	limit = region_limit, color = 254, /USA, $
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
	limit = region_limit, color = 254, /USA, $
       position =[xa, ya, xb, ybb], /CYLINDRICAL

   xyouts, win_x/2.,  win_y-18, '!6Visible   ' + strmid(filename, 0, 22), color=254, $
         charsize=1.5, charthick=1.5, align = 0.5, /device
   xyouts, win_x/3.2, win_y-235, '!6o', color =254, $
         charsize=2, charthick=7, align = 0.5, /device


 plot, [xl, xr], [yb, yt], /nodata, xrange = [xl, xr], $
       yrange = [yb, yt], position =[xa, ya, xb, ybb], $
       ythick = 1, charsize = 1.5, charthick=1, xstyle=1, ystyle=1,$
       xminor = 1, color=254, yminor=1, xtick_get=xv, ytick_get=yv

; plot grid line
 nxv = n_elements(xv)
 nyv = n_elements(yv)
  for i = 0, nxv-1 do begin
    oplot,  [xv(i), xv(i)], [yb, yt], linestyle=1, color=254
  endfor

  for i = 0, nyv-1 do begin
    oplot,  [xl, xr], [yv(i), yv(i)], linestyle=1, color=254
  endfor

 image = tvrd(true=1, order=1)
 write_png, filedir + strmid(filename, 0, 22)+'.png', $
            image, /order 

overlay, red, green, blue, flat, flon, np, nl, filename, 'overlay500m.ps' 

end

