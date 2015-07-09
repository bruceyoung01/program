;
; Read HDF5 file
; The HDF5 Libarary can be found at 
; http://idlastro.gsfc.nasa.gov/idl_html_help/Alphabetical_Listing_of_HDF5_Routines.html 
;

PRO get_hdf5_info, filename, outfilename  

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

openw, 1, outfilename

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
 printf, 1, 'Object Name: ', ObjName, ' Tyoe: ', Result.Type

 if ( result.type eq 'DATASET') then begin
 ; open dataset
 DatasetID = H5D_Open(fileid, ObjName)
 Data = H5D_READ( datasetid)

 ; dimension of database
 ; open data space
 SpaceID = H5D_GET_SPACE(DatasetID)
 DIMS = H5S_GET_SIMPLE_EXTENT_DIMS(SpaceID)  
 NDIMS = H5S_GET_SIMPLE_EXTENT_NDIMS(SpaceID)
 printf, 1, 'NDIMS: ', NDIMS, ' DIMS: ', DIMS 

 ; attributes
 NumAttrs = H5A_GET_NUM_ATTRS(DatasetID)
   for j = 0, NumAttrs-1 do begin
     AttrID = H5A_OPEN_IDX(FILEID, j) 
     AttrName = H5A_GET_NAME(AttrID) 
     printf, 1,  'Attrs ', j, ' Attrname: ', Attrname
   endfor
 
 H5D_close, datasetid 
endif
endfor

 H5F_CLOSE, fileid
close, 1
END
