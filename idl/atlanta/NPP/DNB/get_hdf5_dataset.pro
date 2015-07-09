;
; Read HDF5 file
; The HDF5 Libarary can be found at 
; http://idlastro.gsfc.nasa.gov/idl_html_help/Alphabetical_Listing_of_HDF5_Routines.html 
;

PRO get_hdf5_dataset, filename, sdsname, data 

;filename = '/data/China/MOD08_M3.005.g3Stats.3374.hdf'

;
; Check if this file is a valid HDF file 
;
if not h5f_is_hdf5(filename) then begin
  print, 'Invalid HDF file ...'
  return
endif else begin
  print, 'Open HDF file : ' + filename
endelse

;
;open outfilename 
;


;
; See what is inside
;
FileID = H5F_open(filename)

; get object ID
NumObjs = H5G_get_num_objs (FileID)

; loop through each object
for i = 0, NumObjs-1 do begin
 ObjName = H5G_GET_OBJ_NAME_BY_IDX(fileID, i)
 Result = H5G_GET_OBJINFO(FileID, ObjName)
 print, 'Object Name: ', ObjName, ' Tyoe: ', Result.Type

; if ( result.type eq 'DATASET' and Objname eq SDSname) then begin
 if ( result.type eq 'DATASET')  then begin
  print, Objname
  open dataset
 DatasetID = H5D_Open(fileid, ObjName)
 Data = H5D_READ( datasetid)
 H5D_close, datasetid 
endif
endfor

 H5F_CLOSE, fileid
END
