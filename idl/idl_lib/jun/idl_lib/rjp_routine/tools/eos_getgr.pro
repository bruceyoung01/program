; $Id: eos_getgr.pro,v 1.1.1.1 2003/10/22 18:09:40 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        EOS_GETGR
;
; PURPOSE: 
;        Convenience routine to read variables from an HDF-EOS
;        grid data structure.
;
; CATEGORY:
;        HDF Tools
;
; CALLING SEQUENCE:
;        DATA = EOS_GETGR( FID, NAME [, Keywords, _EXTRA=e ] )
;
; INPUTS:
;        FID -> HDF File ID, as returned by routine EOS_SW_START.
;
;        NAME -> Name of the HDF-EOS grid dataset variable that
;             you want to extract from the HDF-EOS file. 
;
; KEYWORD PARAMETERS:
;        GRIDNAME -> Name of the HDF-EOS grid under which the data
;             is stored in the file.  You can use the IDL HDF_BROWSER
;             routine to easily find the grid name. 
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
;        FID = EOS_GD_OPEN( 'gridfile.hdf', /READ )
;        IF ( FID lt 0 ) THEN MESSAGE, 'Error opening file!'
;
;        ; Read a variable from a grid file
;        DATA = EOS_GETGR( fId, 'Latitude', GRIDNAME='GRID1' )
;
;        ; Close the file 
;        STATUS = EOS_SW_CLOSE( FID )
;        IF ( STATUS lt 0 ) THEN MESSAGE, 'Error closing file!'
;
; MODIFICATION HISTORY:
;        bmy, 18 Sep 2002: TOOLS VERSION 1.51
;        bmy, 19 Dec 2002: TOOLS VERSION 1.52
;                          - fixed typos
;        bmy, 04 Jun 2003: TOOLS VERSION 1.53
;                          - fixed more typos
;
;-
; Copyright (C) 2001-2003, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine eos_getgr"
;-----------------------------------------------------------------------


function EOS_GetGR, fId, Name, GridName=GridName, _EXTRA=e
  
   ;====================================================================
   ; Attach to the grid in the HDF-EOS file
   ;====================================================================
   gId = EOS_GD_Attach( fId, GridName )
 
   ; Error check
   if ( gId lt 0 ) then begin
      S = 'Could not attach to grid ' + StrTrim( GridName, 2 ) + '!'
      Message, S  
   endif

   ;====================================================================
   ; Read a data field from the file
   ;====================================================================
   Status = EOS_GD_ReadField( gId, Name, Data, _EXTRA=e )
   
   ; Error check
   if ( Status lt 0 ) then begin
      S = 'Could not read ' + StrTrim( Name, 2 ) + ' from the file!'
      Message, S
   endif
       
   ;====================================================================
   ; Detach from the HDF-EOS grid
   ;====================================================================
   Status = EOS_GD_Detach( gId )
   
   ; Error check
   if ( Status lt 0 ) then begin
      S = 'Could not detach from grid ' + StrTrim( GridName, 2 ) + '!'
      Message, S
   endif

   ; Return the data to the main program
   return, Data
 
end
