; $Id: ncdf_get.pro,v 1.2 2004/01/29 19:43:05 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        NCDF_GET
;
; PURPOSE:
;        Convenience routine to read data into netCDF format.
;
; CATEGORY:
;        netCDF Tools
;
; CALLING SEQUENCE:
;        DATA = NCDF_GET( FID, NAME [, Keywords ] )
;
; INPUTS:
;        FID -> netCDF File ID, as returned by routine NCDF_OPEN.
;
;        NAME -> Name under which the data array will be saved 
;             to the netCDF file.  
;
; KEYWORD PARAMETERS:
;        VARINFO -> Returns a structure containing information
;             about the variable read in from disk.  The structure
;             has the following form:
;
;             { NAME      : "", $
;               DATATYPE  : "", $
;               NDIMS     : 0L, $
;               NATTS     : 0L, $
;               DIM       : LONARR(NDIMS) }
;
;
;        LONGNAME -> Returns the value saved under the "long_name" 
;             attribute in the netCDF file.
;
;        UNIT -> Returns the value of the "unit" attribute 
;             saved in the netCDF file.
;
;        RANGE -> Returns the value of the "valid_range" 
;             saved in the netCDF file
;
;        _EXTRA=e -> Picks up extra keywords got NCDF_VarGet.
;
; OUTPUTS:
;        DATA -> Array containing extracted data from the netCDF file.
;
; SUBROUTINES:
;        Uses the following IDL netCDF routines:
;        ========================================
;        NCDF_VarId   (function)  NCDF_VarGet
;        NCDF_VarInfo (function)  NCDF_AttGet
;        NCDF_AttName (function)
;
; REQUIREMENTS:
;        Need to use a version of IDL w/ netCDF routines installed.
;
; NOTES:
;        (1) Only looks for the "long_name", "unit", and "valid_range"
;            attributes.  The user can extend this as he/she desires.
;            For a more general program, see ~/IDL/tools/ncdf_read.pro
;            by Martin Schultz.
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
;        FID   = NCDF_OPEN( 'myfile.nc' )
;        IF ( FID lt 0 ) then Message, 'Error opening file!'
;
;        ; Read data from the netCDF file
;        ; Return data attributes in the VARINFO array
;        ; Also returns the text from the UNIT string
;        DATA = NCDF_GET( FID, 'BIOBSRCE::NOx', $
;                         VARINFO=VARINFO, UNIT=UNIT ) 
;
;        ; Close the netCDF file
;        NCDF_CLOSE, FID
;
; MODIFICATION HISTORY:
;        bmy, 22 May 2002: TOOLS VERSION 1.50
;        bmy, 21 Oct 2003: TOOLS VERSION 1.53
;                          - If we can't find a netCDF variable name,
;                            then try again using a "sanitized" name
;                            w/ all bad characters stripped out
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
; with subject "IDL routine ncdf_get"
;-----------------------------------------------------------------------


function NCDF_Get, fId, Name,                      $
                   VarInfo=VarInfo,   Unit=Unit,   $
                   LongName=LongName, Range=Range, $
                   _EXTRA=e

   ;====================================================================
   ; Initialization
   ;====================================================================
   
   ; External functions
   FORWARD_FUNCTION NCDF_Valid_Name

   ; Keywords
   if ( N_Elements( fId  ) eq 0 ) then Message, 'FID not passed!'
   if ( N_Elements( Name ) eq 0 ) then Message, 'NAME not passed!'

   ;====================================================================
   ; Get information about the variable in the file
   ;====================================================================

   ; Get the netCDF variable ID # (vID)
   vId = NCDF_VarId( fId, Name )

   ; Error check vId
   if ( vId lt 0 ) then begin

      ; Strip out "bad" characters from netCDF var name.  If the 
      ; netCDF file was created w/ bpch2nc.pro then the var name
      ; had all "bad" characters stripped out beforehand.
      NewName = NCDF_Valid_Name( Name )

      ; Informational message
      S = 'Could not find ' + StrTrim( Name,    2 ) + $
          '; Trying '       + StrTrim( NewName, 2 )
      Message, S, /Continue

      ; Try again w/ the new variable name
      vId = NCDF_VarID( fId, NewName )
      
      ; If this still doesn't work, then stop w/ err msg
      if ( vId lt 0 ) then begin
         S = StrTrim( NewName, 2 ) + ' is an invalid variable name!'
         Message, S
      endif
   endif

   ; Get a structure w/ information about this variable
   VarInfo = NCDF_VarInq( fId, vId )
   
   ;====================================================================
   ; Read variable attributes from the netCDF file
   ;====================================================================

   ; Loop thru # of attributes
   for N = 0L, VarInfo.NAtts-1L do begin

      ; Search by attribute name
      case ( NCDF_AttName( fId, vId, N ) ) of

         ; Descriptive long name: convert from BYTE to STRING
         'long_name' : begin
            NCDF_AttGet, fId, vId, 'long_name', LongName
            LongName = StrTrim( LongName, 2 )
         end

         ; Units: convert from BYTE to STRING
         'unit' : begin
            NCDF_AttGet, fId, vId, 'unit', Unit
            Unit = StrTrim( Unit, 2 )
         end

         ; If "unit" is not an attribute, try "units"
         'units' : begin
            NCDF_AttGet, fId, vId, 'units', Unit
            Unit = StrTrim( Unit, 2 )
         end

         ; Data range
         'valid_range' : NCDF_AttGet, fId, vId, 'valid_range', Range

         ; Otherwise skip
         else : ; Nothing
      endcase

   endfor

   ;====================================================================
   ; Read data from the netCDF file
   ;====================================================================

   ; Read the data
   NCDF_VarGet, fId, vId, Data, _EXTRA=e

   ; Return DATA array to calling program
   return, Data
      
end

