
; Purpose of this program is to write variables in HDF file to an ASCII file

@./read_modis_04.pro


; read the directory and filename

  filedir = '/home/bruce/data/modis/setexas/terra/'
  filename = 'MOD04_L2.A2005001.1740.005.2006202213332.hdf'
  outpname = 'terra200501011740'
; open a new file to write new variables

  OPENW, lun, outpname + '.txt', /get_lun

; using the subroutine of reading MODIS_04 product to read AOD from HDF file

    read_modis_04, filedir, filename, flat, flon, aod, np, nl
  PRINT, 'AA :  ', np
  PRINT, 'BB :  ', nl
;  OPENW, lun, outpname + '.txt', /get_lun
  FOR i = 0, np*nl-1 DO BEGIN
      
; write the latitude, longitude, AOD into an ASCII file
    PRINTF, lun, flat(i), flon(i), aod(i), FORMAT = '(f10.5, f12.5, f15.5)'
  ENDFOR
  FREE_LUN, lun
END
