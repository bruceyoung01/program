; $Id: create3dhstru.pro,v 1.1.1.1 2003/10/22 18:06:02 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        CREATE3DHSTRU
;
; PURPOSE:
;        Creates an empty GAMAP datainfo structure or an array
;        of such structures. These are used to hold information
;        about individual data blocks from CTM punch files.
;
; CATEGORY:
;        GAMAP routines
;
; CALLING SEQUENCE:
;        newdatainfo = CREATE3DHSTRU( [n_elements] )
;
; INPUTS:
;        N_ELEMENTS -> Number of individual structures to
;             be contained in the array of structures. Default
;             is 1, i.e. return a single structure.
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
;        DataInfo = CREATE3DHSTRU()
;            ; returns a single structure which will hold
;            ; info about CTM punch file data.
;
;        DataInfo = CREATE3DHSTRU( 20 )
;            ; returns an 20 element array of structures 
;            ; which will hold info about 20 records from a 
;            ; CTM punch file
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
;
;-
; Copyright (C) 1998, 1999, Martin Schultz and Bob Yantosca, 
; Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; or bmy@io.harvard.edu with subject "IDL routine create3dhstru"
;-------------------------------------------------------------


function create3dhstru,elements
   
   stru = { h3dstru,                  $  ; name of structure
            ilun       : 0L,          $  ; logical file unit
            filepos    : -1L,         $  ; position of data in file ilun
            category   : '',          $  ; diag name, e.g. 'NOX_SRCE',
                                         ;  or description
            tracer     : 0L,          $  ; tracer number ("real" species!)
            tracername : '',          $  ; tracer name for output purposes
            tau0       : 0.D,         $  ; beginning of time step
            tau1       : 0.D,         $  ; end of time step
            scale      : 1.0,         $  ; primary scaling factor
            unit       : '',          $  ; physical unit of data
            format     : '',          $  ; data format in punch file
            status     : 0,           $  ; status of data
            dim        : [ 0,0,0,0 ], $  ; dimension of data array (I,J,L,time)
            first      : [ 0,0,0 ],   $  ; First location of I, J, L
            data       : ptr_new() }     ; (null) pointer will hold data
 
 
   ; if elements not provided or eq 1, return the sample, else replicate
   if (n_elements(elements) eq 0) then elements = 1
 
   if (elements eq 1) then return,stru
 
   struarr = replicate(stru,elements)
   return,struarr
 
end
 
