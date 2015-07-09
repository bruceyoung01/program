; $Id: convert_unit.pro,v 1.1.1.1 2003/10/22 18:09:39 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        CONVERT_UNIT
;
; PURPOSE:
;        Convert data to a different unit. You can either 
;        replace a unit by the corresponding standard SI unit or 
;        replace a specific unit with another one.
;
; CATEGORY:
;        Tools
;
; CALLING SEQUENCE:
;        CONVERT_UNIT,DATA,UNIT,TOPARAM [,keywords]
;
; INPUTS:
;        DATA -> A data vector, array, or a single value that shall
;            be converted to a new unit. 
;
;        UNIT -> A string variable containing the (current) unit of 
;            DATA. This will be replaced by the new unit afterwards.
;            If omitted, you must give the FROM_UNIT keyword to indicate
;            the current unit of DATA.
;
;        TOPARAM -> The unit to convert DATA to. This is equivalent to 
;            the keyword TO_UNIT and overwrites it.
;
; KEYWORD PARAMETERS:
;        FROM_UNIT -> An individual unit to search and replace. If not
;            given, any unit will be converted to TO_UNIT, as long as
;            the current unit belongs to the same category. 
;
;        TO_UNIT -> An individual unit to convert to. If not given, all
;            unit that are converted (see FROM_UNIT) will be replaced
;            by the standard SI unit of their category.
;
;        For the individual unit and categories see FIND_UNIT 
;
;        RESULT -> returns 1 if conversion was successful, 0 otherwise
;            This keyword is mostly for consistency witholder routines.
;            It is more convenient to test !ERROR_STATE.CODE for being
;            0.
;
;        MINVAL -> minimum valid data value. Only data above this 
;            value will be converted (default: -1.E30)
;
;        QUIET -> In case of an error, an error message is displayed,
;            and the !ERROR_STATUS system variable is set to reflect the
;            error condition (program execution continues). Set the
;            QUIET keyword to suppress the error message.
;
; OUTPUTS:
;        DATA will be converted and unit will contain new names.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        Uses FIND_UNIT
;
; NOTES:
;        CONVERT_UNIT wil return the value and unit unchanged if
;        the unit was not found in the standard list (see FIND_UNIT)
;        or the category of the target unit does not match the
;        category of the source unit. In these cases, !ERROR_STATE.CODE
;        will be set to signal an error condition.
;
; EXAMPLE:
;        ; create some data
;        data = findgen(100)
;        unit = 'cm'
;
;        ; convert all data to SI unit of same category (m)
;        convert_unit,data,unit
;
;        ; test success
;        if (!ERROR_STATE.CODE ne 0) then stop
;
;        ; convert temperature in Fahrenheit to 'deg C'
;        ; (multiple calls to capture all different spellings)
;        ; Data will only be changed if unit is indeed Fahrenheit
;        convert_unit,data,unit,from='F',to='deg C'
;        convert_unit,data,unit,from='degF',to='deg C'
;        convert_unit,data,unit,from='deg F',to='deg C'
;
;        ; (easier way) convert any temperature to 'C'
;        ; This will also convert 'K' !
;        ; Don't display error message
;        convert_unit,data,unit,to='C',/QUIET
;
;        ; convert 'mph' data to SI ('m/s')
;        convert_unit,data,unit,from='mph'
;
;        ; explicitely convert 'cm' to 'm'
;        convert_unit,data,'cm','m'
;        ; equivalent to
;        convert_unit,data,from='cm',to='m'
;
; MODIFICATION HISTORY:
;        mgs, 26 Aug 1998: VERSION 1.00
;        mgs, 27 Aug 1998: 
;            - added RESULT and QUIET keywords
;            - improved error handling
;
;-
; Copyright (C) 1998, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine convert_unit"
;-------------------------------------------------------------


pro convert_unit,data,unit,toparam,   $
           from_unit=from_unit,to_unit=to_unit, $
           result=result,minval=minval,quiet=quiet
 
 

    message,/reset   ; reset error state
    result = 0 
 
    if (n_elements(minval) eq 0) then minval = -1.0E30

    quiet = keyword_set(quiet)

    ; ============================================================ 
    ; Check validity of call
    ; ============================================================ 
 
    if (n_elements(UNIT) eq 0) then $
        if (n_elements(from_unit) gt 0) then unit = from_unit  $
        else begin
           message,'2 parameters required : DATA,UNIT',/CONT
           return
        endelse

    ; ============================================================ 
    ; Set dummy if no specific unit is requested to convert from
    ; ============================================================ 
 
    if (n_elements(from_unit) eq 0) then from_unit = 'ANY UNIT'

    ; ============================================================ 
    ; Find unit to convert to
    ; ============================================================ 

    ; to_unit as parameter overwrites keyword
    if (n_elements(toparam) gt 0) then to_unit = toparam
 
    if (n_elements(to_unit) gt 0) then begin
       Find_unit,to_unit,to_name,to_factor,to_offset,to_category
 
       if (to_category lt 0) then begin
          message,'Cannot find unit to convert to!',/CONT
          message,'Nothing will change.',/CONT
          return
       endif
 
       convert_to_si = 0
    endif else $
       convert_to_si = 1   ; no target unit given, convert all to SI
 
 
    ; ============================================================ 
    ; Convert data to new unit
    ; ============================================================ 
 
    factor = 1.0D

    ; check if unit must be converted 
    if (from_unit eq 'ANY UNIT' OR   $
        strlowcase(from_unit) eq strlowcase(unit) ) then begin

        ; find unit information about current unit
        find_unit,unit,dummy,from_factor,from_offset,from_category

        ; if all unit are to be converted to SI, find information
        ; about corresponding SI unit here
        ; (otherwise predetermined target information is used)
        if (convert_to_SI) then $
           find_unit,unit,to_name,to_factor,to_offset,to_category, $
                  /get_si


        ; unit found ?
        if (from_category ge 0) then begin

        ; if category matches convert
           if (from_category eq to_category) then begin

              ind = where(data gt minval)
              if (ind[0] ge 0) then $
                  data[ind] = ( (from_factor*data[ind]+from_offset) $
                                  - to_offset ) / to_factor

; debug output
message,'converted '+unit+'->'+to_name+': '+  $
        string([from_factor,from_offset,to_factor,to_offset],format='(4g12)'), $
        /INFO,/NONAME

              unit = to_name
              result = 1   ; operation successful
           endif else  $
           ; categories do not match
              message,'Units not compatible.',/CONT,NOPRINT=QUIET

        endif else  $
        ; unit not found
           message,'Unit not found in standard list.',/CONT,NOPRINT=QUIET
    endif
 
 
 
    return
end
