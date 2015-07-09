;
;
; File: MODIS_data_files.pro
; Purpose:
;	Contains library code to simplify the reading of MODIS L1B files.
;	These routines should work on the 1km, 500m and 250m files.
; Date:
;	October 30, 2002
;

;
; read_attribute() assumes that the file and the dataset are already open, and
; the caller is looking to read an attached attribute.
;
; INPUTS:
; =======
;	'sds_id'	: can be either a file or a dataset identifier
; 	'attrname'	: name of the attribute
;
; OUTPUTS:
; ========
;	'data'		: whatever data is associated with the attribute
;
; RETURN VALUE:
; =============
;	0	: Everything worked (success)
;	-1	: Couldn't find/read attribute
;	-2 	: Error in parameter list
;

function read_attribute, sds_id, attrname, data

; check parameters
if n_params() ne 3 then return, -2

; lookup the attribute
attr_idx = hdf_sd_attrfind(sds_id, attrname)
if attr_idx eq -1 then return, -1

; get the attribute info
hdf_sd_attrinfo, sds_id, attr_idx, data=data
end



;
;
; read_dataset reads a named dataset from the named file.  The data is returned
; in 'data'.  'fill_value' is the only optional parameter.  If specified, the fill
; value for the dataset will be returned in this variable.
;
; INPUTS:
; =======
;	'fname'	: name of the HDF file
;	'dsname': name of the dataset to read
;
; OPTIONAL KEYWORDS:
; ==================
;   'SCALE'	: if set, applies the 'scale_factor' attribute to the data
;
;
; OUTPUTS:
; ========
;	'data'	   : contains the data requested.
;	'fill_value: (optional) If specified, contains the fill value
;
; RETURN VALUE:
; =============
;  	0	: Everything worked (success)
;	-1	: Couldn't find/open file
;	-2	: Couldn't find/open named dataset
;	-3 	: Fill value requested, but unable to read it from file
;	-4	: Insufficient number of parameters
;
function read_dataset, fname, dsname, data, fill_value, scale=scale

;check parameter list.
if n_params() lt 3 then begin
	print, "Insufficient number of parameters, aborting!"
	return, -4
end

;open file
sd_id = hdf_sd_start(fname, /read)
if sd_id eq -1 then begin
	return, -1
end

;find, then open dataset
sds_id = hdf_sd_nametoindex(sd_id, dsname)
if sds_id eq -1 then return, -2
sds_id = hdf_sd_select(sd_id, sds_id)
if sds_id eq -1 then return, -2

;get the data
hdf_sd_getdata, sds_id, data

;if fill value is defined, get the fill value from the file
if n_params() eq 4 then begin
	status = read_attribute(sds_id, "_FillValue", fill_value)
	if status ne 0 then return, -3
end

; if instructed to look for a scale factor, then do so.
if keyword_set(scale) then begin
	status = read_attribute(sds_id, "scale_factor", scale_val)
	if status ne 0 then return, -3
	scale_val = scale_val(0)
	data = data * scale_val
endif

hdf_sd_endaccess, sds_id
hdf_sd_end, sd_id

return, 0
end


;
;
; read_dataset_band reads a band from a named dataset from the named file.  The data
; is returned in 'data'.  'fill_value' is the only optional parameter.  If specified,
; the fill value for the dataset will be returned in this variable.
;
; INPUTS:
; =======
;	'fname'	: name of the HDF file
;	'dsname': name of the dataset to read
;	'band'	: index of the band to read
;
; OUTPUTS:
; ========
;	'data'	   : contains the data requested.
;	'fill_value: (optional) If specified, contains the fill value
;
; RETURN VALUE:
; =============
;  	0	: Everything worked (success)
;	-1	: Couldn't find/open file
;	-2	: Couldn't find/open named dataset
;	-3 	: Fill value requested, but unable to read it from file
;	-4	: Insufficient number of parameters
;	-5	: Dataset is not 3D.
;	-6	: Specified value of "band" is too big
;
function read_dataset_band, fname, dsname, band, data, fill_value

;check parameter list.
if n_params() lt 4 then begin
	print, "Insufficient number of parameters, aborting!"
	return, -4
end

;open file
sd_id = hdf_sd_start(fname, /read)
if sd_id eq -1 then begin
	return, -1
endif

;find, then open dataset
sds_id = hdf_sd_nametoindex(sd_id, dsname)
if sds_id eq -1 then return, -2
sds_id = hdf_sd_select(sd_id, sds_id)
if sds_id eq -1 then return, -2

; get the dimensions of the dataset
hdf_sd_getinfo, sds_id, dims=dim
if n_elements(dim) ne 3 then begin
	print, "ERROR!  Dataset not three dimensional"
	return, -5
endif
if (band ge dim(2)) or (band lt 0) then begin
	print, "ERROR!  Specified band is out of range!"
	return, -6
endif

;get the data
count = dim
count(2)=1
start = [0, 0, band]
hdf_sd_getdata, sds_id, data, start=start, count=count

;if fill value is defined, get the fill value from the file
if n_params() eq 5 then begin
	status = read_attribute(sds_id, "_FillValue", fill_value)
	if status ne 0 then return, -3
end

; close dataset and file
hdf_sd_endaccess, sds_id
hdf_sd_end, sd_id

return, 0
end



;
; lookup_bandloc() takes a band name as input and scans the "band_name" attribute
; of all the image datasets in a 1km L1B file.  The names of the image datasets
; are specified by 'image_datasets' and is an array of strings. The name of the
; dataset which contains the match, as well as the band index within that dataset
; is returned.
;
; INPUTS:
; =======
;  	'sd_id'		: handle to open hdf file
;	'bandname'	: name of the band to find
;	'image_datasets': array of image dataset names to check for "band"
;
; OUTPUTS:
; ========
;	'dsname'	: name of dataset containing band ("") if not found
;	'band_index'	: index of the band within 'dsname'. (-1 if not found)
;
; RETURN VALUE:
; =============
;	0	: Everything worked (success)
;	-1	: Unable to open one of the specified image datasets
;	-2 	: Unable to find specified band
;	-3	: Problem with parameter list
;
function lookup_bandloc, sd_id, bandname, image_datasets, dsname, band_index

;check parameter list
if n_params() ne 5 then return, -3

n_datasets = n_elements(image_datasets)

i=0
found_band = 0
while (not found_band) and (i lt n_datasets) do begin
	; find the dataset
	sds_id = hdf_sd_nametoindex(sd_id, image_datasets(i))
	if (sds_id eq -1) then return, -1

	; open the dataset and read the band list
	sds_id = hdf_sd_select(sd_id, sds_id)
	attr_index = hdf_sd_attrfind(sds_id, "band_names")
	if (attr_index eq -1) then begin
		hdf_sd_endaccess, sds_id
		return, -2
	endif
	hdf_sd_attrinfo, sds_id, attr_index, data=band_list
	band_list = strsplit(band_list, ',', /extract)

;       print, 'bandlist', band_list


	; check to see if the band name is in this band list
	band_index = 0
	while (not found_band) and (band_index lt n_elements(band_list)) do begin

		if band_list(band_index) eq bandname then begin

			; set the "found the band" flag
			found_band = 1

		end else begin
			band_index = band_index + 1
		endelse
	endwhile

	; increment the dataset counter
	if not found_band then begin
 		i = i + 1
	endif

	; close up the dataset
	hdf_sd_endaccess, sds_id
endwhile

; set the return value and the 'dsname' parameter according to the result of the
; search
if found_band then begin
	dsname = image_datasets(i)
	retval = 0
end else begin
	retval = -2
endelse

return, retval
end


;
; read_1km_data() reads the specified band from the 1km data file.  Given the
; specified band, the correct dataset/band in the file is read.  An optional
; correction to radiance or reflectance is applied.  Note that both keywords
; cannot simultaneously be set.
;
; INPUTS:
; =======
;	'fname'	  : filename
;	'bandname': name of the band to read in
;
;
; OUTPUTS:
; ========
;	'data'    : data in the interesting band
;
; OPTIONAL KEYWORDS:
; ==================
;  	'/radiance'	: lookup and apply the conversion to radiance
;	'/reflectance'	: lookup and apply the conversion to reflectance
;
; RETURN VALUE:
; =============
;  	0	: Everything worked (success)
;	-1	: Problem with the parameters
;	-2 	: Couldn't find the specified band
;	-3 	: Couldn't open the file
;
function read_1km_data, fname, bandname, data, radiance=rad, reflectance=refl

; check parameters
if n_params() lt 3 then return, -1
if keyword_set(rad) and keyword_set(refl) then return, -1

; These are the datasets to examine for the desired band:
image_datasets= ["EV_1KM_Emissive", $
		 "EV_1KM_RefSB", $
		 "EV_250_Aggr1km_RefSB", $
		 "EV_500_Aggr1km_RefSB"]

;open the file
sd_id = hdf_sd_start(fname,/read)
if sd_id eq -1 then return, -3

;lookup the dataset
retval = lookup_bandloc(sd_id, bandname, image_datasets, dsname, band_index)
if retval ne 0 then begin
	hdf_sd_end, sd_id
	return, -2
endif

;
; it is an error to try and correct one of the "emissive" bands to
; reflectance.  Un-set the keyword if the desired band is emissive
;
if dsname eq "EV_1KM_Emissive" then refl=0

;
; if I have to lookup a radiance or reflectance correction, do it now.
;
if keyword_set(rad) or keyword_set(refl) then begin
	sds_id = hdf_sd_nametoindex(sd_id, dsname)
	sds_id = hdf_sd_select(sd_id, sds_id)

	; read in the specific data requested
	if keyword_set(rad) then begin
		retval = read_attribute(sds_id, "radiance_scales", scales)
		retval = read_attribute(sds_id, "radiance_offsets", offsets)
	end else begin
		retval = read_attribute(sds_id, "reflectance_scales", scales)
		retval = read_attribute(sds_id, "reflectance_offsets", offsets)
	endelse

	; select only the scale and offset of interest to us
	scales = scales(band_index)
	offsets = offsets(band_index)

	hdf_sd_endaccess, sds_id
endif

;close up the file
hdf_sd_end, sd_id

;read the data with my little service routine
retval = read_dataset_band(fname, dsname, band_index, data)

; apply the correction if one was specified
if keyword_set(rad) or keyword_set(refl) then begin
	data = data * scales + offsets
endif

return, 0
end

