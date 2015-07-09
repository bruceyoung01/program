; $ID: read_filelist.pro V01 04/16/2012 11:05 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_filelist READ FILE NAMES FROM FILE LIST.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) infile    (string) :FILE NAMES LIST                             [---]
;  (2 ) filename  (string) :FILE NAMES                                  [---]
;  (3 ) nfile     (integer):TOTAL NUMBER OF FILE NAMES                  [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/16/2012)
;******************************************************************************

PRO read_filelist, infile, filename, nfile
;  
   filename = STRARR(5000)
   oneline  = ' '
   i        = 0

;  READ FILE NAMES AND CHECK OUT HOW MANY FILES
   OPENR, 1, infile
   WHILE ( NOT EOF(1) ) DO BEGIN
    READF, 1, oneline
    filename(i) = oneline
    i = i +1
   ENDWHILE
   CLOSE, 1
   nfile = i
END
