; $Id: ncdf_valid_name.pro,v 1.2 2004/06/03 18:01:27 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        NCDF_VALID_NAME
;
; PURPOSE:
;        Strips invalid characters from a string which is to be
;        used as a netCDF variable name.  Based on original code
;        by Martin Schultz.
;
; CATEGORY:
;        netCDF tools
;
; CALLING SEQUENCE:
;        RESULT = NCDF_VALID_NAME( ARG )
;
; INPUTS:
;        ARG -> netCDF variable name string to be examined.
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        RESULT -> New netCDF name string with "bad" characters
;             replaced by "good" characters.
;
; SUBROUTINES:
;        External Subroutines Used:
;        ==========================
;        STRREPL (function)
;
; REQUIREMENTS:
;        References routines from the TOOLS package.
;
; NOTES:
;        In IDL 6.0+, the netCDF library has been updated.  Some
;        characters which used to be allowed in netCDF variable names
;        are no longer allowed.  Therefore, use this function to
;        replace "bad" characters with "good" characters when 
;        reading or writing to/from netCDF files.
;
; EXAMPLE:
;        RESULT = NCDF_VALID_NAME( 'IJ-AVG-$::CO' )
;        PRINT, RESULT
;
;             ; Prints "IJ-AVG-S__CO"
;
; MODIFICATION HISTORY:
;        bmy, 21 Oct 2003: VERSION 1.00
;
;-
; Copyright (C) 2003, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ncdf_valid_name"
;-----------------------------------------------------------------------


function NCDF_Valid_Name, Arg
   
   ;====================================================================
   ; Initialization
   ;====================================================================
 
   ; External functions
   FORWARD_FUNCTION StrRepl
 
   ; Init
   if ( N_Elements( Arg ) ne 1 ) then Message, 'Need to pass ARG!'
 
   ;====================================================================
   ; Replace bad characters for netCDF var names w/ good characters!
   ;====================================================================
   t = StrRepl( Arg, '+', 'P' )
   t = StrRepl( t,   '$', 'S' )
   t = StrRepl( t,   '*', 'A' )
   t = StrRepl( t,   '&', '_' )
   t = StrRepl( t,   ' ', '_' )
   t = StrRepl( t,   '@', '_' )
   t = StrRepl( t,   ':', '_' )
   t = StrRepl( t,   '=', '_' ) 
   t = StrRepl( t,   '=', '-' ) 
   t = StrRepl( t,   '#', '_' ) 
   t = StrRepl( t,   '(', '_' ) 
   t = StrRepl( t,   ')', '_' ) 
 
   ; Return to calling program
   return, t
end
