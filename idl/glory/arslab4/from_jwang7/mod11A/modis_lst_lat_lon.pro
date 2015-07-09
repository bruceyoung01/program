PRO mod_lst_lat_lon, infile, rlat, rlon

; the lat and lon for MODIS 1km product is saved
; in different tiles. based upon filename, 
; we can first identify the tile file name 
tiledir = '/home/jwang/class/data/mod_lst_tile/'
tilenum = string(strmid(infile, 17, 6))
tilefile = 'MODIS_geoloc_1km_' + tilenum + '.hdf'
SDsvar = strarr(2)
SdSVar = ['Latitude', 'Longitude']

; get hdf file id 
FileID = Hdf_sd_start(tiledir + tilefile, /read)
for i = 0, n_elements(SDSvar)-1 do begin
 thisSDSinx = hdf_sd_nametoindex(FileID, SDSVar(i))
 thisSDS = hdf_sd_select(FileID, thisSDSinx)
   HDF_SD_getdata, thisSDS, Data
   if (i eq 0) then RLAT = float(DATA)
   if (i eq 1) then RLON = float(DATA)
endfor
END

