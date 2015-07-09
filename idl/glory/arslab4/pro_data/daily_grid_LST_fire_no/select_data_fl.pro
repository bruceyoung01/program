
; purpose of this program : select the same data among LST, fire products of MODIS
@/home/bruce/program/idl/arslab4/pro_data/daily_grid_LST_fire_AOD/process_day.pro
@/home/bruce/program/idl/arslab4/pro_data/daily_grid_LST_fire_AOD/process_day_fire.pro


  filedir     = '/mnt/sdc/data/modis/arslab4/mod11/2010/'
  filelist    = '201004lstlist_afl'
  ffiledir    = '/mnt/sdc/data/modis/arslab4/mod14/2010/'
  ffilelist   = '201004firelist_afl'


  process_day, filedir + filelist, Nday, AllFileName, StartInx, EndInx, $
                  YEAR=year, Mon=mon, Date=Date, TimeS = TimeS, $
                  TimeE = TimeE, Dayname, DAYNUM, NFile=NFile

  process_day_fire, ffiledir + ffilelist, fNday, fAllFileName, fStartInx, fEndInx, $
                  YEAR= fyear, Mon= fmon, Date= fDate, TimeS = fTimeS, $
                  TimeE = fTimeE, fDayname, fDAYNUM, NFile=fNFile

  OPENW, lun1, filedir + filelist + 'nn', /get_lun
  OPENW, lun3, ffiledir + ffilelist + 'nn', /get_lun

  lstname = STRARR(NFile)
  FOR j = 0, NFile-1 DO BEGIN
  lstname(j) = STRMID(AllFileName(j), 10, 12)
  ;PRINT, 'LST FILE NAME : ', lstname(j)
  ENDFOR

  firename = STRARR(fNFile)
  FOR j = 0, fNFile-1 DO BEGIN
  firename(j) = STRMID(fAllFileName(j), 7, 12)
  ;PRINT, 'FIRE FILE NAME : ', firename(j)
  ENDFOR

  FOR i = 0, NFile-1 DO BEGIN
    FOR k = 0, fNFile-1 DO BEGIN
     IF (firename(k) EQ lstname(i)) THEN BEGIN
      PRINTF, lun1, AllFileName(i)
      PRINTF, lun3, fAllFileName(k)
     ENDIF
    ENDFOR
  ENDFOR
  FREE_LUN, lun1
  FREE_LUN, lun3

END
