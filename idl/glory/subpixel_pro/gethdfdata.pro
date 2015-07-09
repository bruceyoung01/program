;+
; NAME:
; 	getHDFdata
; 
; PURPOSE:
; 	This function returns the data associated with the 
; 	name of an SD dataset.
; 
; AUTHOR:
; 	Luke Ellison
; 
; CREATED:
; 	March 15, 2010
; 
; SYNTAX:
; 	data = getHDFdata(SDinterfaceID, SDSname, 
; 	  attribute=attribute, noreverse=noreverse, 
; 	  keepopen=keepopen, id=id, close=close)
; 
; INPUTS:
; 	SDinterfaceID: The SD interface ID under which is 
; 	the SD dataset to be extracted.  If this value is 
; 	of type string, then it is assumed to be the 
; 	filename of the HDF file, and is opened for 
; 	reading with its SD interface ID stored in keyword 
; 	id, and is finally closed upon completion of 
; 	getHDFdata.
; 	
; 	SDSname: The name of the SD dataset to be 
; 	extracted.  If SDSname is not included, then 
; 	keyword attribute needs to be set to an attribute 
; 	of the SD interface.
; 
; KEYWORDS:
; 	attribute: If set, getHDFdata returns the 
; 	specified attribute of SDSname. 
; 	
; 	noreverse: Set the keyword to retrieve the data 
; 	without transposing the data from column to row 
; 	order.
; 	
; 	keepopen: If SDinterfaceID is of type string and 
; 	keepopen is set, then the HDF file is not closed 
; 	on completion of getHDFdata and the SD interface 
; 	ID is stored in keyword id.
; 	
; 	id: Returns the SD interface ID for instances 
; 	where the user can have this information when 
; 	keepopen keyword is set.
; 	
; 	close: Closes the HDF file, overriding keepopen.
; 
; OUTPUTS:
; 	data: The data associated with the SD dataset 
; 	defined by the SDSname input parameter.
; 
; USER ROUTINES:
; 	None.
; 
; REVISION HISTORY:
; 	
;-

function getHDFdata, SDinterfaceID, SDSname, attribute=attribute, $
  noreverse=noreverse, keepopen=keepopen, id=id, close=close
	on_error, 2
	SDtypeString = (size(SDinterfaceID, /type) eq 7)
	if SDtypeString then $
	  id = HDF_SD_START(SDinterfaceID, /READ) $
	else $
	  id = SDinterfaceID
	
	if keyword_set(SDSname) then begin
		index = HDF_SD_NAMETOINDEX(id, SDSname)
		SDdatasetID = HDF_SD_SELECT(id, index)
	endif else $
	  SDdatasetID = id
	
	if keyword_set(attribute) then begin
		attrID = HDF_SD_ATTRFIND(SDdatasetID, attribute)
		HDF_SD_ATTRINFO, SDdatasetID, attrID, DATA=data
	endif else $
	  HDF_SD_GETDATA, SDdatasetID, data, noreverse=noreverse
	
	if keyword_set(SDSname) then $
	  HDF_SD_ENDACCESS, SDdatasetID
	
	if ((SDtypeString and not keyword_set(keepopen)) or $
	  keyword_set(close)) then $
	    HDF_SD_END, id
	
	return, data
end