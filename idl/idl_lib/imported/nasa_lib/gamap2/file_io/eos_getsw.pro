; $Id: eos_getsw.pro,v 1.1.1.1 2007/07/17 20:41:38 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        EOS_GETSW
;
; PURPOSE: 
;        Convenience routine to read variables from an HDF-EOS
;        satellite swath data structure.
;
; CATEGORY:
;        File & I/O, Scientific Data Formats
;
; CALLING SEQUENCE:
;        DATA = EOS_GETSW( FID, NAME [, Keywords, _EXTRA=e ] )
;
; INPUTS:
;        FID -> HDF File ID, as returned by routine EOS_SW_START.
;
;        NAME -> Name of the satellite swath dataset variable that
;             you want to extract from the HDF-EOS file. 
;
; KEYWORD PARAMETERS:
;        SWATHNAME -> Name of the HDF-EOS swath under which the data
;             is stored in the file.  You can use the IDL HDF_BROWSER
;             routine to easily find the swath name. 
;
;        _EXTRA=e -> Passes extra keywords to routine EOS_SW_READFIELD.
;
; OUTPUTS:
;        DATA -> Array containing extracted data from the HDF-EOS file.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        Need to use a version of IDL w/ HDF-EOS routines installed.
;
; NOTES:
;        None
;
; EXAMPLE:
;
;        ; Make sure HDF is supported on this platform
;        IF ( EOS_EXISTS() eq 0 ) then MESSAGE, 'HDF not supported!'
;
;        ; Open the HDF file and get the file ID # (FID)
;        FID = EOS_SW_OPEN( 'swathfile.hdf', /READ )
;        IF ( FID lt 0 ) THEN MESSAGE, 'Error opening file!'
;
;        ; Read a variable from a swath file
;        DATA = EOS_GETSW( fId, 'Latitude', SWATHNAME='swath1' )
;
;        ; Close the file 
;        STATUS = EOS_SW_CLOSE( FID )
;        IF ( STATUS lt 0 ) THEN MESSAGE, 'Error closing file!'
;
; MODIFICATION HISTORY:
;        bmy, 18 Sep 2002: TOOLS VERSION 1.51
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
; or phs@io.as.harvard.edu with subject "IDL routine eos_getsw";
;-----------------------------------------------------------------------


function EOS_GetSW, fId, Name, SwathName=SwathName, _EXTRA=e
  
   ;====================================================================
   ; Attach to the swath in the HDF-EOS file
   ;====================================================================
   sId = EOS_SW_Attach( fId, SwathName )
 
   ; Error check
   if ( sId lt 0 ) then begin
      S = 'Could not attach to swath ' + StrTrim( SwathName, 2 ) + '!'
      Message, S  
   endif

   ;====================================================================
   ; Read a data field from the file
   ;====================================================================
   Status = EOS_SW_ReadField( sId, Name, Data, _EXTRA=e )
   
   ; Error check
   if ( Status lt 0 ) then begin
      S = 'Could not read ' + StrTrim( Name, 2 ) + ' from the file!'
      Message, S
   endif
       
   ;====================================================================
   ; Detach from the HDF-EOS swath 
   ;====================================================================
   Status = EOS_SW_Detach( sId )
   
   ; Error check
   if ( Status lt 0 ) then begin
      S = 'Could not detach from swath ' + StrTrim( SwathName, 2 ) + '!'
      Message, S
   endif

   ; Return the data to the main program
   return, Data
 
end
