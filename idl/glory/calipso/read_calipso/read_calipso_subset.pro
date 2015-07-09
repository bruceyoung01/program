; $Id: read_calipso_subset.pro,v 1.3 2007/11/06 10:23:05 sneepm Exp $
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
;	READ_CALIPSO_SUBSET
;
; PURPOSE:
;	Read specific fields from Calipso data files (L1 and L2) and read just what is required.
;
; CATEGORY:
;	Data I/O
;
; CALLING SEQUENCE:
;	READ_CALIPSO_SUBSET, PATH, FNAME, FIELDNAMES, DATA, START=START, COUNT=COUNT, STRIDE=STRIDE
; 
; PARAMETERS:
;   PATH: The directory where the files are located (string scalar).
;   FNAME: The file name from which to read (string scalar).
;   FIELDNAMES: The fields to be read from the file (string array or string scalar).
;   DATA: named variable in which the results will be placed. The data is returned 
;       in a nameless structure. 
;
; NAMED PARAMETERS:
;   START, COUNT, STRIDE: see documentation of HDF_SD_GETDATA for details. Set value to -1 
;   if you want all data in a specific dimension.
;
; USAGE EXAMPLE:
;   First we read the geolocation data with READ_CALIPSO. Then we read every other Lidar backscatter 
;   profile for all latitudes between -5 and +5 degrees.
;       
;       path='./'
;       fname='CALIPSO_sim_L1_V01.2004-01-01T03-36-11ZN.hdf'
;       fieldnames=['Latitude', 'Profile_Time']
;       read_calipso, path, fname, fieldnames, full_data
;
;       idx = where(full_data.latitude ge -5.0 and full_data.latitude lt 5.0, count_items)
;       start  = [0,min(idx)]
;       count  = [-1,count_items/2]
;       stride = [-1,1]
;       read_calipso_subset, path, fname, ['Total_Attenuated_Backscatter_532'], data, $
;           start=start, count=count, stride=stride
;       help, /structure, data
;-

pro read_calipso_subset, path, fname, fieldnames, data, start=start, count=count, stride=stride
	compile_opt defint32, strictarr, strictarrsubs
    
    ; Open de HDF-4 file and the SD interface
    fid = hdf_open(path + path_sep() + FNAME,/read)
    
    if n_params() gt 2 and arg_present(data) then begin
        SDinterface_id = HDF_SD_START( path + path_sep() + FNAME , /READ  )

        ; loop over the fieldnames provided in the fieldnames variable, and read all requested data.
        ; The data will be grouped in the 
        for fieldnameindex=0,n_elements(fieldnames)-1 do begin
            field_index = HDF_SD_NAMETOINDEX(SDinterface_id, fieldnames[fieldnameindex])
            
            sds_id=HDF_SD_SELECT(SDinterface_id,field_index)
            HDF_SD_GETINFO, sds_id, DIMS=dims, NDIMS=ndims
            
            if n_elements(start) eq 0 then begin
                usestart=replicate(0,ndims) 
            endif else begin
                idx=where(start lt 0, cnt, ncomplement=nocnt, complement=noidx)
                if cnt eq 0 then begin
                    usestart=start
                endif else begin
                    usestart = lonarr(ndims)
                    usestart[noidx] = start[noidx]
                    usestart[idx] = 0
                endelse
            endelse
            
            if n_elements(stride) eq 0 then begin
                usestride=replicate(0,ndims) 
            endif else begin
                idx=where(stride lt 0, cnt, ncomplement=nocnt, complement=noidx)
                if cnt eq 0 then begin
                    usestride=stride
                endif else begin
                    usestride = lonarr(ndims)
                    usestride[noidx] = stride[noidx]
                    usestride[idx] = 0
                endelse
            endelse
            
            if n_elements(count) eq 0 then begin
                usecount=(dims-usestart)/(stride+1)
            endif else begin
                idx=where(count lt 0, cnt, ncomplement=nocnt, complement=noidx)
                if cnt eq 0 then begin
                    usecount=count
                endif else begin
                    usecount = lonarr(ndims)
                    usecount[noidx] = count[noidx]
                    usecount[idx] = (dims[idx]-usestart[idx])/(usestride[idx]+1)
                endelse
            endelse
            
            HDF_SD_GETDATA,sds_id,tmp, count=usecount, start=usestart, stride=usestride
            
            if fieldnameindex eq 0 then begin
                data = create_struct(fieldnames[fieldnameindex], tmp)
            endif else begin
                data = create_struct(data,fieldnames[fieldnameindex], tmp)
            endelse
            HDF_SD_ENDACCESS,sds_id
        endfor
        
        ; If only a single item was requested, just return the array.
        if n_elements(fieldnames) eq 1 then data = tmp
        
        HDF_SD_END,SDinterface_id
    endif
    
    HDF_CLOSE,fid
end

; MODIFICATION HISTORY:
; 	Written by:	Maarten Sneep, 2007. Bug reports (and correcting code) are welcome.
;	$Log: read_calipso_subset.pro,v $
;	Revision 1.3  2007/11/06 10:23:05  sneepm
;	Just return the array instead of a structure if only a single field was requested.
;
;	Revision 1.2  2007/11/05 16:50:44  sneepm
;	n_complement -> ncomplement in where statements.
;
;	Revision 1.1  2007/11/05 16:41:33  sneepm
;	Split file. Added documentation.
;


