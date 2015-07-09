; Purpose of this program is to use HDF to read MOD14 product

n = 3
filedir = '/home/bruce/data/modis/arslab4/mod14/2000/'
filename= 'MOD14.A2000366.1655.005.2006342072113.hdf'

; open a new file to write new variables

  OPENW, lun, filename + '.txt', /get_lun

; open the HDF file for reading
sd_id = HDF_SD_START(filedir + filename, /READ)

; find the SDS index to the MOD14 fire mask
index1 = HDF_SD_NAMETOINDEX(sd_id, 'FP_latitude')
index2 = HDF_SD_NAMETOINDEX(sd_id, 'FP_longitude')
index3 = HDF_SD_NAMETOINDEX(sd_id, 'FP_sample')

; select and read the entire fire SDS
sds_id1 = HDF_SD_SELECT(sd_id, index1)
HDF_SD_GETDATA, sds_id1, lat
PRINT, lat
HELP,lat

sds_id2 = HDF_SD_SELECT(sd_id, index2)
HDF_SD_GETDATA, sds_id2, lon
PRINT, lon
HELP,lon

sds_id3 = HDF_SD_SELECT(sd_id, index3)
HDF_SD_GETDATA, sds_id3, fire_num
PRINT, fire_num
HELP,fire_num

  FOR i = 0, n-1 DO BEGIN

; write the latitude, longitude, fire number into an ASCII file
    PRINTF, lun, lat(i), lon(i), fire_num(i), FORMAT = '(f10.5, f12.5, i4)'
  ENDFOR
  FREE_LUN, lun

; finished with SDS
HDF_SD_ENDACCESS, sds_id1
HDF_SD_ENDACCESS, sds_id2
HDF_SD_ENDACCESS, sds_id3


; finished with HDF file
HDF_SD_END, sd_id

end
