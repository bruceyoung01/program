; $Id$
;-----------------------------------------------------------------------
;+
; NAME:
;        HDF_SETSD
;
; PURPOSE:
;        Convenience routine to write data into the Hierarchical Data
;        Format Scientific Dataset (HDF-SD) structure
;
; CATEGORY:
;        HDF_TOOLS
;
; CALLING SEQUENCE:
;        HDF_SETSD, FID, DATA [, Keywords ]
;
; INPUTS:
;        FID -> HDF File ID, as returned by routine HDF_SD_START.
;
;        DATA -> Data (array or scalar) to be written to HDF-SD format.
;
; KEYWORD PARAMETERS:
;        NAME -> Name of the scientific dataset variable that
;             you want to wrote to the file.  
;
;        LONGNAME -> Longer descriptive name for the data.  This will 
;             be added as the "long_name" attribute.  Default is ''.
;
;        RANGE -> A 2-element vector containing the [min,max] of
;             the data array.  If not passed, RANGE will be computed.
;
;        _EXTRA=e -> picks up extra keywords for HDF_SD_SETINFO, such
;             as FILL, UNIT, COORDSYS, etc...
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        Uses core IDL routines:
;        -----------------------------------------------
;        HDF_SD_Create (function)  HDF_SD_SetInfo
;        HDF_SD_AddData            HDF_SD_EndAccess  
;
; REQUIREMENTS:
;        Need to use a version of IDL w/ HDF routines installed.
;
; NOTES:
;        None.
;
; EXAMPLE:
;        FID = HDF_SD_START( 'myhdf.hdf', /Create )
;        IF ( FID lt 0 ) then Message, 'Error opening file!'
;
;        HDF_SETSD, FID, DATA, 'NOx',         $
;                   LONGNAME='Nitrogen Oxide',$
;                   UNIT='v/v',               $
;                   FILL=0.0, 
;
;        HDF_SD_END, FID
;
;             ; Writes NOx data to an HDF file.
;
; MODIFICATION HISTORY:
;        bmy, 17 Apr 2002: TOOLS VERSION 1.50
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
; with subject "IDL routine hdf_setsd"
;-----------------------------------------------------------------------


PRO HDF_SetSD, fId, Data, Name, $
               LongName=LongName, Range=Range, _EXTRA=e
 
   ;====================================================================
   ; Keyword settings
   ;====================================================================
   if ( N_Elements( fId      ) ne 1 ) then Message, 'fId not passed!'
   if ( N_Elements( Data     ) eq 0 ) then Message, 'DATA not passed!'
   if ( N_Elements( Name     ) ne 1 ) then Message, 'NAME not passed!'
   if ( N_Elements( LongName ) ne 1 ) then LongName = ''
   if ( N_Elements( Range    ) eq 0 ) then Range    = [ Min( Data, Max=M ), M ]

   ;====================================================================
   ; Write data to the HDF file
   ;====================================================================
 
   ; Initialize HDF_SD interface for this data array
   sId = HDF_SD_Create( fId, Name, Size( Data, /Dim ), /Float )
 
   ; Define attributes for the data
   HDF_SD_SetInfo, sId, Label=LongName, Range=Range, _EXTRA=e
    
   ; Create and write the data -- make sure it's FLOAT!
   HDF_SD_AddData, sId, Float( Data )
        
   ; Terminate HDF-SD interface and quit
   HDF_SD_EndAccess, sId
 
   return
end
 
 
