; $Id: hdf_getvd.pro,v 1.1.1.1 2007/07/17 20:41:39 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        HDF_GETVD
;
; PURPOSE: 
;        Convenience routine to read VDATA variables 
;        from Hierarchical Data Format (HDF) files
;
; CATEGORY:
;        File & I/O, Scientific Data Formats
;
; CALLING SEQUENCE:
;        VDATA = HDF_GETVD( FID, NAME [, _EXTRA=e ] )
;
; INPUTS:
;        FID -> HDF File ID, as returned by routine HDF_OPEN.
;
;        NAME -> Name of the VDATA variable that you 
;             want to extract from the file.  
;
; KEYWORD PARAMETERS:
;        _EXTRA=e -> Passes extra keywords to routine HDF_VD_READ.
;
; OUTPUTS:
;        VDATA -> Array containing extracted data from the HDF file.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        Need to use a version of IDL w/ HDF routines installed.
;
; NOTES:
;        Taken from MOP02Viewer by Yottana Khunatorn (bmy, 7/17/01)
;        
; EXAMPLE:
;        FID = HDF_OPEN( 'fvdas_flk_01.ana.eta.20011027.hdf', /Read )
;        IF ( FID lt 0 ) then Message, 'Error opening file!'
;        PTOP = HDF_GETVD( fId, 'PTOP' ) 
;        HDF_CLOSE, FID
;
;             ; Opens an HDF-format file and gets the file ID.  Then
;             ; call HDF_GETSD to return the PTOP variable from the 
;             ; file.  Then close the file and quit.
;
; MODIFICATION HISTORY:
;        bmy, 05 Nov 2001: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2001-2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine hdf_getvd";
;-----------------------------------------------------------------------

function HDF_GetVD, fId, Name, Verbose=Verbose, _EXTRA=e
 
   ;====================================================================
   ; Function GetVData reads VDATA fields from an HDF-EOS file
   ; (such as the ones containing Time, Longitude, Latitude)
   ;
   ; Scellooched from MOP02Viewer by Yottana Khunatorn (bmy, 7/17/01)
   ;====================================================================
   
   ; Get reference for VDATA field
   vRef = HDF_VD_Find( fId, StrTrim( Name, 2 ) )
 
   ; Make sure Time is a valid field name
   if ( vRef lt 0 ) then begin
      S = Name + ' not found!'
      Message, S
   endif
 
   ; Get index for VDATA field
   vId = HDF_VD_Attach( fId, vRef )
 
   ; Make sure Time is a valid field name
   if ( vId lt 0 ) then begin
      S = Name + ' not found!'
      Message, S
   endif
 
   ; Read VDATA field
   nRead = HDF_VD_Read( vId, vData, _EXTRA=e )       
   
   ; Error check
   if ( nRead eq 0 ) then begin
      S = 'Could not read VDATA field: ' + StrTrim( Name, 2 )
      Message, S
   endif
 
   ; Detach from VDATA field
   HDF_VD_Detach, vId
 
   ; Return to calling program
   return, vData
 
end
