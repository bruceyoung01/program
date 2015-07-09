; $Id: hdf_getsd.pro,v 1.1.1.1 2003/10/22 18:09:39 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        HDF_GETSD
;
; PURPOSE: 
;        Convenience routine to read scientific dataset variables 
;        from Hierarchical Data Format (HDF) files
;
; CATEGORY:
;        HDF Tools
;
; CALLING SEQUENCE:
;        DATA = HDF_GETSD( FID, NAME [, _EXTRA=e ] )
;
; INPUTS:
;        FID -> HDF File ID, as returned by routine HDF_SD_START.
;
;        NAME -> Name of the scientific dataset variable that
;             you want to extract from the file.  
;
; KEYWORD PARAMETERS:
;        _EXTRA=e -> Passes extra keywords to routine HDF_SD_GETDATA.
;
; OUTPUTS:
;        DATA -> Array containing extracted data from the HDF file.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        Need to use a version of IDL w/ HDF routines installed.
;
; NOTES:
;        Scellooched from MOP02Viewer by Yottana Khunatorn (bmy, 7/17/01)
;        
; EXAMPLE:
;
;        ; Make sure HDF is supported on this platform
;        IF ( HDF_EXISTS() eq 0 ) then MESSAGE, 'HDF not supported!'
;
;        ; Open the HDF file and get the file ID # (FID)
;        FID = HDF_SD_START( 'fvdas_flk_01.ana.eta.20011027.hdf', /Read )
;        IF ( FID lt 0 ) then MESSAGE, 'Error opening file!'
;
;        ; Read the UWND field from disk
;        DATA = HDF_GETSD( fId, 'UWND' )
;
;        ; Close the file 
;        HDF_SD_END, FID
;
; MODIFICATION HISTORY:
;        bmy, 05 Nov 2001: VERSION 1.00
;        bmy, 23 Apr 2002: TOOLS VERSION 1.50
;                          - updated documentation
;
;-
; Copyright (C) 2001, 2002, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine hdf_getsd"
;-----------------------------------------------------------------------


function HDF_GetSD, fId, Name, _EXTRA=e
 
   ; Translate NAME to index number
   Ind = HDF_SD_NameToIndex( fId, Name )
 
   ; Make sure NAME is a valid field name
   if ( Ind[0] lt 0 ) then begin
      S = Name + ' not found in this file!'
      Message, S
   endif
 
   ; Get the data set ID
   sId = HDF_SD_Select( fId, Ind )
 
   ; Make sure data set ID is valid
   if ( sId lt 0 ) then begin
      S = sId + ' is an invalid SD ID for this file!' 
      Message, S  
   endif
 
   ; Read the data
   HDF_SD_GetData, sId, SData, _EXTRA=e
 
   ; Detach from the data set
   HDF_SD_EndAccess, sId      
 
   ; Return the data to the main program
   return, SData
 
end
