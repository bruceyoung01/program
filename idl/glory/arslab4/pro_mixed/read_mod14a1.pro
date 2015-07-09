; Purpose of this program is to use HDF to read MOD14 product

n = 8
filedir = '/home/bruce/data/modis/arslab4/mod14a1/2003/'
filename= 'MOD14A1.A2003001.h08v07.005.2007263092126.hdf'

; open a new file to write new variables

  OPENW, lun, filename + '.txt', /get_lun

; open the HDF file for reading
sd_id = HDF_SD_START(filedir + filename, /READ)

; read "FirePix" and "MaxT21" attributes
attr_index1 = HDF_SD_ATTRFIND(sd_id, 'FirePix')
HDF_SD_ATTRINFO, sd_id, attr_index1, DATA=FirePix
attr_index2 = HDF_SD_ATTRFIND(sd_id, 'MaxT21')
HDF_SD_ATTRINFO, sd_id, attr_index2, DATA=MaxT21

PRINT, FirePix
PRINT, MaxT21
HELP, FireMask, MaxFRP
; select and read the entire fire SDS
index1 = HDF_SD_NAMETOINDEX(sd_id, 'FireMask')
sds_id1 = HDF_SD_SELECT(sd_id, index1)
HDF_SD_GETDATA, sds_id1, FireMask

index2 = HDF_SD_NAMETOINDEX(sd_id, 'MaxFRP')
sds_id2 = HDF_SD_SELECT(sd_id, index2)
HDF_SD_GETDATA, sds_id2, MaxFRP

;sds_id3 = HDF_SD_SELECT(sd_id, index3)
;HDF_SD_GETDATA, sds_id3, fire_num

  FOR i = 0, n-1 DO BEGIN

; write the latitude, longitude, fire number into an ASCII file
    PRINTF, lun, FirePix(i), MaxT21, FORMAT = '(f10.5, f12.5)'
  ENDFOR
  FREE_LUN, lun

; finished with SDS
HDF_SD_ENDACCESS, sds_id1
HDF_SD_ENDACCESS, sds_id2
;HDF_SD_ENDACCESS, sds_id3


; finished with HDF file
HDF_SD_END, sd_id

end
