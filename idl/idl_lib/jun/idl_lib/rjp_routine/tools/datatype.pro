;-------------------------------------------------------------
; $Id: datatype.pro,v 1.1.1.1 2003/10/22 18:09:37 bmy Exp $
;+
; NAME:
;        DATATYPE
;
; PURPOSE:
;        Returns the number (or name) of the data type
;        of an IDL scalar, array, structure, or object.
;
; CATEGORY:
;        Tools
;
; CALLING SEQUENCE:
;        RESULT = DATATYPE( Data [, Keywords ] )
;
; INPUTS:
;        DATA -> A variable (scalar, array, structure, or object)
;             whose data type is desired.
;
; KEYWORD PARAMETERS:
;        /NAME -> If set, will return the name of the data type
;             instead of the type number.
;        
; OUTPUTS:
;        The IDL data type number or data type name will be
;        contained in RESULT. 
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        The IDL data type numbers are:
;        -----------------------------------------
;        0  : undefined    6  : complex
;        1  : byte         7  : string
;        2  : int          8  : structure
;        3  : long         9  : double complex
;        4  : float        10 : pointer
;        5  : double       11 : object reference
; 
; EXAMPLE:
;        print, DATATYPE( 0d0 )
;             5
;
;             ; Double precision data is type 5
;
;        print, DATATYPE( 0d0, /Name )
;             DOUBLE
;
;             ; Returns the name of the data type
;
; MODIFICATION HISTORY:
;        bmy, 26 Jul 1999: VERSION 1.00
;
;-
; Copyright (C) 1999, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine datatype"
;-------------------------------------------------------------


function DataType, Data, Name=Name
 
   ; String of data types
   TypeStr  = [ 'UNDEFINED',      'BYTE',    'INT',               $
                'LONG',           'FLOAT',   'DOUBLE',            $       
                'COMPLEX',        'STRING',  'STRUCTURE',         $
                'DOUBLE COMPLEX', 'POINTER', 'OBJECT REFERENCE' ]
 
   ; The data type is the 2nd to last element of 
   ; the vector returned by the SIZE command
   SData = Size( Data )
   Type  = SData[ N_Elements( SData ) - 2 ]
 
   ; If /STRING was set, then return the string representation 
   ; of the data type.  Otherwise, just return the type number.
   if ( Keyword_Set( Name ) )    $
      then return, TypeStr[ Type ]  $
      else return, Type
 
end
