pro rdhdf_info, filename, fdname, fdlabel

      fdname = ''
	fdlabel = ''
	;	See if there is anything there to read

	sd_id=HDF_SD_START(filename)
      HDF_SD_FILEINFO,sd_id,NumSDS,attributes

	IF NumSDS LT 1 THEN Message, "No Scientific Data Sets in File"

	;	Find out about the first SDS
	
	FOR INUM = 0, NumSDS-1 do begin

 	sds_id=HDF_SD_SELECT(sd_id,inum)
	help,sds_id

	HDF_SD_GETINFO,sds_id,NDIMS=NDIMS,LABEL=LABEL,DIMS=DIMS,TYPE=TYPE,NAME=NAME,$
	COORDSYS=COORDSYS
	
	;
	; Close down the HDF file
      ;
	HDF_SD_ENDACCESS,sds_id
      
	help,NDIMS,RANGE,LABEL,DIMS,TYPE,NAME,COORDSYS
	wait, 2
	 if (inum eq 0) then begin
	   fdname = NAME
	   fdlabel = LABEL
 	 endif else begin
	   fdname = [fdname,NAME]
	   fdlabel= [fdlabel,LABEL]
	 endelse
	endfor
	
	HDF_SD_END,sd_id
		
END
