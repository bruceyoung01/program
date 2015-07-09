; $Id$
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
;             the data array.  If not passed, RANGE will be computed.
;             RANGE is saved as the "valid_range" attribute.
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
;        Uses the following IDL netCDF routines:
;        ========================================
;        NCDF_Control    NCDF_VarDef (function)
;        NCDF_AttPut     NCDF_VarPut
;
; REQUIREMENTS:
;        Need to use a version of IDL w/ netCDF routines installed.
;
; NOTES:
;        (1) The min and max of DATA will be written to the HDF file
;            as the "valid_range" attribute.  
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
;        DIM1 = NCDF_DIMSET( FID, 'Length', S[0] )
;        DIM2 = NCDF_DIMSET( FID, 'Width',  S[1] )
;
;        ; Go into netCDF DATA mode
;        NCDF_CONTROL, /ENDEF
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
;
;-
; Copyright (C) 2002, Bob Yantosca, Harvard University
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
   ; Keyword settings
   ;====================================================================
   if ( N_Elements( fId   ) eq 0 ) then Message, 'FID not passed!'
   if ( N_Elements( Data  ) eq 0 ) then Message, 'DATA not passed!'
   if ( N_Elements( Name  ) eq 0 ) then Message, 'NAME not passed!'
   if ( N_Elements( Dims  ) eq 0 ) then Message, 'DIMS not passed!'
   if ( N_Elements( Range ) eq 0 ) then Range = [ Min( Data, Max=M ), M ] 

   ;====================================================================
   ; Define netCDF variable name & attributes
   ;====================================================================
 
   ; Enter netCDF Definition mode 
   NCDF_Control, fId, /ReDef
 
   ; Create a variable to hold the data
   vId = NCDF_VarDef( fId, Name, Dims, /Float )
 
   ; Error check
   if ( vId lt 0 ) then Message, 'Could not define variable!'
   
   ; If LONGNAME is passed, write it as an attribute
   if ( N_Elements( LongName ) eq 1 ) $
      then NCDF_AttPut, fId, vId, 'long_name', LongName
 
   ; If UNIT is passed, write it as an attribute
   if ( N_Elements( Unit ) eq 1 ) $
      then NCDF_AttPut, fId, vId, 'unit', Unit
 
   ; Put the range of the data as an attribute (always saved to file)
   NCDF_AttPut, fId, vId, 'valid_range', Range
 
   ;====================================================================
   ; Write data to the netCDF file
   ;====================================================================
 
   ; Enter netCDF data mode
   NCDF_Control, fId, /Endef
 
   ; Write the data
   NCDF_VarPut, fId, vId, Data
 
   return
end
 
 
