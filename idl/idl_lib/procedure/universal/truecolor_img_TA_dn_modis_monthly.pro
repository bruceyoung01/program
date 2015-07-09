;  $ID: truecolor_img_TA_dn_modis_monthly.pro V01 06/08/2012 22:44 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE truecolor_img_TA_dn_modis_monthly PLOTS MODIS TRUE COLOR IMAGE, 
;  INCLUDING TERRA AND AQUA, WITH FIRE COUNTS(DAYTIME AND NIGHTTIME), ALSO 
;  OUTPUT FIRE COUNTS FILE.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;  NOTES:
;  ============================================================================
;  (1 ) MODIFIED BY BRUCE FROM PREVIOUS VERSION. (06/08/2012)
;  (2 ) ADD TO OUTPUT FIRE COUNTS FILE BY BRUCE. (06/08/2012)
;******************************************************************************

   PRO truecolor_img_TA_dn_modis_monthly,           $
       red=red, green=green, blue=blue,             $
       flat = flat, flon= flon, mag = mag,          $
       region = region, winx=winx, winy=winy,       $
       outputname = outputname, latdel =latdel,     $
       londel = londel, latlab = latlab,            $
       lonlab = lonlab, dtfirelat = dtfirelat,      $
       dtfirelon = dtfirelon,ntfirelat = ntfirelat, $
       ntfirelon = ntfirelon,title=title,           $
       dlun = dlun, nlun = nlun
            
    np = n_elements(red(*,0))
    nl = n_elements(red(0,*))

    if (not keyword_set(region)) then begin
       region = [min(flat)-2, min(flon)-2, max(flat+2), max(flon+2)]
    endif

    if (not keyword_set(OutPutName)) then begin
      print, 'No output file name is specified'
      print, 'File will be saved as jpeg'
      OutPutName = 'overlay' 
    endif

    if (not keyword_set(mag)) then begin
      mag = 1
    endif
 
    if (not keyword_set(winx)) then begin
     winx = 700 
    endif

    if (not keyword_set(winy)) then begin
     winy = 500 
    endif

    if (not keyword_set(londel)) then begin
     londel = 10 
    endif

    if (not keyword_set(latdel)) then begin
     latdel = 10 
    endif
    
    if (not keyword_set(latlab)) then begin
     latlab = region(1)-1.5 
    endif

    if (not keyword_set(lonlab)) then begin
     lonlab = region(0)-1 
    endif

 ; pixel after reprojection, default is white pixel  
   newred = bytarr(winx, winy)+255
   newgreen = bytarr(winx, winy)+255
   newblue = bytarr(winx, winy)+255

 ; MODIS only gives lat and lon not 1km resolution
 ; hence, interpolation is needed to have every 1km pixel
 ; has lat and lon 
   if ( mag gt 1 ) then begin
   np = np*mag
   nl = nl*mag
   red  = congrid(red,   np, nl, /interp)
   green= congrid(green, np, nl, /interp)
   blue = congrid(blue,  np, nl, /interp)
   flat = congrid(flat,  np, nl, /interp)
   flon = congrid(flon,  np, nl, /interp)
   endif

 ; set up window
   set_plot, 'x'
   device, retain=2
   window, 1, xsize=winx, ysize=winy
 ; !p.background=255L + 256L * (255+256L *255)

   map_set, latdel = latdel, londel =londel,   $
         /grid, charsize=2.0, mlinethick = 2,  $
        limit = region, title=title, color = 1,$
        position = [0.1, 0.1, 0.9, 0.9] 

 ; ship coordinate
   imax = 0
   imin = np*1LL
   jmin = nl*1LL
   jmax = 0
   for i = 0LL, np-1LL do begin
   for j = 0LL, nl-1LL do begin
     if ( flon(i,j) ge region(1) and flon(i,j) le region(3) $
          and flat(i,j) ge region(0) and flat(i,j) le region(2) ) then begin
      result = convert_coord(flon(i,j), flat(i,j), /data, /to_device)
      newcoordx  = result(0)
      newcoordy  = result(1)

      if (newcoordx lt winx and newcoordy lt winy and $
          newcoordx gt 0 and newcoordy gt 0 ) then begin 
         newred(newcoordx, newcoordy) = red(i,j)
         newgreen(newcoordx, newcoordy)=green(i,j)
         newblue(newcoordx, newcoordy) =blue(i,j)
    ;     if ( imax lt i) then imax = i
    ;     if ( imin gt i ) then imin = i
    ;     if ( jmax lt j) then jmax = j
    ;     if ( jmin gt j ) then jmin = j
      endif
     endif
   endfor
   endfor
   print, 'i range', imax, imin
   print, 'j range', jmax, jmin

 ; display the reprojecte image
  tv, [[[newred]], [[newgreen]], [[newblue]]], true=3

 ; redraw the map with noerase opition
   map_set, /noerase, latdel = latdel , londel = londel,  $
         /grid, charsize=3.0, mlinethick = 2,$
         limit = region, title=title, color = 1,$
         latlab = latlab, lonlab = lonlab, $
         /label, latalign=0, lonalign = 1, $
        position = [0.1, 0.1, 0.9, 0.9]

   map_continents, /hires, /coasts, /usa, color=1
  
 ;  map_grid, latdel = latdel, londel=londel, /box_axes
 
  nxg = (region(3)-region(1))/londel
  nyg = (region(2) - region(0))/latdel
  lats = region(0) + findgen(nyg+1) * latdel
  lons = region(1) + findgen(nxg+1) * londel 
  latlabs = fltarr(nyg+1)+latlab
  lonlabs = fltarr(nxg+1) + lonlab  

  xyouts, latlabs, lats, string(lats, format='(I3)'), color=1, align=0.5, charsize = 5.0
  xyouts, lons, lonlabs, string(lons, format='(I4)'), color=1, align=0.5, charsize = 5.0

; MODIFIED BY BRUCE. (03/22/2012)
  MYCT, 33
; plot fire hot spots
  if (keyword_set(dtfirelat) and keyword_set(dtfirelon)) then begin
     dtresult = where(dtfirelon ge region (1) and dtfirelat ge region(0) and $
                    dtfirelon le region(3) and dtfirelat le region(2), dtcount )
      PRINTF, dlun, outputname + '_daytime', dtcount
      PRINT,        outputname, ' Total Fire Num (Daytime) : ', dtcount
      if ( dtcount gt 0 ) then begin
       plots, dtfirelon(dtresult), dtfirelat(dtresult), psym = sym(1), $
              color = 2, symsize = 1.0
      endif
  endif
  MYCT, 33, /BRIGHT_COLORS
  if (keyword_set(ntfirelat) and keyword_set(ntfirelon)) then begin
     ntresult = where(ntfirelon ge region (1) and ntfirelat ge region(0) and $
                    ntfirelon le region(3) and ntfirelat le region(2), ntcount )
      PRINTF, nlun, outputname + '_nighttime', ntcount
      PRINT,        outputname, ' Total Fire Num (Nighttime) : ', ntcount
      if ( ntcount gt 0 ) then begin
       plots, ntfirelon(ntresult), ntfirelat(ntresult), psym = sym(1), $
              color = 3, symsize = 1.5
      endif
  endif

; MODIFIED BY BRUCE. (03/26/2012)
;  if (keyword_set(dafirelat) and keyword_set(dafirelon)) then begin
;     daresult = where(dafirelon ge region (1) and dafirelat ge region(0) and $
;                    dafirelon le region(3) and dafirelat le region(2), dacount )
;     PRINTF, lun, outputname, 'Total Fire Num (Daytime) : ', dtcount
;     PRINT,       outputname, 'Total Fire Num (Daytime) : ', dtcount
;      if ( dacount gt 0 ) then begin
;       plots, dafirelon(daresult), dafirelat(daresult), psym = sym(1), $
;              color = 2, symsize = 0.5
;      endif
;  endif
;  if (keyword_set(nafirelat) and keyword_set(nafirelon)) then begin
;     naresult = where(nafirelon ge region (1) and nafirelat ge region(0) and $
;                    nafirelon le region(3) and nafirelat le region(2), nacount )
;     PRINTF, lun, outputname, 'Total Fire Num (Nighttime) : ', ntcount
;     PRINT,       outputname, 'Total Fire Num (Nighttime) : ', ntcount
;      if ( nacount gt 0 ) then begin
;       plots, nafirelon(naresult), nafirelat(naresult), psym = sym(1), $
;              color = 3, symsize = 0.5
;      endif
;  endif
; plot tornado events

;  TimePeriod = [0, 4, 8, 12, 16, 20, 24]
;  red   = [0,   0,   0,  255, 255, 76 ]
;  green = [0,   0, 255,  255, 126,  0 ]
;  blue  = [0, 255,   0,    0,   0,  38 ]
 ; colors = red*1L * 256L *(green*1L + 256L * blue*1L)


  if (keyword_set(tornadolat) and keyword_set(tornadolon)) then begin
     result = where(tornadolon ge region (1) and tornadolat ge region(0) and $
                    tornadolon le region(3) and tornadolat le region(2), count )
      print, 'total tornado num: ', count 
      if ( count gt 0 ) then begin     
            for i = 0, count-1 do begin   ; comparing tornado timing with MODIS timing
              inx = result(i)
              
;              result1 = where(TimePeriod ge tornadotime(inx)/100., count1)
;              if count1 lt 0 then stop
;              colorinx = result1(0)-1 
              plots, tornadolon(inx), tornadolat(inx), psym = sym(4), $
                      color = 0, symsize = 2.5 

; the following is plotted the tornado events before and after the
; satellite impages 
;              result1 = where( abs(flat - tornadolat(inx)) le 1 and $
;                              abs(flon - tornadolon(inx)) le 1, count1)
;              if ( count1 ge 0 ) then begin
;                   cnl = result1(0)/np
;                   cnp = result1(0) - cnl*np
;                   print, 'mod lat and lon:', flat(cnp, cnl), flon(cnp, cnl)
;                   print, 'tor lat and lon :', tornadolat(inx), tornadolon(inx) 
;                   print, 'cnl = ', cnl, ' modtime ', modtime(cnl), ' tornadotime ', tornadotime(inx) 
                     
;                   if (modtime(cnl) le tornadotime(inx) ) then begin 
;                      plots, tornadolon(inx), tornadolat(inx), psym = sym(1), $
;                             color = 0L + 256L*(255L + 0), symsize = 2 
;                      print, 'color green'
;                   endif 
                   
;                   if (modtime(cnl) gt tornadotime(inx) ) then begin 
;                      plots, tornadolon(inx), tornadolat(inx), psym = sym(1), $
;                             color = 0L + 256L*(0L + 255L*256), symsize = 2
;                      print, 'color blue'
;                   endif

;             endif else begin
;                      plots, tornadolon(inx), tornadolat(inx), psym = sym(1), $
;                             color = 0L , symsize = 2
;              endelse 

           endfor
     endif
  endif

 ; write image into the file
 ; read current window content 
  image = tvrd(true=3, order=1)

 ; write to tiff
  write_jpeg,  outputname + '.jpg', image, $
               quality = 100, true = 3, order=1
 end
 
