; $ID SELECT_DATA_FILE.PRO V01 11/14/2011 13:45 BRUCE EXP $
;
;******************************************************************************
;  PROGRAM SELECT_DATA_FILE IS USED TO SELECT THE SAME FILE NAMES IN TWO OR 
;  MORE FILE LISTS.
;
;  PROGRAM VARIABLES:
;  ============================================================================
;  
;  NOTES:
;  (1 ): ORIGINALL WRITTEN BY BRUCE. (BRUCE 11/14/2011)
;
;******************************************************************************

  filedir1     = '/home/bruce/sshfs/pfw/satellite/CALIPSO/sahel/CAL_LID_L1-ValStage1-V3-01/'
  filelist1    = 'CAL_LID_L1-ValStage1-V3-01_02_small'
  filedir2     = '/home/bruce/sshfs/pfw/satellite/CALIPSO/sahel/CAL_LID_L1-ValStage1-V3-01/'
  filelist2    = 'list_2011012162'

  OPENW, lun1, filedir1 + filelist1 + 'nn', /get_lun

; CHECK OUT HOW MANY FILES
  n = 5000
  i = 0
  j = 0
  filename1 = STRARR(n)
  filename2 = STRARR(n)
  oneline1  = ' '
  oneline2  = ' '
  OPENR, 11, filedir1 + filelist1
  OPENR, 12, filedir2 + filelist2
  WHILE (NOT EOF(11) ) DO BEGIN
     READF, 11, oneline1
     filename1(i) = oneline1
     i = i + 1
  ENDWHILE
  CLOSE, 11
  nfile1 = i

  WHILE (NOT EOF(12) ) DO BEGIN
     READF, 12, oneline2
     filename2(j) = oneline2
     j = j + 1
  ENDWHILE
  CLOSE, 12
  nfile2 = j

; JUSTIFY THE SAME FILE NAME AND WRITE IT OUT
  FOR i = 0, nfile1-1 DO BEGIN
    FOR k = 0, nfile2-1 DO BEGIN
     IF (filename2(k) EQ filename1(i)) THEN BEGIN
      PRINT, filename1(i)
      PRINTF, lun1, filename1(i)
     ENDIF
    ENDFOR
  ENDFOR
  FREE_LUN, lun1

END
