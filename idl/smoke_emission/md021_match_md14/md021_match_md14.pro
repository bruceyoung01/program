;------------------------------------------------------------------------------
;  $ID: md021_match_md14.pro V01 11/17/2013 15:28 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM md021_match_md14 READS MOD021KM/MYD021KM DAY-TIME AND MOD14/MYD14 
;  ALL DATA (INCLUDING BOTH DAY AND NIGHT TIME), SELECTS MOD14/MYD14 BASED ON 
;  MOD021KM/MYD021KM DAY-TIME DATA.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (11/19/2013)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
@../../idl_lib/procedure/smoke_emission/process_day_md021km.pro
@../../idl_lib/procedure/smoke_emission/process_day_fire.pro


;  SET UP DIRECTORY AND FILE NAME
   filedir   = '/Users/bruce/Documents/A/sshfs/tw/parallel/data/satellite/modis/smoke/myd021/2010/10/'
   filelist  = '201010myd021km_day'
   ffiledir  = '/Users/bruce/Documents/A/sshfs/tw/parallel/data/satellite/modis/smoke/myd14/2010/10/'
   ffilelist = '201010myd14'

;  CALL SUBROUTINE process_day_md021km.pro TO READ MOD021KM/MYD021KM FILE NAME
   process_day_md021km, $
   filedir + filelist, Nday, AllFileName, StartInx, EndInx, $
   YEAR=year, Mon=mon, Date=Date, TimeS = TimeS, $
   TimeE = TimeE, Dayname, DAYNUM, NFile=NFile

;  CALL SUBROUTINE process_day_fire.pro TO READ MOD14/MYD14 FILE NAME
   process_day_fire, $
   ffiledir + ffilelist, fNday, fAllFileName, fStartInx, fEndInx, $
   YEAR= fyear, Mon= fmon, Date= fDate, TimeS = fTimeS, $
   TimeE = fTimeE, fDayname, fDAYNUM, NFile=fNFile

;  OPEN NEW FILE NAME TO STORE DAY AND NIGHT FILE NAME LIST
   OPENW, lun1, filedir  + filelist  + 'nn',       /get_lun
   OPENW, lun3, ffiledir + ffilelist + '_daynn',   /get_lun
   OPENW, lun4, ffiledir + ffilelist + '_nightnn', /get_lun
   PRINT, '# OF DAY-TIME DATA   = ', NFILE
   PRINT, '# OF NIGHT-TIME DATA = ', FNFILE-NFILE


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
   ENDFOR
   FREE_LUN, lun1
   FREE_LUN, lun3
   FREE_LUN, lun4
END
