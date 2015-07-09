; $ID: sub_read_sahel_countries.pro V01 02/21/2012 11:08 BRUCE EXP$
;
;******************************************************************************
;  SUBROUTINE sub_read_sahel_countries READS THE COUNTRY INFO FROM A TEXT FILE, 
;  INCLUDING COUNTRY NAME, LATITUDE, LONGITUDE.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/21/2012)
;
;******************************************************************************

PRO sub_read_sahel_countries, $
    dir, filename,nline,      $ ; INPUT
    cname, clat, clon           ; OUTPUT

;  OPEN THE FIEL AND READ IT
   OPENR, lun, dir + filename, /get_lun
   tmpname = " "
   tmplat  = 0.0
   tmplon  = 0.0
   FOR i = 0, nline-1 DO BEGIN
    READCOL, lun, tmpname, tmplat, tmplon
    cname(i) = tmpname
    clat(i)  = tmplat
    clon(i)  = tmplon
   ENDFOR
   FREE_LUN, lun
END
