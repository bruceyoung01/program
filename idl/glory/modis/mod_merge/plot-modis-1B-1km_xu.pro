 ; decode filename list
 !p.font = 6
 infile = 'MOD1km_filelist.txt'
; infile = 'MYD1km_filelist.txt'
 filedir = '/fs1/MODIS/MOD1B/'

; process modis filenames to get date year,... 
 process_day, filedir+infile, Nday, AllFileName, StartInx, EndInx, $
                  YEAR=year, Mon=mon, Date=Day, TimeS = TimeS, $
                  TimeE = TimeE, Dayname, DAYNUM

print,nday 
 ; set region of our interests
 region = [-10, 70, 55, 150]
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
   help, lon,lat,np,nl,red, green,blue
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

   truecolor_img, red=red, green=green, blue=blue, $
              flat = flat, flon= flon, mag = 1, $
              region = region, winx=winx, winy=winy, $
              outputname = filedir+ strmid(infile,0 , 6)+$
              string(year(i), format='(I4)') + '_' + Dayname(i) + $
              '_' + TimeS(i) + '_' + TimeE(i) 

 endfor
 end
 
