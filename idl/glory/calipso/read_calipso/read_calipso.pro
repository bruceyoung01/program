; $Id: read_calipso.pro,v 1.4 2007/11/06 10:23:05 sneepm Exp $
; 
; Copyright (c) 2007, KNMI (Maarten Sneep).
; 
; Permission is hereby granted, free of charge, to any person obtaining a 
; copy of this software and associated documentation files (the "Software"), 
; to deal in the Software without restriction, including without limitation 
; the rights to use, copy, modify, merge, publish, distribute, sublicense, 
; and/or sell copies of the Software, and to permit persons to whom the 
; Software is furnished to do so, subject to the following conditions:
; 
; - The above copyright notice and this permission notice shall be included 
;   in all copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
; OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
; THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR 
; OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
; ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR 
; OTHER DEALINGS IN THE SOFTWARE.
;
;
;+
; NAME:
;	READ_CALIPSO
;
; PURPOSE:
;	Read specific fields from Calipso data files (L1 and L2).
;
; CATEGORY:
;	Data I/O
;
; CALLING SEQUENCE:
;	READ_CALIPSO, PATH, FNAME, FIELDNAMES, DATA, ATTRIBUTENAMES, ATTRIBUTES
; 
; PARAMETERS:
;   PATH: The directory where the files are located (string scalar).
;   FNAME: The file name from which to read (string scalar).
;   FIELDNAMES: The fields to be read from the file (string array or string scalar).
;   DATA: named variable in which the results will be placed. The data is returned 
;       in a nameless structure. 
;   ATTRIBUTENAMES: The names of the attributes to be read from the 'metadata' 
;       table (string array or string scalar, optional).
;   ATTRIBUTES: A named variable that will receive the attributes, optional.
;
; USAGE EXAMPLE:
;   See documentation of READ_CALIPSO_SUBSET for an example.
;-

pro read_calipso, path, fname, fieldnames, data, attributenames, attributes
	compile_opt defint32, strictarr, strictarrsubs
    
    ; Open de HDF-4 file and the SD interface
    fid = hdf_open(path + path_sep() + FNAME,/read)
    
    ; only read data if we can dump it.
    if n_params() gt 2 and arg_present(data) then begin
        SDinterface_id = HDF_SD_START( path + path_sep() + FNAME , /READ  )

        ; loop over the fieldnames provided in the fieldnames variable, and read all requested data.
        ; The data will be grouped in the 
        for fieldnameindex=0,n_elements(fieldnames)-1 do begin
            
            ; Find the field index from the name, and read the data into a temporary variable.
            field_index = HDF_SD_NAMETOINDEX(SDinterface_id, fieldnames[fieldnameindex])
            sds_id=HDF_SD_SELECT(SDinterface_id,field_index)
            HDF_SD_GETDATA,sds_id,tmp
            
            ; add the data to the structure.
            if fieldnameindex eq 0 then begin
                data = create_struct(fieldnames[fieldnameindex], tmp)
            endif else begin
                data = create_struct(data,fieldnames[fieldnameindex], tmp)
            endelse
            HDF_SD_ENDACCESS,sds_id
        endfor
        
        ; If only a single item was requested, just return the array.
        if n_elements(fieldnames) eq 1 then data = tmp
        
        ; close teh SD interface (the file will be closed at the end.
        HDF_SD_END,SDinterface_id
    endif
    
    ; only read (file-level) attributes if requested    
    if n_params() gt 4 and arg_present(attributes) then begin
        ; store the number of records if we read some data as well, 
        ; otherwise just initialize the attributes structure.
        if size(tmp, /type) ne 0 then $
            attributes = {NUM_RECS: (size(tmp, /dimensions))[1]} $
        else $
            attributes = {NUM_RECS: -1}
        
        ; open and read the Vdata group
        vds_id = HDF_VD_LONE(fid)
        vdata_id=HDF_VD_ATTACH(fid,vds_id,/read)

        for attrnameindex=0,n_elements(attributeNames)-1 do begin
            nrec = HDF_VD_READ(vdata_id,tmp,fields=attributeNames[attrnameindex])
            attributes = create_struct(attributes, attributeNames[attrnameindex], tmp)
        endfor
        
        HDF_VD_DETACH,vdata_id
    endif
    
    ; Close the file.
    HDF_CLOSE,fid
end

; MODIFICATION HISTORY:
; 	Written by:	Maarten Sneep, 2007. Bug reports (and correcting code) are welcome.
;	$Log: read_calipso.pro,v $
;	Revision 1.4  2007/11/06 10:23:05  sneepm
;	Just return the array instead of a structure if only a single field was requested.
;
;	Revision 1.3  2007/11/05 16:41:33  sneepm
;	Split file. Added documentation.
;


