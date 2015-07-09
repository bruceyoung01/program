; Purpose of this program is to use HDF to read MOD14 product

PRO sub_read_mod14, filedir, filename, nfire, lat, lon, fire_sample, fire_line


; open the HDF file for reading
sd_id = HDF_SD_START(filedir + filename, /READ)

; find the SDS index to the MOD14 fire mask
index1 = HDF_SD_NAMETOINDEX(sd_id, 'FP_latitude')
index2 = HDF_SD_NAMETOINDEX(sd_id, 'FP_longitude')
index3 = HDF_SD_NAMETOINDEX(sd_id, 'FP_sample')
index4 = HDF_SD_NAMETOINDEX(sd_id, 'FP_line')

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
HDF_SD_GETDATA, sds_id3, fire_sample
PRINT, fire_sample
HELP,fire_sample

sds_id4 = HDF_SD_SELECT(sd_id, index4)
HDF_SD_GETDATA, sds_id4, fire_line
PRINT, fire_line
HELP,fire_line
nfire = n_elements(fire_line)

; finished with SDS
HDF_SD_ENDACCESS, sds_id1
HDF_SD_ENDACCESS, sds_id2
HDF_SD_ENDACCESS, sds_id3
HDF_SD_ENDACCESS, sds_id4

; finished with HDF file
HDF_SD_END, sd_id

end
