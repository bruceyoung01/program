; $Id: hdf_getsdattr.pro,v 1.1.1.1 2003/10/22 18:09:38 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        HDF_GETSDATTR
;
; PURPOSE: 
;        Convenience routine to read attributes (global or variable-
;        associated) from Hierarchical Data Format (HDF) files.
;
; CATEGORY:
;        HDF Tools
;
; CALLING SEQUENCE:
;        DATA = HDF_GETSDATTR( ID, NAME [ , Keywords ] )
;
; INPUTS:
;        ID -> HDF File ID as returned by routine HDF_SD_START,
;             or scientific dataset ID, as returned by routine
;             HDF_SD_SELECT.
;
;        NAME -> Name of the attribute to be read from the HDF file.
;
; KEYWORD PARAMETERS:
;        COUNT -> Returns the total number of values in the 
;             specified attribute to the calling program.
; 
;        HDF_TYPE -> Returns the HDF type of the attribute to the
;             calling program.  HDF types are returned as a scalar
;             string.  Possible returned values are DFNT_NONE, 
;             DFNT_CHAR, DFNT_FLOAT32, DFNT_FLOAT64, DFNT_INT8, 
;             DFNT_INT16, DFNT_INT32, DFNT_UINT8, DFNT_UINT16, and 
;             DFNT_UINT32.
;
;        TYPE -> Returns the IDL type pf the attribute to the calling 
;             program.  The type of the attribute is returned as a
;             scalar string. Possible returned values are BYTE, INT, 
;             LONG, FLOAT, DOUBLE, STRING, or UNKNOWN.
;
; OUTPUTS:
;        DATA -> Array containing attribute data from the HDF file.
;
; SUBROUTINES:
;        IDL HDF routines used:
;        ==========================
;        HDF_SD_AttrInfo  
;        HDF_SD_AttrFind (function)
;
; REQUIREMENTS:
;        Need to use a version of IDL w/ HDF routines installed.
;
; NOTES:
;        None
;        
; EXAMPLE:
;
;        ; Make sure HDF is supported on this platform
;        IF ( NCDF_EXISTS() eq 0 ) then MESSAGE, 'HDF not supported!'
;
;        ; Open the HDF file and get the file ID # (FID)
;        FID = HDF_SD_START( 'fvdas_flk_01.ana.eta.20011027.hdf', /READ )
;        IF ( FID lt 0 ) then MESSAGE, 'Error opening file!'
;
;        ; Read the Ak, Bk, and PTOP attributes from the HDF file
;        ; These are GLOBAL attributes associated w/ the file
;        AK   = HDF_GETSDATTR( FID, 'ak'   )
;        BK   = HDF_GETSDATTR( FID, 'bk'   )
;        PTOP = HDF_GETSDATTR( FID, 'ptop' )
;
;        ; Close the HDF file 
;        HDF_SD_END, FID
;
; MODIFICATION HISTORY:
;        bmy, 30 Apr 2002: TOOLS VERSION 1.50
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
; with subject "IDL routine hdf_getsdattr"
;-----------------------------------------------------------------------


function HDF_GetSdAttr, Id, Name, Count=Count, HDF_Type=HDF_Type, Type=Type   
   
   ; Keywords
   if ( N_Elements( sId  ) ne 1 ) then Message, 'SID not passed!'
   if ( N_Elements( Name ) ne 1 ) then Message, 'NAME not passed!'

   ; Find the index of the given attribute
   Ind = HDF_SD_AttrFind( Id, Name )

   ; Error check
   if ( Ind[0] lt 0 ) then begin
      S = 'Could not find attribute ' + StrTrim( Name, 2 ) 
      Message, S
   endif
      
   ; Get information about the attribute
   HDF_SD_AttrInfo, Id, Ind, $
      Count=Count, Data=Data, HDF_Type=HDF_Type, Type=Type, _EXTRA=e

   ; Return DATA to the calling program
   return, Data
   
end
