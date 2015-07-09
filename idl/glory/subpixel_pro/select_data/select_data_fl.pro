
; purpose of this program : select the same data among LST, fire products
; geolocation, and water vapor of MODIS

@./process_day_mod021km.pro
@./process_day_fire.pro
@./process_day_mod03.pro
@./process_day_mod05.pro


  filedir     = '/media/disk/data/modis/ca/2003mod021km/day_night/'
  filelist    = 'filenames.txt'
  ffiledir    = '/media/disk/data/modis/ca/2003mod14/'
  ffilelist   = 'filenames.txt'
  gfiledir    = '/media/disk/data/modis/ca/2003mod03/'
  gfilelist   = 'filenames.txt'
  wfiledir    = '/media/disk/data/modis/ca/2003mod05/'
  wfilelist   = 'filenames.txt'

  process_day_mod021km, filedir + filelist, Nday, AllFileName, StartInx, EndInx, $
                  YEAR=year, Mon=mon, Date=Date, TimeS = TimeS, $
                  TimeE = TimeE, Dayname, DAYNUM, NFile=NFile

  process_day_fire, ffiledir + ffilelist, fNday, fAllFileName, fStartInx, fEndInx, $
                  YEAR= fyear, Mon= fmon, Date= fDate, TimeS = fTimeS, $
                  TimeE = fTimeE, fDayname, fDAYNUM, NFile=fNFile

  process_day_mod03, gfiledir + gfilelist, gNday, gAllFileName, gStartInx, gEndInx, $
                  YEAR= gyear, Mon= gmon, Date= gDate, TimeS = gTimeS, $
                  TimeE = gTimeE, gDayname, gDAYNUM, NFile=gNFile
  process_day_mod05, wfiledir + wfilelist, wNday, wAllFileName, wStartInx, wEndInx, $
                  YEAR= wyear, Mon= wmon, Date= wDate, TimeS = wTimeS, $
                  TimeE = wTimeE, wDayname, wDAYNUM, NFile=wNFile


  OPENW, lun1, filedir + filelist + 'dn', /get_lun
  OPENW, lun3, ffiledir + ffilelist + 'dn', /get_lun
  OPENW, lun5, gfiledir + gfilelist + 'dn', /get_lun
  OPENW, lun7, wfiledir + wfilelist + 'dn', /get_lun


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

  geoname = STRARR(gNFile)
  FOR j = 0, gNFile-1 DO BEGIN
  geoname(j) = STRMID(gAllFileName(j), 7, 12)
  ;PRINT, 'GEO FILE NAME : ', geoname(j)
  ENDFOR

  watername = STRARR(wNFile)
  FOR j = 0, wNFile-1 DO BEGIN
  watername(j) = STRMID(wAllFileName(j), 10, 12)
  ;PRINT, 'WATER FILE NAME : ', watername(j)
  ENDFOR

  FOR i = 0, NFile-1 DO BEGIN
    PRINT, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    PRINT, 'I = ', i
    time1 = systime()
    PRINT, 'START TIME = ', time1
    FOR k = 0, fNFile-1 DO BEGIN
      FOR l = 0, gNFile-1 DO BEGIN
        FOR j = 0, wNFile-1 DO BEGIN
          IF ( lstname(i) EQ firename(k) AND $
               lstname(i) EQ geoname(l)  AND $
               lstname(i) EQ watername(j)) THEN BEGIN
            PRINT, AllFileName(i)
            PRINT, fAllFileName(k)
            PRINT, gAllFileName(l)
            PRINT, wAllFileName(j)
            PRINTF, lun1, AllFileName(i)
            PRINTF, lun3, fAllFileName(k)
            PRINTF, lun5, gAllFileName(l)
            PRINTF, lun7, wAllFileName(j)
          ENDIF
        ENDFOR
      ENDFOR
    ENDFOR
    time2 = systime()
    PRINT, 'END TIEM = ', time2
  ENDFOR
FREE_LUN, lun1
FREE_LUN, lun3
FREE_LUN, lun5
FREE_LUN, lun7

END
