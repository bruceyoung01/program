; $ID: plot-modis-1B-1km_TA_dn_monthly.pro V01 03/27/2012 17:20 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot-modis-1B-1km_TA_dn_monthly PLOTS MODIS TRUE COLOR IMAGE WITH 
;  FIRE DOTS.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) MODIFIED BY BRUCE. (03/27/2012)
;  (2 ) MODIFIED FROM plot-modis-1B-1km.pro. (03/27/2012)
;  (3 ) ADD TO OUTPUT FIRE COUNTS FILE BY BRUCE. (06/08/2012)
;  (4 ) ADD MONTHLY FIRE COUNTS AND COMPLETELY TRUE COLOR IMAGE. (10/21/2013)
;******************************************************************************

@./sub/truecolor_img_TA_dn_modis.pro
@./sub/process_day_mod021km.pro

 ; decode filename list
 !p.font      = 6
 filedir      = '/home/bruce/sshfs/tw/parallel/data/satellite/modis/smoke/mod021/2010/01/'
 infile       = '2010mod021km_day'
 dfirefiledir = '/home/bruce/sshfs/tw/parallel/data/satellite/modis/smoke/mod14/2010/01/'
 dfirefilelist= '2010mod14_daynn'
 nfirefiledir = '/home/bruce/sshfs/tw/parallel/data/satellite/modis/smoke/mod14/2010/01/'
 nfirefilelist= '2010mod14_nightnn'
 dcountfile   = 'Terra_fire_count_daytime_smoke'
 ncountfile   = 'Terra_fire_count_nighttime_smoke'
;tornadofile  = '~/PRO/Storm_data/May_tornado.txt'

; OPEN FIRE COUNTS OUTPUT FILE
  OPENW, dlun, dcountfile, /get_lun
  OPENW, nlun, ncountfile, /get_lun
  sat = 'MOD'
; process modis filenames to get date year,... 
  process_day_mod021km, filedir+infile, Nday, AllFileName, StartInx, EndInx, $
                             YEAR=year, Mon=tmon, Date=Day, TimeS =TimeS,    $
                             TimeE = TimeE, Dayname, DAYNUM

  print,'dayname : ',Dayname

; process fire
  readcol, dfirefiledir+dfirefilelist, dfirefiles, format = 'A'
  readcol, nfirefiledir+nfirefilelist, nfirefiles, format = 'A'

;  SELECT THE FIRE FILE NAMES WITH THE SAME YEAR, MONTH, AND DAY AS THE MODIS'S
   NFILE = N_ELEMENTS(nfirefiles)
   FYEAR = INTARR(NFILE)
   FMONTH= INTARR(NFILE)
   FDAY  = INTARR(NFILE)
   FOR J = 0, NFILE-1 DO BEGIN
    FYEAR(J) = FIX(STRMID(nfirefiles(J), 7, 4))
    FJDAY    = FIX(STRMID(nfirefiles(J), 11, 3))
    DMY      = DATE_VALUE(FYEAR(J), FJDAY)
    FMONTH(J)= FIX(STRMID(DMY, 3, 2))
    FDAY(J)  = FIX(STRMID(DMY, 0, 2))
   ENDFOR
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
; region = [-15,  -25, 35,  45] ;SAHEL
  region = [-10,  -20, 20,  45] ;SAHEL
; region = [-40,   60, 50, 160] ;SEAS
; region = [ 25, -115, 45, -90] ;NE
; region = [ 20, -100, 45, -70] ;NE
 winx = 1000
 winy = 800

 nday = 2
; plot images for every day
 for i = 0, nday-1 do begin
     nff = EndInx(i) - StartInx(i) + 1
     nls = 0
     nle = 0
; EXTRACT THE YEAR, MONTH, DAY, AND SATELLITE FROM MODIS DATA
   SAT  = STRMID(Allfilename(StartInx(i)), 0, 3)
   SATE = 'TA'
   SATELLITE1 = 783
   SATELLITE2 = 784
   IYEAR = FIX(STRMID(Allfilename(StartInx(i)), 10, 4))
   IJDAY = FIX(STRMID(Allfilename(StartInx(i)), 14, 3))
   DMY   = DATE_VALUE(IYEAR, IJDAY)
   IMONTH= FIX(STRMID(DMY, 3, 2))
   IDAY  = FIX(STRMID(DMY, 0, 2))

   for nf = 0, nff-1 do begin 
      reader_mod, filedir, Allfilename(nf+StartInx(i)), lat=lat, $
                     lon = lon, np = np, nl = nl, $
                     red = rred, green = ggreen, blue = bblue

      IF (NF EQ 0) THEN BEGIN
         red     = fltarr(np, nl*(nff+1))
         green   = fltarr(np, nl*(nff+1))
         blue    = fltarr(np, nl*(nff+1))
         flat    = fltarr(np, nl*(nff+1))
         flon    = fltarr(np, nl*(nff+1))
         modtime = fltarr(    nl*(nff+1))
      ENDIF

      IF (I EQ 0 AND NF EQ 0 ) THEN BEGIN    
        ared     = fltarr(nday, np, nl*(nff+1))
        agreen   = fltarr(nday, np, nl*(nff+1))
        ablue    = fltarr(nday, np, nl*(nff+1))
        aflat    = fltarr(nday, np, nl*(nff+1))
        aflon    = fltarr(nday, np, nl*(nff+1))
        amodtime = fltarr(nday,     nl*(nff+1))
      ENDIF
  
      nls = nle
      nle = nls + nl
print, "i, np, nls, nle = ", i, ", ", np, ", ", nls, ", ", nle
      red  (0:np-1, nls:nle-1) = rred  (0:np-1, 0:nl-1)
      green(0:np-1, nls:nle-1) = ggreen(0:np-1, 0:nl-1)
      blue (0:np-1, nls:nle-1) = bblue (0:np-1, 0:nl-1)
      flat (0:np-1, nls:nle-1) = congrid(lat, np, nl, /interp) 
      flon (0:np-1, nls:nle-1) = congrid(lon, np, nl, /interp)
      modtime(      nls:nle-1) = fix(strmid(Allfilename(nf+StartInx(i)), 18, 4))

endfor

; get fire location   
   process_fire, MODISfilenames = Allfilename(StartInx(i): EndInx(i)), $
                 firefiledir = dfirefiledir, firefiles = dfirefiles,   $
                 firelat = dfirelat, firelon = dfirelon
   IND   = WHERE(FYEAR  EQ IYEAR  AND $
                 FMONTH EQ IMONTH AND $
                 FDAY   EQ IDAY, NIND)
   process_fire_only, firefiledir = nfirefiledir, firefiles = nfirefiles(ind),$
                 firelat = nfirelat, firelon = nfirelon
; manupilate data and enhance the image
   red  (0:np-1, 0:nle-1)  = reform(red  (0:np-1, 0:nle-1))
   green(0:np-1, 0:nle-1)  = reform(green(0:np-1, 0:nle-1))
   blue (0:np-1, 0:nle-1)  = reform(blue (0:np-1, 0:nle-1))
   flat (0:np-1, 0:nle-1)  = reform(flat (0:np-1, 0:nle-1))
   flon (0:np-1, 0:nle-1)  = reform(flon (0:np-1, 0:nle-1))
   modtime(      0:nle-1)  = reform(modtime( 0:nle-1))

   red  (0:np-1, 0:nle-1)  = hist_equal(bytscl(red  (0:np-1, 0:nle-1)))
   green(0:np-1, 0:nle-1)  = hist_equal(bytscl(green(0:np-1, 0:nle-1)))
   blue (0:np-1, 0:nle-1)  = hist_equal(bytscl(blue (0:np-1, 0:nle-1)))

   ared  (i, 0:np-1, nls:nle-1) = red  (0:np-1, nls:nle-1)
   agreen(i, 0:np-1, nls:nle-1) = green(0:np-1, nls:nle-1)
   ablue (i, 0:np-1, nls:nle-1) = blue (0:np-1, nls:nle-1)
   aflat (i, 0:np-1, nls:nle-1) = flat (0:np-1, nls:nle-1)
   aflon (i, 0:np-1, nls:nle-1) = flon (0:np-1, nls:nle-1)
   amodtime(i,       nls:nle-1) = modtime(      nls:nle-1)

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
   
   truecolor_img_TA_dn_modis, red=ared(i, *, *), green=agreen(i, *, *), $
              blue=ablue(i, *, *),                                      $
              flat = aflat(i, *, *), flon= aflon(i, *, *), mag = 1,     $
              region = region, winx=winx, winy=winy,            $
              outputname =                                      $
              sat + string(year(i), format='(I4)') + '_' +      $
              Dayname(i) + '_' + TimeS(i) + '_' + TimeE(i) +'_' $
              + strmid(infile, 0, 7) + '_terra_dn_MODIS',       $
              dtfirelat = dfirelat, dtfirelon = dfirelon,       $
              ntfirelat = nfirelat, ntfirelon = nfirelon,       $
              title=sat+string(year(i), format='(I4)') +        $
              Dayname(i) + '_' + TimeS(i) + '_' + TimeE(i) +    $
              '_terra_dn_MODIS', latdel = 10, londel = 10,      $
              dlun = dlun, nlun = nlun
 endfor 

   truecolor_img_TA_dn_modis, red=ared, green=agreen, blue=ablue,  $
              flat = aflat, flon= aflon, mag = 1,                  $
              region = region, winx=winx, winy=winy,            $
              outputname =                                      $
              sat + string(year(0), format='(I4)') + '_' +      $
              strmid(Dayname(0), 0, 9) + '_terra_dn_MODIS',     $
              dtfirelat = dfirelat, dtfirelon = dfirelon,       $
              ntfirelat = nfirelat, ntfirelon = nfirelon,       $
              title=sat+string(year(0), format='(I4)') +        $
              strmid(Dayname(0), 0, 9) +                        $
              '_terra_dn_MODIS', latdel = 10, londel = 10,      $
              dlun = dlun, nlun = nlun

 FREE_LUN, dlun
 FREE_LUN, nlun
 end
 
