; Purpose of this program is to use HDF to read MOD14 product

PRO sub_read_mod14_judge, filedir, filename, fire_mask


; open the HDF file for reading
sd_id = HDF_SD_START(filedir + filename, /READ)

; find the SDS index to the MOD14 fire mask
index1 = HDF_SD_NAMETOINDEX(sd_id, 'fire mask')

; select and read the entire fire SDS
sds_id1 = HDF_SD_SELECT(sd_id, index1)
HDF_SD_GETDATA, sds_id1, fire_mask
;PRINT, fire_mask
;HELP,fire_mask

; finished with SDS
HDF_SD_ENDACCESS, sds_id1

; finished with HDF file
HDF_SD_END, sd_id

end
