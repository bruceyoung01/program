; $Id: create3dfstru.pro,v 1.1.1.1 2007/07/17 20:41:46 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CREATE3DFSTRU
;
; PURPOSE:
;        Creates an empty GAMAP fileinfo structure or an array
;        of such structures. These are used to hold information
;        about CTM data files.
;
; CATEGORY:
;        GAMAP Internals, Structures
;
; CALLING SEQUENCE:
;        FILEINFO = CREATE3DHSTRU( [Elements] )
;
; INPUTS:
;        ELEMENTS -> Number of individual structures to
;             be contained in the array of structures. Default
;             is 1, i.e. return a single structure.
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        A fileinfo structure or an array of fileinfo structures.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        See comments in code below for structure field descriptions.
;
; EXAMPLES:
;        FILEINFO = CREATE3DFSTRU()
;            ; returns a single structure which will hold
;            ; info about CTM punch file data.
;
;        FILEINFO = CREATE3DFSTRU( 20 )
;            ; returns an 20 element array of structures 
;            ; which will hold info about 20 records from a 
;            ; CTM data file
;
; MODIFICATION HISTORY:
;        mgs, 14 Aug 1998: VERSION 1.00
;        bmy, 18 May 2007: GAMAP VERSION 2.06
;                          - added standard doc header
;                          - updated comments, cosmetic changes
; MODIFICATION HISTORY:
;        bmy, 19 Feb 1999: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1999-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine create3dfstru"
;-----------------------------------------------------------------------

function Create3dFstru, Elements

   ; External functions
   FORWARD_FUNCTION CTM_Type

   ; Create a template FILEINFO structure
   Stru = { f3dstru,                         $  ; name of structure
            FileName  : '',                  $  ; name of file
            Ilun      : 0L,                  $  ; logical file unit
            FileType  : 0,                   $  ; see "ctm_open_file.pro" 
            Status    : 1,                   $  ; indicates error condition
            TopTitle  : '',                  $  ; first header line
            ModelInfo : CTM_Type( 'DUMMY' ), $  ; model type information
            GridInfo  : Ptr_New()            }  ; (null) ptr to gridinfo stru

   ; If ELEMENTS isn't passed, use default value of 1
   if ( N_Elements( Elements ) eq 0 ) then Elements = 1

   ; If ELEMENTS=1 then return the template structure
   if ( Elements eq 1 ) then return, Stru

   ; Otherwise replicate the structure and return
   StruArr = Replicate( Stru, Elements )
   return, StruArr

end
 
