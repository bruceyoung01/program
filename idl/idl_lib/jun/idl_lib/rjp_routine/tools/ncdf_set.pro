; $Id: ncdf_set.pro,v 1.1.1.1 2003/10/22 18:09:37 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        NCDF_SET
;
; PURPOSE:
;        Convenience routine to write data into netCDF format.
;
; CATEGORY:
;        netCDF Tools
;
; CALLING SEQUENCE:
;        NCDF_SET, FID, DATA, NAME, DIMS [, Keywords ]
;
; INPUTS:
;        FID -> HDF File ID, as returned by routine NCDF_CREATE.
;
;        DATA -> Data (array or scalar) to be written to netCDF file.
;
;        NAME -> Name under which the data array will be saved 
;             to the netCDF file.  
;
; KEYWORD PARAMETERS:
;        LONGNAME -> Longer descriptive name for the data.  
;             This will be saved as the "long_name" attribute.  
;
;        RANGE -> A 2-element vector containing the [min,max] of
;             the data array.  If not passed, RANGE will be computed
;             (but only if DATA is a numeric type).  RANGE is saved 
;             to the netCDF file as the "valid_range" attribute.
;
;        UNIT -> String containing the units of the data. 
;             This will be saved as the "unit" attribute.       
;
;        _EXTRA=e -> Picks up extra keywords
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        Uses the following routines:
;        =====================================================
;        NCDF_Control    NCDF_VarDef     (function)
;        NCDF_AttPut     DATATYPE        (function from TOOLS)
;        NCDF_VarPut     NCDF_VALID_NAME (function from TOOLS)   
;
; REQUIREMENTS:
;        Need to use a version of IDL w/ netCDF routines installed.
;        Also references routines from the TOOLS package.
;
; NOTES:
;        (1) For now, treat BYTE data like CHAR data.  This is
;            most likely since netCDF does not support STRING types,
;            strings have to be stored as arrays of bytes.
;
; EXAMPLE:
;
;        ; Define array to write to file
;        ARRAY = DIST( 100, 50 )
;
;        ; Find out if netCDF is supported on this platform
;        IF ( NCDF_EXISTS() eq 0 ) then MESSAGE, 'netCDF not supported!'
;
;        ; Open netCDF file and get the file ID # (FID)
;        FID = NCDF_CREATE( 'myfile.nc', /CLOBBER )
;        IF ( FID lt 0 ) then Message, 'Error opening file!'
;
;        ; Set dimensions for netCDF file
;        S    = SIZE( ARRAY, /DIM ) 
;        DIM1 = NCDF_DIMDEF( FID, 'Length', S[0] )
;        DIM2 = NCDF_DIMDEF( FID, 'Width',  S[1] )
;
;        ; Go into netCDF DATA mode
;        NCDF_CONTROL, FID, /ENDEF
;
;        ; Call NCDF_SET to write the array to the file
;        NCDF_SET, FID, ARRAY, 'My Data', [ DIM1, DIM2 ], $
;                  LONGNAME='Data array created by me!',  $
;                  UNIT='unitless'
;
;        ; Close the netCDF file
;        NCDF_CLOSE, FID
;
; MODIFICATION HISTORY:
;        bmy, 19 Apr 2002: TOOLS VERSION 1.50
;        bmy, 10 Sep 2002: TOOLS VERSION 1.51
;                          - Now call routine DATATYPE to determine
;                            the type of the data so that we can
;                            write to the netCDF file appropriately
;                          - Don't add the RANGE attribute to
;                            the netCDF file for a string type value.
;                          - Updated comments 
;        bmy, 21 Oct 2003: TOOLS VERSION 1.53
;                          - now "sanitize" the netCDF variable name
;                            w/ routine NCDF_VALID_NAME.  The new netCDF
;                            library in IDL 6.0+ chokes on bad characters.
;
;-
; Copyright (C) 2002-2003, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ncdf_set"
;-----------------------------------------------------------------------


pro NCDF_Set, fId, Data, Name, Dims, $
              LongName=LongName, Range=Range, Unit=Unit, _EXTRA=e

   ;====================================================================
   ; Initalization
   ;====================================================================
   
   ; External Functions
   FORWARD_FUNCTION DataType, NCDF_Valid_Name

   ; Keyword Settings
   if ( N_Elements( fId   ) eq 0 ) then Message, 'FID not passed!'
   if ( N_Elements( Data  ) eq 0 ) then Message, 'DATA not passed!'
   if ( N_Elements( Name  ) eq 0 ) then Message, 'NAME not passed!'
   if ( N_Elements( Dims  ) eq 0 ) then Message, 'DIMS not passed!'

   ; Get the type of the data to be written to the file
   Type = DataType( Data, /Name )

   ; ERROR: undefined type!
   if ( Type eq 'UNDEFINED' ) then Message, 'DATA array is UNDEFINED!'

   ; Default data range 
   if ( Type eq 'STRING'     OR Type eq 'POINTER'            OR $
        Type eq 'STRUCTURE'  OR Type eq 'OBJECT REFERENCE' ) then begin

      ; Force RANGE to be UNDEFINED for non-numeric data types
      UnDefine, Range

   endif else begin
      
      ; Set RANGE to [ min, max ] if it isn't passed explicitly
      if ( N_Elements( Range ) eq 0 ) then Range = [ Min( Data, Max=M ), M ] 

   endelse

   ;====================================================================
   ; Define netCDF variable name & attributes
   ;====================================================================
 
   ; Enter netCDF Definition mode 
   NCDF_Control, fId, /ReDef

   ; Strip out "bad" characters from netCDF var name.  In IDL 6.0+,
   ; NCDF_VARDEF chokes if the var name has special characters
   NewName = NCDF_Valid_Name( Name )

   ; Create a variable to hold the data
   case ( Type ) of
      ;--------------------------------------------------------------------
      ; Prior to 10/21/03:
      ; Now use "sanitized" variable name string
      ;'BYTE'   : vId = NCDF_VarDef( fId, Name, Dims, /Char   )
      ;'DOUBLE' : vId = NCDF_VarDef( fId, Name, Dims, /Double )
      ;'FLOAT'  : vId = NCDF_VarDef( fId, Name, Dims, /Float  )
      ;'LONG'   : vId = NCDF_VarDef( fId, Name, Dims, /Long   )
      ;'INT'    : vId = NCDF_VarDef( fId, Name, Dims, /Short  )
      ;--------------------------------------------------------------------
      'BYTE'   : vId = NCDF_VarDef( fId, NewName, Dims, /Char   )
      'DOUBLE' : vId = NCDF_VarDef( fId, NewName, Dims, /Double )
      'FLOAT'  : vId = NCDF_VarDef( fId, NewName, Dims, /Float  )
      'LONG'   : vId = NCDF_VarDef( fId, NewName, Dims, /Long   )
      'INT'    : vId = NCDF_VarDef( fId, NewName, Dims, /Short  )
      else     : Message, 'Type not supported by netCDF!'
   endcase

   ; Error check
   if ( vId lt 0 ) then Message, 'Could not define variable!'
   
   ; If LONGNAME is passed, write it as an attribute
   if ( N_Elements( LongName ) eq 1 ) $
      then NCDF_AttPut, fId, vId, 'long_name', LongName
 
   ; If UNIT is passed, write it as an attribute
   if ( N_Elements( Unit ) eq 1 ) $
      then NCDF_AttPut, fId, vId, 'unit', Unit
 
   ; Put the range of the data as an attribute (numeric types only) 
   if ( DataType( Range, /Name ) ne 'UNDEFINED' ) $
      then NCDF_AttPut, fId, vId, 'valid_range', Range
 
   ;====================================================================
   ; Write data to the netCDF file
   ;====================================================================
 
   ; Enter netCDF data mode
   NCDF_Control, fId, /Endef
 
   ; Write the data
   NCDF_VarPut, fId, vId, Data
 
   return
end
 
 
