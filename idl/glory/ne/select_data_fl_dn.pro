
; purpose of this program : select the same data among LST, fire products of MODIS
@./sub/process_day_mod021km.pro
@./sub/process_day_fire.pro


  filedir   = '/home/bruce/sshfs/pfw/data/satellite/MODIS/sahel/mod021km/'
  filelist  = '2008mod021km_day'
  ffiledir  = '/home/bruce/sshfs/pfw/data/satellite/MODIS/sahel/mod14/'
  ffilelist = '2008mod14_day'
  nfilelist = '2008mod14_night'


  process_day_mod021km, filedir + filelist, Nday, AllFileName, StartInx, EndInx, $
                  YEAR=year, Mon=mon, Date=Date, TimeS = TimeS, $
                  TimeE = TimeE, Dayname, DAYNUM, NFile=NFile

  process_day_fire, ffiledir + ffilelist, fNday, fAllFileName, fStartInx, fEndInx, $
                  YEAR= fyear, Mon= fmon, Date= fDate, TimeS = fTimeS, $
                  TimeE = fTimeE, fDayname, fDAYNUM, NFile=fNFile

  OPENW, lun1, filedir  + filelist  + 'nn', /get_lun
  OPENW, lun3, ffiledir + ffilelist + 'nn', /get_lun
  OPENW, lun4, ffiledir + nfilelist + 'nn', /get_lun

  lstname = STRARR(NFile)
  FOR j = 0, NFile-1 DO BEGIN
  lstname(j) = STRMID(AllFileName(j), 0, 3) + STRMID(AllFileName(j), 10, 12)
  ;PRINT, 'LST FILE NAME : ', lstname(j)
  ENDFOR

  firename = STRARR(fNFile)
  FOR j = 0, fNFile-1 DO BEGIN
  firename(j) = STRMID(fAllFileName(j), 0, 3) + STRMID(fAllFileName(j), 7, 12)
  ;PRINT, 'FIRE FILE NAME : ', firename(j)
  ENDFOR

  FOR i = 0, fNFile-1 DO BEGIN
    ind1 = WHERE(firename(i) EQ lstname, nind1)
    IF (nind1 GT 0) THEN BEGIN
     PRINTF, lun1, AllFileName(ind1)
     PRINTF, lun3, fAllFileName(i)
    ENDIF ELSE BEGIN
     PRINTF, lun4, fAllFileName(i)
    ENDELSE
;    FOR k = 0, fNFile-1 DO BEGIN
;     IF (firename(k) EQ lstname(i)) THEN BEGIN
;      PRINTF, lun1, AllFileName(i)
;      PRINTF, lun3, fAllFileName(k)
;     ENDIF
;    ENDFOR
;      PRINTF, lun4, fAllFileName(k)
;     ENDELSE
  ENDFOR
  FREE_LUN, lun1
  FREE_LUN, lun3
  FREE_LUN, lun4
END
