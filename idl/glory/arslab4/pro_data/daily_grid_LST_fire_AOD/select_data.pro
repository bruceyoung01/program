
; purpose of this program : select the same data among LST, fire, AOD products of MODIS
@/home/bruce/program/idl/arslab4/pro_data/daily_grid_LST_fire_AOD/process_day.pro
@/home/bruce/program/idl/arslab4/pro_data/daily_grid_LST_fire_AOD/process_day_fire.pro


  filedir     = '/mnt/sdc/data/modis/arslab4/mod11/2010/'
  filelist    = '2010lstlist_afl'
  afiledir    = '/mnt/sdc/data/modis/arslab4/mod04/2010/'
  afilelist   = '2010aodlist_afl'
  ffiledir    = '/mnt/sdc/data/modis/arslab4/mod14/2010/'
  ffilelist   = '2010firelist_afl'


  process_day, filedir + filelist, Nday, AllFileName, StartInx, EndInx, $
                  YEAR=year, Mon=mon, Date=Date, TimeS = TimeS, $
                  TimeE = TimeE, Dayname, DAYNUM, NFile=NFile

  process_day, afiledir + afilelist, aNday, aAllFileName, aStartInx, aEndInx, $
                  YEAR= ayear, Mon= amon, Date= aDate, TimeS = aTimeS, $
                  TimeE = aTimeE, aDayname, aDAYNUM, NFile=aNFile

  process_day_fire, ffiledir + ffilelist, fNday, fAllFileName, fStartInx, fEndInx, $
                  YEAR= fyear, Mon= fmon, Date= fDate, TimeS = fTimeS, $
                  TimeE = fTimeE, fDayname, fDAYNUM, NFile=fNFile

  OPENW, lun1, filedir + filelist + 'n', /get_lun
  OPENW, lun2, afiledir + afilelist + 'n', /get_lun
  OPENW, lun3, ffiledir + ffilelist + 'n', /get_lun

  lstname = STRARR(NFile)
  FOR j = 0, NFile-1 DO BEGIN
  lstname(j) = STRMID(AllFileName(j), 10, 12)
  ;PRINT, 'LST FILE NAME : ', lstname(j)
  ENDFOR

  aodname = STRARR(aNFile)
  FOR j = 0, aNFile-1 DO BEGIN
  aodname(j) = STRMID(aAllFileName(j), 10, 12)
  ;PRINT, 'AOD FILE NAME : ', aodname(j)
  ENDFOR

  firename = STRARR(fNFile)
  FOR j = 0, fNFile-1 DO BEGIN
  firename(j) = STRMID(fAllFileName(j), 7, 12)
  ;PRINT, 'FIRE FILE NAME : ', firename(j)
  ENDFOR

  FOR i = 0, NFile-1 DO BEGIN
   FOR j = 0, aNFile-1 DO BEGIN
    FOR k = 0, fNFile-1 DO BEGIN
     IF (aodname(j) EQ lstname(i) AND firename(k) EQ lstname(i)) THEN BEGIN
      PRINTF, lun1, AllFileName(i)
      PRINTF, lun2, aAllFileName(j)
      PRINTF, lun3, fAllFileName(k)
     ENDIF
    ENDFOR
   ENDFOR
  ENDFOR
  FREE_LUN, lun1
  FREE_LUN, lun2
  FREE_LUN, lun3

END
