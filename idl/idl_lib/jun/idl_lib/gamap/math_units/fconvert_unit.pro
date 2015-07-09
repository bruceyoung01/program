; $Id: fconvert_unit.pro,v 1.1.1.1 2007/07/17 20:41:29 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        FCONVERT_UNIT (function)
;
; PURPOSE:
;        Wrapper for CONVERT_UNIT.  Passes all of the input data to
;        CONVERT_UNIT and returns the result to the calling program.
;
; CATEGORY:
;        Math & Units
;
; CALLING SEQUENCE:
;        RESULT = FCONVERT_UNIT( DATA, UNIT, TOPARAM [, Keywords ] )
;
; INPUTS:
;        DATA -> A data vector, array, or a single value that shall
;            be converted to a new unit. 
;
;        UNIT -> A string variable containing the (current) unit of 
;            DATA. This will be replaced by the new unit afterwards.
;            If omitted, you must give the FROM_UNIT keyword to 
;            indicate the current unit of DATA.
;
;        TOPARAM -> The unit to convert DATA to. This is equivalent to 
;            the keyword TO_UNIT and overwrites it.;  
;
; KEYWORD PARAMETERS:
;        RESULT -> returns 1 if conversion was successful, 0 otherwise
;            This keyword is mostly for consistency witholder routines.
;            It is more convenient to test !ERROR_STATE.CODE for being
;            0.
;
;        _EXTRA=e -> Passes extra keywords to CONVERT_UNIT.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ===============================
;        CONVERT_UNIT 
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;        mgs, 26 Aug 1998: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Added std documentation header
;
;-
; Copyright (C) 1998-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine fconvert_unit"
;-----------------------------------------------------------------------


function FConvert_Unit, Data, Unit, ToParam, Result=Result, _EXTRA=e
 
    ; simply take data, call convert_unit procedure and return data

    Convert_Unit, Data, Unit, ToParam, Result=Result, _EXTRA=e
 
    return, data
 
end
 
