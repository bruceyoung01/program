pro read_product_sds, datavalue, allvalidrange, fillvalue, fileId, varname, fail,$
        scaleNo=scaleNo, offsetNo=offsetNo, fillNo=fillNo, validrangeNo=validrangeNo 
;+
;.......................................................................
; $Id$
;.......................................................................
; NAME: read_product_sds
;	
;
; PURPOSE:
;        given file id and a variable name, retrieve "calibrated" data 
;        values.
;	
; INPUTS:
;	fileId:	HDF file id number
;       varname: variable name
;
; OPTIONAL INPUTS:
;       scaleNo: 	This parameter does not have scale factor attribute;
;                 	 default assumes that it has.
;       offsetNo: 	This parameter does not have offset attribute; 
;                 	 default assumes that it has.
;       fillNo:   	This parameter does not have fill value attribute;
;                 	 default assumes that it has.
;	validrangeNo:  	This parameter does not have valid range attributes;
;		  	 default assumes that is has.
;
;
; OUTPUTS:
;       datavalue:	The calibrated data, offset and scale applied if necessary.
;	allvalidrange:	The valid range, as read from the SDS attribute.
;	fillvalue:	The fillvalue read from the SDS attribute.
;	fail:		Fail status flag.
;
;
;.......................................................................
; REVISION HISTORY:
;       11/08/01	EGM	Applied scale and offset to fillvalue. Ensured
;				data, range, and fill value returned as float.
;				Added documentation.
;       03/07/00	MAG	Updates with proper MODIS names and additional
;                       code to take into account incorrectly set FillValues
;                       in the L-1B data itself. 
;.......................................................................
; PROGRAMMER:  
;	       Eric G Moody (eric.moody@gsfc.nasa.gov)
;              Climate and Radiation Branch
;              NASA Goddard Space Flight Center
;              Greenbelt, Maryland, U.S.A.
;
;              Mark A Gray
;              Jason Li 
;.......................................................................
; License:
; This software is provided "as-is", without any express or
; implied warranty. In no event will the authors be held liable
; for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software and to alter
; it freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must
;    not claim you wrote the original software.
;
; 2. Altered source versions must be plainly marked as such, and must
;    not be misrepresented as being the original software.
;
; 3. This notice may not be removed or altered from any source distribution.
;.......................................................................
;-



fail=0

;... read SDS data:

index = HDF_SD_NAMETOINDEX(fileId, varname)
sdsid = HDF_SD_SELECT(fileId, index)
HDF_SD_GETDATA, sdsid, dataValue
HDF_SD_ENDACCESS, sdsid


;... read attributes:

scale_sds_name= 'scale_factor'
IF NOT Keyword_Set(scaleNo) THEN BEGIN
   scaleId = HDF_SD_ATTRFIND(sdsid,scale_sds_name)
   IF scaleId NE -1 THEN BEGIN
      HDF_SD_ATTRINFO, sdsid, scaleId, DATA=scale_factor
   ENDIF
   scale_factor = float(scale_factor)
ENDIF

offset_sds_name= 'add_offset'
IF NOT Keyword_Set(offsetNo) THEN BEGIN
   offsetId = HDF_SD_ATTRFIND(sdsid,offset_sds_name)
   IF offsetId NE -1 THEN BEGIN
      HDF_SD_ATTRINFO, sdsid, offsetId, DATA=offset
   ENDIF
   offset = float(offset)
ENDIF

validrange_sds_name= 'valid_range'
IF NOT Keyword_Set(validrangeNo) THEN BEGIN
   validrangeId = HDF_SD_ATTRFIND(sdsid,validrange_sds_name)
   IF validrangeId NE -1 THEN BEGIN
      HDF_SD_ATTRINFO, sdsid, validrangeId, DATA=validrange
   ENDIF
   validrange = float(validrange)
ENDIF

fillvalue_sds_name= '_FillValue'
IF NOT Keyword_Set(fillNo) THEN BEGIN
   fillId = HDF_SD_ATTRFIND(sdsid,fillvalue_sds_name)
   IF fillId NE -1 THEN BEGIN
      HDF_SD_ATTRINFO, sdsid, fillId, DATA=fillValue
   ENDIF
   fillvalue = float(fillvalue[0])
ENDIF

;... calibrate data by applying scale factor and offset if necessary:


arraysizetemp=size(dataValue)
if not keyword_set(scaleNo) then begin
dataValue = float(dataValue)
case 1 of
   max(DataValue) eq -1 and min(DataValue) eq -1: begin
      ;data is a probably a vis channel viewed at nighttime 
      ;let's get the hell out here! eek!
      print,'Cannot find any useful data in the sds ',varname
      fail= 1
   end
   arraysizetemp(0) eq 2: begin
      allvalidrange = fltarr(2)
      dataValue[*,*] = scale_factor[0] * (dataValue[*,*]-offset[0])
      allvalidrange[0:1] = scale_factor[0] * (validrange[0:1]-offset[0])
      fillvalue = scale_factor[0] * (fillvalue-offset[0])
   end
   arraysizetemp(0) eq 3: begin
      allvalidrange=fltarr(2,arraysizetemp[1])
      for band =0, arraysizetemp[1]-1 do begin
         allvalidrange[*,band] = scale_factor[0] * (validrange-offset[0])
         dataValue[band,*,*]   = scale_factor[0] * (dataValue[band,*,*]-offset[0])
      endfor
      fillvalue = scale_factor[0] * (fillvalue-offset[0])
   end
else:print,'Oh my, in big trouble here.  your crash is being served'


endcase

;ensure floats:
allvalidrange = float(allvalidrange)
fillvalue     = float(fillvalue)
datavalue     = float(datavalue)

endif



end
