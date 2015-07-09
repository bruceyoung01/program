; $Id: add_data.pro,v 1.1.1.1 2007/07/17 20:41:36 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        ADD_DATA
;
; PURPOSE:
;        Add a variable to a data array and its header, units,
;        cfact, and mcode fields.  For use with CHEM1D.
;
; CATEGORY:
;        Atmospheric Sciences
;
; CALLING SEQUENCE:
;        ADD_DATA,data,header,units,cfact,mcode,    $
;           newdat,newhead,newunit,newfact,newcode [,keywords]
;
; INPUTS:
;        DATA --> the array containing all the data
;        HEADER --> string vector of variable names
;        UNITS --> string vector of variable units (maybe undefined)
;        CFACT --> float vector of conversion factors (maybe undefined)
;        MCODE --> float vector of missing value codes (maybe undefined)
;        NEWDATA --> data vector containing new variable
;        NEWHEADER --> name of new variable
;        NEWUNIT --> physical unit of new variable (may be omitted)
;        NEWFACT --> conversion factor of new variable (may be omitted)
;        NEWCODE --> missing value code for new variable (may be omitted)
;
; KEYWORD PARAMETERS:
;        /INFO  --> prints number of variables (elements of HEADER)
;               after merging the new column with the old array
;        /TRANSPOSE --> NEWDAT is being transposed before merging it
;               with DATA
;        /FIRST --> add variable at first position rather than last
;
; OUTPUTS:
;        DATA, HEADER, UNITS, CFACT, MCODE will contain the extra data
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        suppose DATA is a 3x10 array, and HEADER contains 
;        the names A, B, and C. Then 
;
;            ADD_DATA,DATA,HEADER,DUMMY,DUMMY,DUMMY,findgen(10),'COUNT'
;
;        will add the variable COUNT to the dataset and the name to HEADER.
;
;        A more realistic example:
;            ADD_DATA,DATA,HEADER,UNITS,CFACT,MCODE, $
;                     NEWDAT,'SATURATION_PRESSURE','mbar',1.0,-999.99
;
; MODIFICATION HISTORY:
;        mgs, 05 Nov 1997: VERSION 1.00
;            extracted from CREATE_MASTER.PRO, added flexibility for
;            optional parameters
;        mgs, 06 Nov 1997: - added FIRST keyword
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1997-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine add_data";
;-------------------------------------------------------------


pro add_data,data,header,units,cfact,mcode,    $
             newdat,newhead,newunit,newfact,newcode,info=info,$
             transpose_new=transpose_new,first=first

tmp = newdat
if(keyword_set(transpose_new)) then tmp = transpose(tmp)

  if (keyword_set(first)) then data = [ tmp, data ] $
  else data = [data, tmp]

  if (keyword_set(first)) then header = [newhead, header] $
  else header = [header, newhead]

  if (n_elements(units) ge 1 AND n_elements(newunit) ge 1) then $
     if (keyword_set(first)) then units = [ newunit, units ] $
     else units = [units, newunit]

  if (n_elements(cfact) ge 1 AND n_elements(newfact) ge 1) then $
     if (keyword_set(first)) then cfact = [ newfact, cfact ] $
     else cfact = [cfact, newfact]

  if (n_elements(mcode) ge 1 AND n_elements(newcode) ge 1) then $
     if (keyword_set(first)) then mcode = [ newcode, mcode ] $
     else mcode = [mcode, newcode]
 
  if(keyword_set(info)) then $
     print,'dimension of data array now : ',n_elements(header)
return
end
 
 
