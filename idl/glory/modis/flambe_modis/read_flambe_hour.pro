; $ID: read_flambe_hour.pro V01 03/23/2012 10:01 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_flambe_hour READS THE FIRE INFO FROM FLAMBE FIRE EMISSION 
;  DATA WITH DIFFERENT SATELLITE SOURCES. INFO INCLUDES LATITUDE, LONGITUDE, 
;  AND SATELLITE CODE.
;  SATELLITE CODES AS FOLLOWING:
;  (1 ) 250 = GOES-10 = GOES-WEST
;  (2 ) 251 = GOES-11 = GOES-WEST
;  (3 ) 252 = GOES-12 = GOES-EAST
;  (4 ) 783 = MODIS-Terra
;  (5 ) 784 = MODIS-Aqua
;
;  VARIABLES:
;  ============================================================================
;  (1 ) FILEDIR  (STRING) : FLAMBE FIRE FILE DIRECTORY                   [---]
;  (2 ) FILELIST (STRING) : FLAMBE FIRE FILE NAME LIST                   [---]
;  (3 ) YEAR     (INTEGER): YEAR OF MODIS LEVEL 1B DATA                  [---]
;  (4 ) MONTH    (INTEGER): MONTH OF MODIS LEVEL 1B DATA                 [---]
;  (5 ) DAY      (INTEGER): DAY OF MODIS LEVEL 1B DATA                   [---]
;  (6 ) SATELLITE(INTEGER): SATELLITE CODE                               [---]
;  (7 ) FIRELAT  (FLOAT)  : LATITUDE OF FIRE DOTS                        [Deg]
;  (8 ) FIRELON  (FLOAT)  : LONGITUDE OF FIRE DOTS                       [Deg]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (03/22/2012)
;  (2 ) MODIFIED FROM read_flambe.pro. (03/23/2012)
;******************************************************************************

PRO READ_FLAMBE_HOUR, FILEDIR, FILELIST, YEAR = YEAR,        $
                      MONTH = MONTH, DAY = DAY, HOUR = HOUR, $
                      SATELLITE = SATELLITE,                 $
                      FIRELAT = FIRELAT, FIRELON = FIRELON

;  READ FLAMBE FIRE EMISSION FILE NAMES
   READCOL, FILEDIR + FILELIST, FILENAMES, FORMAT = 'A'

;  SELECT THE FIRE FILE NAMES WITH THE SAME YEAR, MONTH, AND DAY AS THE MODIS'S
   NFILE = N_ELEMENTS(FILENAMES)
   FYEAR = INTARR(NFILE)
   FMONTH= INTARR(NFILE)
   FDAY  = INTARR(NFILE)
   FHOUR = INTARR(NFILE)
   FOR I = 0, NFILE-1 DO BEGIN
    FYEAR(I) = FIX(STRMID(FILENAMES(I), 14, 4))
    FMONTH(I)= FIX(STRMID(FILENAMES(I), 18, 2))
    FDAY(I)  = FIX(STRMID(FILENAMES(I), 20, 2))
    FHOUR(I) = FIX(STRMID(FILENAMES(I), 22, 2))
   ENDFOR
   IND   = WHERE(FYEAR  EQ YEAR  AND $
                 FMONTH EQ MONTH AND $
                 FDAY   EQ DAY   AND $
                 FHOUR  EQ HOUR, NIND)
;  DO THE LOOP OF NIND TO READ SELECTED FLAMBE FIRE EMISSION
   NLINE = 0
   FOR I = 0, NIND-1 DO BEGIN
    READCOL, FILEDIR + FILENAMES(IND(I)), ADATE, AFIRELON, AFIRELAT, $
             AINJ_MIN, AINJ_MED, AINJ_MAX, ASATELLITE, AAREA,        $
             ARATE, ATIME, ACARBON, AEXT_1, AEXT_2, AEXT_3,          $
             FORMAT = 'A, F, F, I, I, I, I, F, F, I, F, F, F, F'
;  SELECT THE SAME SATELLITE
    SIND  = WHERE(ASATELLITE EQ SATELLITE, NSIND)
    IF (NSIND GT 0) THEN BEGIN
     FIRELAT(NLINE:NLINE+NSIND-1) = AFIRELAT(SIND)
     FIRELON(NLINE:NLINE+NSIND-1) = AFIRELON(SIND)
     NLINE = NLINE + NSIND
    ENDIF
   ENDFOR

END

