
; Purpose of this program is to write variables in HDF file to an ASCII file

@./read_modis_14.pro


; read the directory and filename

  filedir = '/home/bruce/data/modis/arslab4/mod14/2002/2002.01.03/'
  filename = 'MOD14.A2002003.2355.005.2008220023835.hdf'
  outpname = 'terra200201032355'
; open a new file to write new variables

  OPENW, lun, outpname + '.txt', /get_lun

; using the subroutine of reading MODIS_14 product to read AOD from HDF file

    read_modis_14, filedir, filename, flat, flon, fire_num
  ;PRINT, 'AA :  ', np
  ;PRINT, 'BB :  ', nl
;  OPENW, lun, outpname + '.txt', /get_lun
  FOR i = 0, np*nl-1 DO BEGIN
      
; write the latitude, longitude, fire number into an ASCII file
    PRINTF, lun, flat(i), flon(i), fire_num(i), FORMAT = '(f10.5, f12.5, f3)'
  ENDFOR
  FREE_LUN, lun
END
