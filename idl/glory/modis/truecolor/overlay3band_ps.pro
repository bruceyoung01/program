
pro overlay3band_ps, cch1, cch2, cch3, llat, llon, np, nl,  filedir, filename 

  ; scale each channel from 0 ~ 255
    mag = 2.
    ch1  = congrid(cch1, np*mag, nl*mag)
    ch2  = congrid(cch2, np*mag, nl*mag)
    ch3  = congrid(cch3, np*mag, nl*mag)

;    ch1=hist_equal(bytscl(ch1*1.0))
;    ch2=hist_equal(bytscl(ch2*1.0))
;    ch3=hist_equal(bytscl(ch3*1.0))

  ; set output device : ps file

    set_plot, 'ps'
    device, filename = filedir+filename + '.ps', xoffset=0.5, yoffset=0.5, $
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
    lat =  congrid(llat, np*mag, nl*mag, /interp)
    lon =  congrid(llon, np*mag, nl*mag, /interp)

  ; result = ch1
  ; set up map
    region_limit = [min(lat)-2, min(lon)-2, max(lat)+2, max(lon)+2]
    position = [0.05, 0.31, 0.95, 0.87]
    xl = region_limit(1)
    yb = region_limit(0)
    xr = region_limit(3)
    yt = region_limit(2)


;    region_limit = [39, -108, 45, -91]
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

