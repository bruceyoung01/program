; $Id: create3dhstru.pro,v 1.1.1.1 2007/07/17 20:41:48 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CREATE3DHSTRU
;
; PURPOSE:
;        Creates an empty GAMAP datainfo structure or an array
;        of such structures. These are used to hold information
;        about individual data blocks from CTM data files.
;
; CATEGORY:
;        GAMAP Internals, Structures
;
; CALLING SEQUENCE:
;        DATAINFO = CREATE3DHSTRU( [Elements] )
;
; INPUTS:
;        ELEMENTS -> Number of individual structures to be contained 
;             in the array of structures. Default is 1, (i.e. return
;             a single structure).
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        A datainfo structure or an array of datainfo structures.
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
;        DATAINFO = CREATE3DHSTRU()
;            ; returns a single structure which will hold
;            ; info about CTM punch file data.
;
;        DATAINFO = CREATE3DHSTRU( 20 )
;            ; returns an 20 element array of structures 
;            ; which will hold info about 20 records from a 
;            ; CTM data file
;
; MODIFICATION HISTORY:
;        mgs, 14 Aug 1998: VERSION 1.00
;        mgs, 10 Nov 1998: - changed default filepos to -1L and scale to 1
;        bmy, 08 Feb 1999: VERSION 1.10
;                          - changed TAU0, TAU1 from longword to double
;                          - added OFFSET field for I0, J0, L0
;        bmy, 17 Feb 1999: VERSION 1.20
;                          - changed OFFSET field to FIRST since we
;                            are storing the I, J, L indices of the 
;                            first 
;        mgs, 16 Mar 1999: - cosmetic changes
;        bmy, 03 Jan 2000: VERSION 1.44
;                          - updated comments
;        bmy, 26 Apr 2000: VERSION 1.45
;                          - TRACER now carries a longword variable
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1998-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine create3dhstru"
;-----------------------------------------------------------------------


function Create3dHstru,elements
   
   ; Create template DATAINFO structure
   Stru = { h3dstru,                  $  ; name of structure
            Ilun       : 0L,          $  ; logical file unit
            FilePos    : -1L,         $  ; position of data in file ilun
            Category   : '',          $  ; diag name, e.g. 'NOX_SRCE',
                                         ;  or description
            Tracer     : 0L,          $  ; tracer number ("real" species!)
            TracerName : '',          $  ; tracer name for output purposes
            Tau0       : 0.D,         $  ; beginning of time step
            Tau1       : 0.D,         $  ; end of time step
            Scale      : 1.0,         $  ; primary scaling factor
            Unit       : '',          $  ; physical unit of data
            Format     : '',          $  ; data format in punch file
            Status     : 0,           $  ; status of data
            Dim        : [ 0,0,0,0 ], $  ; dimension of data array (I,J,L,time)
            First      : [ 0,0,0 ],   $  ; First location of I, J, L
            Data       : Ptr_New() }     ; (null) pointer will hold data
 
            
   ; If ELEMENTS isn't passed, use default value of 1
   if ( N_Elements( Elements ) eq 0 ) then Elements = 1
 
   ; If ELEMENTS=1 then return the template structure
   if ( Elements eq 1 ) then return, Stru
 
   ; Otherwise, replicate the structure and return
   StruArr = Replicate( Stru, Elements )
   return, StruArr
 
end
 
