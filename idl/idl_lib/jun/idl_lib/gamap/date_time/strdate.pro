; $Id: strdate.pro,v 1.1.1.1 2007/07/17 20:41:30 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        STRDATE (function)
;
; PURPOSE:
;        Format a "standard form" date string 
;
; CATEGORY:
;        Date & Time, Strings
;
; CALLING SEQUENCE:
;        RESULT = STRDATE( [ DATE ] [, Keywords ] )
;
; INPUTS:
;        DATE -> (OPTIONAL) Either a up to 6 element array containing 
;            year, month, day, hour, minute, and secs (i.e. the format 
;            returned from BIN_DATE) or a structure containing year, 
;            month, day, hour, minute, seconds (as returned from 
;            TAU2YYMMDD) or a date string in "standard" format as 
;            returned by SYSTIME(0).  If DATE is omitted, STRDATE will 
;            automatically return the current system time. 
;
; KEYWORD PARAMETERS:
;        /SHORT -> omit the time value, return only date
;
;        /SORTABLE -> will return 'YYYY/MM/DD HH:MM' 
;
;        /EUROPEAN -> will return 'DD.MM.YYYY HH:MM'
;
;        IS_STRING -> Indicates that DATE is a date string 
;            rather than an integer array.  This keyword is now 
;            obsolete but kept for compatibility.
;
; OUTPUTS:
;        RESULT -> A date string formatted as 'MM/DD/YYYY HH:MM'.
;            If SHORT flag is set, the format will be 'MM/DD/YYYY'
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================
;        DATATYPE (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) /EUROPEAN and /SORTABLE will have effect of 
;            /SORTABLE but with dots as date Seperators.
;
; EXAMPLES:
;        (1)
;        PRINT, STRDATE( [ 2001, 01, 01, 12, 30, 00 ] )
;           01/01/2001 12:30
;             ; Date string for 2001/01/01 12:30 in USA format
;
;        (2)
;        PRINT, STRDATE( [ 2001, 01, 01, 12, 30, 00 ], /EUROPEAN )
;           01.01.2001 12:30
;             ; Date string for 2001/01/01 12:30 in European format
;
;        (3)
;        PRINT, STRDATE( [ 2001, 01, 01, 12, 30, 00 ], /SORTABLE )
;           2001/01/01 12:30
;             ; Date string for 2001/01/01 12:30 in YYYY/MM/DD format
;
;        (4)
;        PRINT, STRDATE( [ 2001, 01, 01, 12, 30, 00 ], /SORTABLE, /SHORT )
;           2001/01/01
;             ; Date string for 2001/01/01 w/o hours and minutes
;
;        (5)
;        RESULT = TAU2YYMMDD( 144600D )
;        PRINT, STRDATE( RESULT, /SORTABLE )
;           2001/07/01 00:00
;             ; Use TAU2YYMMDD to convert a TAU value (in this case
;             ; for July 1, 2001) to a structure.  Then pass the
;             ; structure to STRDATE to make a string.
;
; MODIFICATION HISTORY:
;        mgs, 11 Nov 1997: VERSION 1.00
;        mgs, 26 Mar 1998: VERSION 1.10 
;                          - examines type of DATE parameter 
;                            and accepts structure input.
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Renamed /GERMAN to /EUROPEAN
;                          - Updated comments, cosmetic changes
;                          - Now uses function DATATYPE
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
; or phs@io.as.harvard.edu with subject "IDL routine strdate"
;-----------------------------------------------------------------------


function StrDate, Date,                                  $
                  Is_String=Is_String, Short=Short,      $
                  Sortable=Sortable,   European=European
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION DataType

   ; Keywords
   European = Keyword_Set( European )
   Sortable = Keyword_Set( Sortable )
   HHMM     = 1L - Keyword_Set( Short )

   ; If DATE is passed
   if ( N_Elements( Date ) gt 0 ) then begin

      ; Get type of data.  Test if it's a string or structure
      Dtype     = DataType( Date )
      Is_String = ( Dtype eq 7 )
      Is_Stru   = ( Dtype eq 8 )

      if ( Is_String ) then begin

         ; DATE is a string
         BDate = Bin_Date( Date) 

      endif else if ( is_stru ) then begin

         ; DATE is as structure
         BDate = intarr(6)
         for i = 0, 5 do begin
            BDate(i) = Fix( Date.(i) )
         endfor

      endif else begin

         ; Date is integer or floating point
         BDate = date

      endelse

   endif else begin

      ; If DATE is not passed, use system time
      BDate = bin_date()   

   endelse
     
   ; In case of not enough elements pad with zero's
   Tmp   = IntArr(6)
   BDate = [ BDate, tmp ]
 
   ; Convert to formatted string items
   BDate = strtrim( string( BDate, format='(i4.2)' ) , 2 )
 
   ; Determine date Separator
   if ( European )   $
      then Sep = '.' $
      else Sep = '/'

   ;====================================================================
   ; Compose Result string
   ;====================================================================

   ; Default : US format
   Result = BDate(1) + Sep + BDate(2) + Sep + BDate(0)

   ; European format, day first
   if ( European ) $
      then Result = BDate(2) + Sep + BDate(1) + Sep + BDate(0)

   ; Sortable: YYYY/MM/DD
   if( Sortable ) $
      then Result = BDate(0) + Sep+ BDate(1) + Sep + BDate(2)

   ; Also add hours and minutes
   if ( HHMM ) $
      then Result = Result +' ' + BDate(3) + ':' + BDate(4)
   
   ; Return to calling program
   return, Result
 
end
 
