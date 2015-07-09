function rdhdf, filename, NAME

	;	See if there is anything there to read
	if n_elements(NAME) eq 0 then return, 0

	sd_id=HDF_SD_START(filename)
      HDF_SD_FILEINFO,sd_id,NumSDS,attributes

	IF NumSDS LT 1 THEN Message, "No Scientific Data Sets in File"

	;	Find out about the first SDS


      index = HDF_SD_NAMETOINDEX(sd_id,NAME)
	sds_id=HDF_SD_SELECT(sd_id,index)	
	help,sds_id
;	HDF_SD_GETINFO,sds_id,RANGE=RANGE
	HDF_SD_GETINFO,sds_id,NDIMS=NDIMS,LABEL=LABEL,DIMS=DIMS,TYPE=TYPE,NAME=NAME,$
	COORDSYS=COORDSYS
	
	HDF_SD_GETDATA,sds_id,xray_out
	;
	; Close down the HDF file
      
	HDF_SD_ENDACCESS,sds_id
	HDF_SD_END,sd_id
        ;
	help,NDIMS,RANGE,LABEL,DIMS,TYPE,NAME,COORDSYS
;	Print,'Displaying Data'
;	window,xsize=DIMS[0],ysize=DIMS[1]
;	erase
;	loadct,8
;	TVSCL, xray_out

;      mapplot, xray_out(*,*,0),/shade

;       XYOUTS, !d.x_size/2, !d.y_size - 20, ALIGNMENT=0.5, /DEVICE, $
;	 STRING(LABEL),charsize=0.75
		
       return, xray_out
		
END
