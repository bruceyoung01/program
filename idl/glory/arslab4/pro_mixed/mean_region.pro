
; purpose of this program : calculate the mean land surface temperature

  m = lon64arr(1)
  count = lon64arr(1) 
  m = 50
  n = 500
  l = 2
  filedir1 = '/home/bruce/data/modis/arslab4/mod14/2000/'
  filename1= 'MOD14.A2000066.1635.005.2008235193438.hdf'

; open an existing file to read variables

  lun1= 91
  lun2= 92
  lun3= 93
  lun4= 94
  lun5= 95
  lun6= 96

  OPENR, lun1, filename1 + '_ftlat.txt'
  OPENR, lun2, filename1 + '_ftlon.txt'
  OPENR, lun3, filename1 + '_ft.txt'
  OPENR, lun4, filename1 + '_tlat.txt'
  OPENR, lun5, filename1 + '_tlon.txt'
  OPENR, lun6, filename1 + '_t.txt'

  ftlat   = fltarr(l)
  READF, lun1, ftlat
  CLOSE, lun1
  ftlon   = fltarr(l)
  READF, lun2, ftlon
  CLOSE, lun2
  ft      = fltarr(l)
  READF, lun3, ft
  CLOSE, lun3
  tlat    = fltarr(m,n)
  READF, lun4, tlat
  CLOSE, lun4
  tlon    = fltarr(m,n)
  READF, lun5, tlon
  CLOSE, lun5
  t       = fltarr(m,n)
  READF, lun6, t
  CLOSE, lun6
  ;PRINT, t
  count  = 0
  fcount = 0
  tt     = 0.0
  ftt    = 0.0

  FOR i = 0, m-1 DO BEGIN
    FOR k = 0, n-1 DO BEGIN
     IF (15.0 gt tlat(i,k) or 25.0 lt tlat(i,k) or -95 gt tlon(i,k) or -85 lt tlon(i,k) and t(i,k) gt 0.0) THEN BEGIN
       tt = tt + t(i,k)
       PRINT, t(i,k)
       count  = count + 1
       PRINT,count
     ENDIF
    ENDFOR
  ENDFOR
  PRINT, count
  meant = tt/count
  PRINT, 'LST ', meant

  FOR j = 0, l-1 DO BEGIN
     IF (15.0 lt ftlat(j) and 25.0 gt ftlat(j) and -95 lt ftlon(j) and -85 gt ftlon(j)) THEN BEGIN
       ftt = ftt + ft(j)
       fcount  = fcount + 1
     ENDIF
  ENDFOR
  PRINT, fcount
  meanft = ftt/fcount
  PRINT, 'FIRE LST ', meanft
  FREE_LUN, lun1
  FREE_LUN, lun2

END
