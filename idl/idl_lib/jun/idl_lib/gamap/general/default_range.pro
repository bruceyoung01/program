; $Id: default_range.pro,v 1.1.1.1 2007/07/17 20:41:40 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        DEFAULT_RANGE  (function)
;
; PURPOSE:
;        Make sure a RANGE argument or keyword is a valid vector with 
;        at least two elements.  Can also be used to limit RANGE to
;        two elements.  The argument may be a string containing one or 
;        more numeric values delimited by almost any character 
;        combination (including '..' and '-').  A '-' will be treated 
;        as a separator if it is preceeded by a digit or not followed
;        by a digit.  The resulting range will be sorted and spans the 
;        minimum and maximum of the "data" given in the argument.
;
; CATEGORY:
;        General
;
; CALLING SEQUENCE:
;        RANGE = DEFAULT_RANGE( ARG, DEFAULT [,/LIMIT2] )
;
; INPUTS:
;        ARG -> The range argument or keyword as passed into 
;              a procedure or function. This can be an undefined
;              variable or a variable with 1 or more elements.
;              If ARG contains 1 element, it will be repeated 
;              to range from and to the same number.
;
;        DEFAULT -> A 2-element vector containing the default range 
;              if ARG is undefined. This argument is mandatory
;              although it is not used if ARG contains at least 
;              1 element.
;
; KEYWORD PARAMETERS:
;        /LIMIT2 -> Limit the resulting RANGE vector to 2 elements.
;               Default is to return *at least* 2 elements.
;
;        RANGE -> Limit the RANGE vector to minimum and maximum 
;               value given by this keyword.
;
;        /NOSORT -> Do not sort the output. This can be useful for
;               longitude vectors spanning the Pacific ;-)
;
; OUTPUTS:
;        RANGE -> A two (or more) element vector that can be used in
;               statements like WHERE(x ge RANGE[0] AND x lt RANGE[1]).
;
; SUBROUTINES:
;        External Subroutines Required:
;        ============================================
;        ISALGEBRAIC (function)   ISDIGIT (function) 
;        STRBREAK    (function)   STRREPL (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        This function is meant for argument checking in procedures
;        or functions, hence it will generally not be called from the
;        command line.
;
; EXAMPLE:
;        LATRANGE = DEFAULT_RANGE( LATRANGE, [-90.,90.] )
;
;             ; Suppose a procedure has a keyword parameter named 
;             ; LATRANGE.  Before we use LATRANGE in any form, we 
;             ; should test it (as above).  This ensures that we have 
;             ; at least 2 elements in LATRANGE and it defaults
;             ; LATRANGE to the whole globe if nothing was passed 
;             ; in the LATRANGE keyword.
;
; MODIFICATION HISTORY:
;        mgs, 29 Sep 1998: VERSION 1.00
;        mgs, 17 Nov 1998: - added string handling
;                          - added RANGE and NOSORT keywords
;        bmy, 13 Jul 2001: TOOLS VERSION 1.48
;                          - now uses new STRREPL function from mgs
;        bmy, 16 Jul 2001: - bug fix: only call STRREPL if there are
;                            non-algebraic characters to be replaced
;                          - eliminate call to obsolete STR_SEP function
;        bmy, 17 Jan 2002: TOOLS VERSION 1.50
;                          - now call STRBREAK wrapper routine from
;                            the TOOLS subdirectory for backwards
;                            compatiblity for string-splitting
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
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
; or phs@io.harvard.edu with subject "IDL routine default_range"
;-----------------------------------------------------------------------


function defrange_str2num,sarg,default


    FORWARD_FUNCTION isdigit, isalgebraic, strrepl

    if (sarg eq '') then return,default

    ; Replace '..' range indicator with blanks
    while (strpos(sarg,'..') ge 0) do begin
        p = strpos(sarg,'..')
        l = strlen(sarg)
        sarg = strmid(sarg,0,p) + '  ' + strmid(sarg,p+2,l-p)
    endwhile

    ; Special treatment of '-' character:
    ; - if succeeded by a non-numeric character, it must be a range 
    ;   indicator: replace with blank
    ; - if between two numeric characters: same thing

    p = 1
    while (strpos(sarg,'-',p) ge 0) do begin
        p = strpos(sarg,'-',p)
        l = strlen(sarg)
        if ( (isdigit(strmid(sarg,p-1,1)) or $
             not isdigit(strmid(sarg,p+1,1)) )  $
             AND (p lt (l-1)) ) then $
           sarg = strmid(sarg,0,p) + ' ' + strmid(sarg,p+1,l-p)
        p = p+1
    endwhile


    ; Replace all non-algebraic characters with blanks
    Ind  = Where( ( 1-IsAlgebraic(sarg) ) )

    if ( Ind[0] ge 0 ) then begin
       for I = 0L, N_Elements( Ind ) - 1L do begin
          SArg = StrRepl( SArg, StrMid( SArg, Ind[I], 1 ), ' ' )
       endfor
    endif

    ; extract numbers from string
    on_ioerror,conv_error

    ; Now use STRBREAK for backwards compatibility
    ; with all prior versions of IDL (bmy, 1/17/02)
    Result = StrBreak( StrCompress( StrTrim( SArg, 2 ) ), ' ' )
    Result = Float( Result )

    return,result

conv_error:
    if (n_elements(result) ge 2) then return,result[0:1]
    if (n_elements(result) ge 1) then return,result[0]
    return,default

end




function default_range, arg,default,limit2=limit2,range=range,nosort=nosort
 
 
    if (n_elements(default) ne 2) then begin
       message,'DEFAULT must have two elements!',/Cont
       return,[0.,0.]
    endif

    if (n_elements(arg) eq 0) then arg = default

    ; take care of string type arguments 
    ; (try to extract two valid numeric values)
    if (size(arg,/type) eq 7) then $
       numarg = defrange_str2num(arg,default)  $
    else  $
       numarg = arg

    case (n_elements(numarg)) of
      1    : result = [ numarg, numarg ]
 
      else : begin
             if (keyword_set(limit2)) then begin
                if (keyword_set(NOSORT)) then $
                   result = numarg[0:1] $
                else $
                   result = [ min(numarg,max=m), m ]  
             endif else  $
                 result = numarg
             end
    endcase

    if (n_elements(range) eq 2) then  $
       ; restrict result to range
       result = ( result > range[0] ) < range[1]

    ; sort result
    if (not keyword_set(NOSORT)) then result = result[sort(result)]


    return,result 
 
end
 
