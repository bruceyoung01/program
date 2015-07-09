;------------------------------------------------------------------------------
; $ID: plot-modis-1B-1km_TA_dn.pro V01 03/27/2012 17:20 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot-modis-1B-1km_TA_dn PLOTS MODIS TRUE COLOR IMAGE WITH FIRE DOTS.
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
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
@../../idl_lib/procedure/smoke_emission/truecolor_img_TA_dn_modis.pro
@../../idl_lib/procedure/smoke_emission/process_day_md021km.pro

;  SET UP DIRECTORY AND FILE NAME LIST
   !p.font      = 6
   filedir      = '/Volumes/HITACHI/modis/smoke/mod021/2010/10/'
   infile       = '201010mod021km_day'
   firefiledir  = '/Volumes/HITACHI/modis/smoke/mod14/2010/10/'
   dfirefilelist= '201010mod14_daynn'
   nfirefilelist= '201010mod14_nightnn'
   dcountfile   = 'Terra_fire_count_daytime_smoke'
   ncountfile   = 'Terra_fire_count_nighttime_smoke'

;  set region of our interests
   minlat = -10.0
   maxlat =  20.0
   minlon = -20.0
   maxlon =  50.0
   region = [minlat, minlon, maxlat,  maxlon]

;  OPEN FIRE COUNTS OUTPUT FILE
   OPENW, dlun, dcountfile, /get_lun
   OPENW, nlun, ncountfile, /get_lun

;  READ MODIS FILENAME TO GET DATE YEAR
   process_day_md021km, $
   filedir+infile, Nday, AllFileName, StartInx, EndInx, $
   YEAR=year, Mon=tmon, Date=Day, TimeS =TimeS,    $
   TimeE = TimeE, Dayname, DAYNUM

;  READ FIRE NAME LIST
   readcol, firefiledir+dfirefilelist, dfirefiles, format = 'A'
   readcol, firefiledir+nfirefilelist, nfirefiles, format = 'A'

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

;  SET UP PLOT WINDOW SIZE
   winx = 500
   winy = 300

;  START TO COMBINE ALL THE DATA IN ONE DAY AND PLOT IT
   FOR i = 0, nday-1 DO BEGIN
      nff = EndInx(i) - StartInx(i) + 1
      nls = 0
      nle = 0
;  EXTRACT THE YEAR, MONTH, DAY, AND SATELLITE FROM MODIS DATA
      SAT  = STRMID(Allfilename(StartInx(i)), 0, 3)
      SATELLITE1 = 783
      SATELLITE2 = 784
      IYEAR = FIX(STRMID(Allfilename(StartInx(i)), 10, 4))
      IJDAY = FIX(STRMID(Allfilename(StartInx(i)), 14, 3))
      DMY   = DATE_VALUE(IYEAR, IJDAY)
      IMONTH= FIX(STRMID(DMY, 3, 2))
      IDAY  = FIX(STRMID(DMY, 0, 2))

      FOR nf = 0, nff-1 DO BEGIN 
         reader_mod, filedir, Allfilename(nf+StartInx(i)), lat=lat, $
                     lon = lon, np = np, nl = nl, $
                     red = rred, green = ggreen, blue = bblue

         IF (nf EQ 0 ) THEN BEGIN    
            red     = FLTARR(np, nl*(nff+1))
            green   = FLTARR(np, nl*(nff+1))
            blue    = FLTARR(np, nl*(nff+1))
            flat    = FLTARR(np, nl*(nff+1))
            flon    = FLTARR(np, nl*(nff+1))
            modtime = FLTARR(nl*(nff+1))
         ENDIF
         nls = nle
         nle = nls + nl
         red(0:np-1, nls:nle-1)    = rred(0:np-1,  0:nl-1)
         green(0:np-1,  nls:nle-1) = ggreen(0:np-1, 0:nl-1)
         blue(0:np-1,  nls:nle-1)  = bblue(0:np-1, 0:nl-1)
         flat(0:np-1,  nls:nle-1)  = CONGRID(lat, np, nl, /interp) 
         flon(0:np-1,  nls:nle-1)  = CONGRID(lon, np, nl, /interp)
         modtime( nls:nle-1)       = FIX(STRMID(Allfilename(nf+StartInx(i)), 18, 4))
      ENDFOR

;  GET THE FIRE LOCATION
      process_fire, MODISfilenames = Allfilename(StartInx(i): EndInx(i)), $
                    firefiledir = firefiledir, firefiles = dfirefiles,    $
                    firelat = dfirelat, firelon = dfirelon
      IND   = WHERE(FYEAR  EQ IYEAR  AND $
                    FMONTH EQ IMONTH AND $
                    FDAY   EQ IDAY, NIND)
      process_fire_only, firefiledir = firefiledir, firefiles = nfirefiles(ind),$
                 firelat = nfirelat, firelon = nfirelon
;  manupilate data and enhance the image
      red     = REFORM(red(0:np-1, 0:nle-1))
      green   = REFORM(green(0:np-1, 0:nle-1))
      blue    = REFORM(blue(0:np-1, 0:nle-1))
      flat    = REFORM(flat(0:np-1, 0:nle-1))
      flon    = REFORM(flon(0:np-1, 0:nle-1))
      modtime = REFORM(modtime(0:nle-1))
      red     = HIST_EQUAL(BYTSCL(red))
      green   = HIST_EQUAL(BYTSCL(green))
      blue    = HIST_EQUAL(BYTSCL(blue))

      truecolor_img_TA_dn_modis,                        $
      red=red, green=green, blue=blue,                  $
      flat = flat, flon= flon, mag = 2,                 $
      region = region, winx=winx, winy=winy,            $
      outputname =                                      $
      sat + STRING(year(i), format='(I4)') + '_' +      $
      Dayname(i) + '_' + TimeS(i) + '_' + TimeE(i) +'_' $
      + STRMID(infile, 0, 7) + '_terra_dn_MODIS',       $
      dtfirelat = dfirelat, dtfirelon = dfirelon,       $
      ntfirelat = nfirelat, ntfirelon = nfirelon,       $
      title=sat+STRING(year(i), format='(I4)') +        $
      Dayname(i) + '_' + TimeS(i) + '_' + TimeE(i) +    $
      '_terra_dn_MODIS', latdel = 10, londel = 10,      $
      dlun = dlun, nlun = nlun
   ENDFOR 
   FREE_LUN, dlun
   FREE_LUN, nlun
END
 
