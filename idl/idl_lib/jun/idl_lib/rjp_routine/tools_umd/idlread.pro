;--------------------------------------------------------------------------
        pro remove_path, file, file_no_path
;--------------------------------------------------------------------------
        file_no_path    = file

        while( strpos( file_no_path , '/' ) ne -1 ) do $
          file_no_path = strmid( file_no_path , $
            strpos( file_no_path , '/' ) + 1, 1000 )

   end

;--------------------------------------------------------------------------- 
; Main  
   
  
 
  
    filen = dialog_pickfile()
   

; Initialize the scientific data set interface (hdf_sd* routines) 
    sdsfileid = hdf_sd_start(filen,/read)

; Get info on the SDSs, number of SDSs and number of global attributes 
    hdf_sd_fileinfo,sdsfileid,numsds,ngatt
    names = strarr(numsds)
    ndims = lonarr(numsds)
    dtype = strarr(numsds)

; Print out a table of the name, number of dimensions and type of each SDS
; in file    
    for i = 0, numsds - 1 do begin
        sds_id = hdf_sd_select(sdsfileid, i)
        hdf_sd_getinfo, sds_id, name = na, ndim = nd,type= typ
        names( i ) = na 
        ndims( i ) = nd
        dtype(i) = typ  
    endfor
    F1='(" ",A,I4)'
    print,'List of SDS names'
    print,' # of SDSs = ',numsds,FORMAT=F1
    print,''
    if numsds gt 0 then begin
        print,"     Label       Dims   Type"
        print,"---------------- ---- --------"
        for i=0,numsds-1 do begin
            print,names(i),ndims(i),dtype(i),FORMAT='(A14,"   ",I4," ",A8," ")'
        endfor
        print,"---------------- ---- --------"
    endif



; Read the geolocation SDS. This is kind of cheating since I know ahead of
; time that the name of the SDS is 'geolocation'.  However, I could run
; the code above to find out the name of the SDS containing geolocation.

; Get ID of SDS 
; This line calls another built in HDF function inside hdf_sd_select to 
; translate the name of the SDS into an index.
    sds_id = hdf_sd_select(sdsfileid,hdf_sd_nametoindex(sdsfileid, 'geolocation'))

; Read the SDS data into a variable. This reads the entire geolocation array

  hdf_sd_getdata, sds_id, geolocation

;  sds_id = hdf_sd_select(sdsfileid,hdf_sd_nametoindex(sdsfileid, 'calCounts'))
;  hdf_sd_getdata, sds_id, calCounts

 ; sds_id = hdf_sd_select(sdsfileid,hdf_sd_nametoindex(sdsfileid, 'tempCounts'))
;  hdf_sd_getdata, sds_id, tempCounts

;  sds_id = hdf_sd_select(sdsfileid,hdf_sd_nametoindex(sdsfileid, 'localDirection'))
;  hdf_sd_getdata, sds_id, localDirection

;  sds_id = hdf_sd_select(sdsfileid,hdf_sd_nametoindex(sdsfileid, 'channels'))
;  hdf_sd_getdata, sds_id, channels


; We are done with SDSs so we can close the interface
    hdf_sd_end, sdsfileid



; Open the file for read and initialize the Vdata interface
    file_handle = hdf_open(filen,/read)

; Get the ID of the first Vdata in the file 
    vdata_ID = hdf_vd_getid(  file_handle, -1 )
    is_NOT_fakeDim = 1
    num_vdata = 0

; Loop over Vdata 
    while (vdata_ID ne -1) and (is_NOT_fakeDim) do begin

; Attach to the vdata 
        vdata_H = hdf_vd_attach(file_handle,vdata_ID)

; Get vdata name
        hdf_vd_get, vdata_H, name=name,size= size, nfields = nfields
        
; Detach vdata
        hdf_vd_detach, vdata_H
       
; Check to see if this is a dummy
; Can't really explain why this happens but sometimes a dummy dimension
; gets returned as a Vdata name depending on the HDF file.  
        is_NOT_fakeDim = strpos(name,'fakeDim') eq -1

; Build up the list of Vdata names,sizes and number of fields 
        if (num_vdata eq 0) then begin
            Vdata_name = name 
            Vdata_size = size
            Vdata_nfields = nfields
            num_vdata = 1
        endif else if is_NOT_fakeDim then begin
            Vdata_name = [Vdata_name,name]
            Vdata_size = [Vdata_size,size]
            Vdata_nfields = [Vdata_nfields,nfields]
            num_vdata = num_vdata + 1
        endif
       
; Get ID of next Vdata
        vdata_ID = hdf_vd_getid( file_handle, vdata_ID )

    endwhile 

; Print out the list of names   
    print,''   
    print, 'List of Vdata names    Size (bytes)   Num. Fields'
    print, '-------------------------------------------------'
    for i = 0,num_vdata-1  do begin
        print, Vdata_name(i),Vdata_size(i),Vdata_nfields(i),$
               format='(A18,I10,I14)'
    endfor
    print, '-------------------------------------------------'

; Find the Scan status Vdata
    vdata_ID = hdf_vd_find(file_handle,'scan_time')

; Attach to this Vdata
    vdata_H = hdf_vd_attach(file_handle,vdata_ID)

; Get the Vdata stats
    hdf_vd_get,vdata_H,name=name,fields=raw_field

; Separate the fields
    fields = str_sep(raw_field,',')

; Read the Vdata, returns the number of records
; The data for all records is returned in a BYTE ARRAY of (record_size,nscans)
; IDL will issue a warning to remind you there are mixed data types in
; the array
    nscan = hdf_vd_read(vdata_h,data)


; Detach from the Vdata
    hdf_vd_detach, Vdata_H
   
; Close the hdf file
    hdf_close,file_handle  


;-------------------------------------------------------------------------------


end
