
; purpose of this program : select the same data among LST, AOD products of MODIS


@/home/bruce/program/idl/arslab4/pro_data/daily_grid_LST_AOD/process_day.pro
@/home/bruce/program/idl/arslab4/pro_data/daily_grid_LST_AOD/process_day_aod.pro


; specify the directory and file name list of LST and AOD.
  filedir     = '/mnt/sdc/data/modis/arslab4/mod11/2010/'
  filelist    = '201004lstlist_afl'
  afiledir    = '/mnt/sdc/data/modis/arslab4/mod04/2010/'
  afilelist   = '201004aodlist_afl'


; read file name
  process_day, filedir + filelist, Nday, AllFileName, StartInx, EndInx, $
                  YEAR=year, Mon=mon, Date=Date, TimeS = TimeS, $
                  TimeE = TimeE, Dayname, DAYNUM, NFile=NFile

  process_day_aod, afiledir + afilelist, aNday, aAllFileName, aStartInx, aEndInx, $
                  YEAR= ayear, Mon= amon, Date= aDate, TimeS = aTimeS, $
                  TimeE = aTimeE, aDayname, aDAYNUM, NFile=aNFile

  OPENW, lun1, filedir + filelist + '_al', /get_lun
  OPENW, lun3, afiledir + afilelist + '_al', /get_lun

; read the time for each file name
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

; select the files which have the same time
  FOR i = 0, NFile-1 DO BEGIN
    FOR k = 0, aNFile-1 DO BEGIN
     IF (aodname(k) EQ lstname(i)) THEN BEGIN
      PRINTF, lun1, AllFileName(i)
      PRINTF, lun3, aAllFileName(k)
     ENDIF
    ENDFOR
  ENDFOR
  FREE_LUN, lun1
  FREE_LUN, lun3

END
