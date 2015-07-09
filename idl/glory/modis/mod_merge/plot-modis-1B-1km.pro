; $ID: plot-modis-1B-1km.pro V01 03/27/2012 17:16 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot-modis-1B-1km PLOTS MODIS TRUE COLOR IMAGE WITH FIRE DOTS.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) MODIFIED BY BRUCE. (03/27/2012)
;******************************************************************************


@/home/bruce/idl/IDLLIB/my-lib/mod1B/truecolor_img.pro

 ; decode filename list
 !p.font      = 6
 filedir      = '/home/bruce/sshfs/pfw/satellite/MODIS/sahel/mod021km_02/'
 infile       = '2008daymod021kmnn'
 firefiledir  = '/home/bruce/sshfs/pfw/satellite/MODIS/sahel/mod14/'
 firefilelist = '2008daymod14nn' 
; tornadofile = '~/PRO/Storm_data/May_tornado.txt'

  sat = 'MOD'
; process modis filenames to get date year,... 
 process_day, filedir+infile, Nday, AllFileName, StartInx, EndInx, $
                  YEAR=year, Mon=mon, Date=Day, TimeS = TimeS, $
                  TimeE = TimeE, Dayname, DAYNUM

 print,'datname : ',Dayname

; process fire
 readcol, firefiledir+firefilelist, firefiles, format = 'A'

; read informaton on tornados
; readcol, tornadofile,  tyr, tmon, tday, ttime, ttzone, $
;         tcountynum, tstate, tlength, twidth, tFcategory, tfatals, tinjuries, $
;         tprodmg, tprodmgexp, tlat, tlon, $
;         format = '(I4, I3, I3, I5, A4, I5, A4, I5, I5, I5, I5, I5, I5, A4, f8.2, f8.2)'

; change tday and ttime to standard UTC time
;   result = where(ttzone eq 'CST', count)            ;CDT  ; UTC
;   if (count gt 0 ) then ttime(result) = ttime(result) + 100; 600
;   result = where(ttzone eq 'MST', count)
;   if (count gt 0 ) then ttime(result) = ttime(result) + 200; 700
;   result = where(ttzone eq 'EST', count)
;   if (count gt 0 ) then ttime(result) = ttime(result) + 0;  500
;   result = where(ttime ge 2400, count)
;   if (count gt 0 ) then begin
;      ttime(result) = ttime(result) - 2400
;      tday(result) = tday(result) + 1  
;   endif



 ; set region of our interests
; region = [ 10, -115, 45, -65] ;CA
  region = [-15,  -25, 35,  45] ;SAHEL
; region = [-40,   60, 50, 160] ;SEAS
 winx = 1000
 winy = 800
  
 ; plot images for every days
 for i = 0, nday-1 do begin
     nff = EndInx(i) - StartInx(i) + 1
     nls = 0
     nle = 0
   for nf = 0, nff-1 do begin 
      reader_mod, filedir, Allfilename(nf+StartInx(i)), lat=lat, $
                     lon = lon, np = np, nl = nl, $
                     red = rred, green = ggreen, blue = bblue

      if (nf eq 0 ) then begin    
        red = fltarr(np, nl*(nff+1))
        green = fltarr(np, nl*(nff+1))
        blue = fltarr(np, nl*(nff+1))
        flat = fltarr(np, nl*(nff+1))
        flon = fltarr(np, nl*(nff+1))
        modtime = fltarr(nl*(nff+1))
      endif
  
      nls = nle
      nle = nls + nl
      red(0:np-1, nls:nle-1) = rred(0:np-1,  0:nl-1)
      green(0:np-1,  nls:nle-1) = ggreen(0:np-1, 0:nl-1)
      blue(0:np-1,  nls:nle-1) = bblue(0:np-1, 0:nl-1)
      flat(0:np-1,  nls:nle-1) =  congrid(lat, np, nl, /interp) 
      flon(0:np-1,  nls:nle-1) =  congrid(lon, np, nl, /interp)
      modtime( nls:nle-1) = fix(strmid(Allfilename(nf+StartInx(i)), 18, 4))

                                
endfor

 ; get fire location   
   process_fire, MODISfilenames = Allfilename(StartInx(i): EndInx(i)), $
                 firefiledir = firefiledir, firefiles = firefiles,     $
                 firelat = firelat, firelon = firelon
help, firelat, firelon
 ; manupilate data and enhance the image
   red = reform(red(0:np-1, 0:nle-1))
   green = reform(green(0:np-1, 0:nle-1))
   blue = reform(blue(0:np-1, 0:nle-1))
   flat = reform(flat(0:np-1, 0:nle-1))
   flon = reform(flon(0:np-1, 0:nle-1))
   modtime = reform(modtime(0:nle-1))

   red = hist_equal(bytscl(red))
   green = hist_equal(bytscl(green))
   blue = hist_equal(bytscl(blue))

; get tornado data on this day
;   result = where(tday eq day(i) and tmon eq mon(i), count)
;   if (count gt 0 ) then begin
;         tornadolat = tlat(result)
;         tornadolon = tlon(result)
;         tornadotime = ttime(result) 
;   endif else begin
;         tornadolat = -999
;         tornadolon = -999
;         tornadotime = -999
;   endelse
   
   truecolor_img, red=red, green=green, blue=blue, $
              flat = flat, flon= flon, mag = 1, $
              region = region, winx=winx, winy=winy, $
              outputname =  $
              sat + string(year(i), format='(I4)') + '_' + Dayname(i) + $
              '_' + TimeS(i) + '_' + TimeE(i) +'_' + strmid(infile, 0, 7), $
              firelat = firelat, firelon = firelon,$
              title=sat+string(year(i), format='(I4)') + Dayname(i) + $
              '_' + TimeS(i) + '_' + TimeE(i) 
 endfor 
 end
 
