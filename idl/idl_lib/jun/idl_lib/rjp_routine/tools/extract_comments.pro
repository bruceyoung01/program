; $Id: extract_comments.pro,v 1.1.1.1 2003/10/22 18:09:38 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        EXTRACT_COMMENTS
;
; PURPOSE:
;        split a string returned from READDATA.PRO into 
;        items of a string array.
;
; CATEGORY:
;        general data handling
;
; CALLING SEQUENCE:
;        result=EXTRACT_COMMENTS(comments,index,delim=' ')
;
; INPUTS:
;        COMMENTS --> string array of comment lines returned from
;            readdata.pro
;
;        INDEX --> line number of comments to be analyzed
;
; KEYWORD PARAMETERS:
;        DELIM --> delimiter character between items. Default: 1 blank.
;
; OUTPUTS:
;        A string array containing the single "words" of 1 comment line.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;
; EXAMPLE:
;        units=EXTRACT_COMMENTS(comments,2,delim=' ')
;
; MODIFICATION HISTORY:
;        mgs, 10 Nov 1997: VERSION 1.00
;
;-
; Copyright (C) 1997, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine extract_comments"
;-------------------------------------------------------------


function extract_comments,comments,index,delim=delim
 
; extract header information out of comments array returned from readdata
; for later use
 
     ON_ERROR,2
 
     if (n_elements(delim) le 0) then delim = ' '
 
; compress string so that only one blank is left between items
     char = STRCOMPRESS(STRTRIM(comments(index),2))
; if delimiter is not a blank, remove all blanks
     if(delim ne ' ') then char = STRCOMPRESS(char,/remove_all)
 
; return array of tokens
     return,STR_SEP(char,delim)
 
end
 
 
