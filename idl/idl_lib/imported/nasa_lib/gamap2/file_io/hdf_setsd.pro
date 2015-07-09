; $Id: hdf_setsd.pro,v 1.1.1.1 2007/07/17 20:41:39 bmy Exp $
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
;        File & I/O, Scientific Data Formats
;
; CALLING SEQUENCE:
;        HDF_SETSD, FID, DATA, NAME [, Keywords ]
;
; INPUTS:
;        FID -> HDF File ID, as returned by routine HDF_SD_START.
;
;        DATA -> Data (array or scalar) to be written to HDF-SD format.
;
;        NAME -> Name under which the data array will be saved 
;             to the HDF file.  
;
; KEYWORD PARAMETERS:
;        LONGNAME -> Longer descriptive name for the data.  This will 
;             be saved as the "long_name" attribute.  Default is ''.
;
;        RANGE -> A 2-element vector containing the [min,max] of
;             the data array.  If not passed, RANGE will be computed
;             (but only for numeric data types).  RANGE will be saved 
;             to the HDF file as the "valid_range" attribute.
;
;        _EXTRA=e -> picks up extra keywords for HDF_SD_SETINFO, such
;             as FILL, UNIT, COORDSYS, etc...
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        Uses the following IDL HDF routines:
;        ===========================================
;        HDF_SD_Create (function)  HDF_SD_SetInfo
;        HDF_SD_AddData            HDF_SD_EndAccess 
;        DATATYPE      (function) 
;
; REQUIREMENTS:
;        Need to use a version of IDL w/ HDF routines installed.
;
; NOTES:
;        (1) Since HDF supports the STRING type, we do not have to
;            treat BYTE data like ASCII characters (cf ncdf_set.pro)
;
; EXAMPLE:
; 
;        ; Find out if HDF is supported on this platform
;        IF ( HDF_EXISTS() eq 0 ) then MESSAGE, 'HDF not supported!'
;
;        ; Open the HDF file
;        FID = HDF_SD_START( 'myhdf.hdf', /Create )
;        IF ( FID lt 0 ) then Message, 'Error opening file!'
;
;        ; Write data to disk
;        HDF_SETSD, FID, DATA, 'NOx',         $
;                   LONGNAME='Nitrogen Oxide',$
;                   UNIT='v/v',               $
;                   FILL=0.0, 
;
;        ; Close HDF File
;        HDF_SD_END, FID
;
;             ; Writes NOx data to an HDF file.
;
; MODIFICATION HISTORY:
;        bmy, 17 Apr 2002: TOOLS VERSION 1.50
;        bmy, 11 Sep 2002: TOOLS VERSION 1.51
;                          - Now call routine DATATYPE to determine
;                            the type of the data so that we can
;                            write all data types to the HDF file.
;                          - Don't add the RANGE attribute to
;                            the HDF file for a string type value.
;                          - Updated comments 
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2002-2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine hdf_setsd"
;-----------------------------------------------------------------------


PRO HDF_SetSD, fId, Data, Name, $
               LongName=LongName, Range=Range, _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION DataType

   ; Keywords
   if ( N_Elements( fId      ) ne 1 ) then Message, 'fId not passed!'
   if ( N_Elements( Data     ) eq 0 ) then Message, 'DATA not passed!'
   if ( N_Elements( Name     ) ne 1 ) then Message, 'NAME not passed!'
   if ( N_Elements( LongName ) ne 1 ) then LongName = ''

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
   ; Write data to the HDF file
   ;====================================================================
  
   ; Initialize HDF_SD interface for this data array
   case ( Type ) of
      'BYTE'   : sId = HDF_SD_Create( fId, Name, Size( Data, /Dim ), /Byte   )
      'STRING' : sId = HDF_SD_Create( fId, Name, Size( Data, /Dim ), /String )
      'DOUBLE' : sId = HDF_SD_Create( fId, Name, Size( Data, /Dim ), /Double )
      'FLOAT'  : sId = HDF_SD_Create( fId, Name, Size( Data, /Dim ), /Float  )
      'LONG'   : sId = HDF_SD_Create( fId, Name, Size( Data, /Dim ), /Long   )
      'INT'    : sId = HDF_SD_Create( fId, Name, Size( Data, /Dim ), /Short  )
      else     : Message, 'Type not supported by HDF!'
   endcase

   ; Define attributes for the data (omit RANGE for STRING type)
   case ( Type ) of
      'BYTE'   : HDF_SD_SetInfo, sId, Label=LongName, Range=Range, _EXTRA=e
      'STRING' : HDF_SD_SetInfo, sId, Label=LongName,              _EXTRA=e
      'DOUBLE' : HDF_SD_SetInfo, sId, Label=LongName, Range=Range, _EXTRA=e
      'FLOAT'  : HDF_SD_SetInfo, sId, Label=LongName, Range=Range, _EXTRA=e
      'LONG'   : HDF_SD_SetInfo, sId, Label=LongName, Range=Range, _EXTRA=e
      'INT'    : HDF_SD_SetInfo, sId, Label=LongName, Range=Range, _EXTRA=e
      else     : Message, 'Type not supported by HDF!'
   endcase
    
   ; Create and write the data
   HDF_SD_AddData, sId, Data 
        
   ; Terminate HDF-SD interface and quit
   HDF_SD_EndAccess, sId
 
   return
end
 
 
