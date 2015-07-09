; $Id: extract_comments.pro,v 1.1.1.1 2007/07/17 20:41:39 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        EXTRACT_COMMENTS
;
; PURPOSE:
;        Split a string returned from READDATA.PRO into 
;        items of a string array.
;
; CATEGORY:
;        General
;
; CALLING SEQUENCE:
;        RESULT = EXTRACT_COMMENTS( COMMENTS, INDEX, DELIM=' ' ) 
;
; INPUTS:
;        COMMENTS -> String array of comment lines returned from
;            readdata.pro
;
;        INDEX -> line number of comments to be analyzed
;
; KEYWORD PARAMETERS:
;        DELIM -> delimiter character between items. Default: 1 blank.
;
; OUTPUTS:
;        RESULT -> A string array containing the single "words" 
;             of 1 comment line.
;
; SUBROUTINES:
;        External Subroutines Required:
;        ===============================
;        STRBREAK (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        UNITS = EXTRACT_COMMENTS( comments, 2, delim=' ' )
;
; MODIFICATION HISTORY:
;        mgs, 10 Nov 1997: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Now use version-independent STRBREAK
;                            routine instead of older STR_SEP routine
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
; or phs@io.harvard.edu with subject "IDL routine extract_comments"
;-----------------------------------------------------------------------


function extract_comments, comments, index, delim=delim
 
     ; extract header information out of comments array returned 
     ; from readdata for later use
 
   ; External functionls
   FORWARD_FUNCTION StrBreak
     
   ON_ERROR,2
     
   if ( N_Elements( Delim ) le 0 ) then delim = ' '
 
   ; compress string so that only one blank is left between items
   Char = StrCompress( StrTrim( Comments( Index ), 2 ) )

   ; if delimiter is not a blank, remove all blanks
   if ( Delim ne ' ') then char = StrCompress( Char, /Remove_all )
  
   ; return array of tokens
   ;-------------------------------------------------------
   ; Prior to 7/16/07:
   ; Now use version-independent STRBREAK (bmy, 7/16/07)
   ;return, STR_SEP(char,delim)
   ;-------------------------------------------------------
   return, StrBreak( Char, Delim )

end
 
 
