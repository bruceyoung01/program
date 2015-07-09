;+
; NAME:
;        STRREPL (function)
;
; PURPOSE:
;        Replace all occurences of one character in a string
;        with another character. The character to be replaced
;        can either be given as string of length 1 or as an
;        index array containing the character positions
;        (see strwhere). This function also works for string arrays.
;
; CATEGORY:
;        String Utilities
;
; CALLING SEQUENCE:
;        Result = STRREPL(str, fromchar, tochar [,/IGNORECASE])
;
; INPUTS:
;        STR      -> the string to be changed
;
;        FROMCHAR -> either: a string of length 1 (the character to 
;                        be replaced)
;                    or: an index array with the character positions
;
;        TOCHAR   -> replacement character
;
; KEYWORD PARAMETERS:
;        IGNORECASE -> if set, fromchar will be treated case-insensitive
;              (only if fromchar is a character)
;        FOLD_CASE -> same thing but following IDL naming (e.g. StrMatch)
;
; OUTPUTS:
;        A string of same length as the input string
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;        Uses SIZE(/TYPE) available since IDL 5.2
;
; EXAMPLES:
;        ; Convert a Unix filename to Windows
;        ufile = '/usr/local/idl/lib/test.pro'
;        wfile = 'c:' + strrepl(ufile,'/','\')
;        print,wfile
;        ; prints "c:\usr\local\idl\lib\test.pro"
;
;        ; Use with index (uses strwhere function)
;        a = 'abcdabcdabcd'
;        index = [ strwhere(a,'a'), strwhere(a,'b') ] > 0
;        print,strrepl(a,index,'#')
;        ; prints  "##cd##cd##cd"
;
; MODIFICATION HISTORY:
;        mgs, 02 Jun 1998: VERSION 1.00
;        mgs, 24 Feb 2000: - rewritten
;                          - now accepts character argument
;                          - added IGNORECASE keyword
;        mgs, 26 Aug 2000: - changed copyright to open source
;                          - added FOLD_CASE keyword
;
;-
;
;###########################################################################
;
; LICENSE
;
; This software is OSI Certified Open Source Software.
; OSI Certified is a certification mark of the Open Source Initiative.
;
; Copyright © 2000 Martin Schultz
;
; This software is provided "as-is", without any express or
; implied warranty. In no event will the authors be held liable
; for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software for any
; purpose, including commercial applications, and to alter it and
; redistribute it freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must
;    not claim you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation
;    would be appreciated, but is not required.
;
; 2. Altered source versions must be plainly marked as such, and must
;    not be misrepresented as being the original software.
;
; 3. This notice may not be removed or altered from any source distribution.
;
; For more information on Open Source Software, visit the Open Source
; web site: http://www.opensource.org.
;
;###########################################################################


function strrepl,str,fromchar,tochar,   $
                 IGNORECASE=ignorecase, FOLD_CASE=fold_case
 
ON_ERROR,2    ; return to caller

     ; argument testing
     if n_params() lt 3 then begin
        message,'Usage: strrepl,str,fromchar,tochar[,/IGNORECASE])'
     endif

     ; make working copy of string and convert to a byte array
     bstr = byte(string(str))
      
     ; fromchar is given as character
     if size(fromchar,/TYPE) eq 7 then begin
        ; ignore case?
        if keyword_set(ignorecase) OR keyword_set(fold_case) then begin
           ; call strrepl recursively w/o the IGNORE_CASE keyword
           res1 = strrepl(str,strupcase(fromchar),tochar)
           res2 = strrepl(res1,strlowcase(fromchar),tochar)
           return,res2
        endif else begin
           ; find all character occurences
           ; must be a single character - use the first
           bfc = (byte(fromchar))[0]
           ; go and search
           w = where(bstr eq bfc,count)
           ; if not found, return original string
           if count eq 0 then return,str
        endelse
     endif else begin
     ; fromchar is already an index array
        w = long(fromchar)
     endelse

     ; make sure index is in range
     test = where(w lt 0 OR w ge n_elements(bstr),tcount)
     if tcount gt 0 then begin
        message,'WARNING: Index out of range!',/Continue
        ; restrict to valid index values
        test = where(w ge 0 AND w lt n_elements(bstr),tcount)
        if tcount gt 0 then begin
           w = w[test]
        endif else begin
        ; no valid indices: return original string
           return,str
        endelse
     endif

     ; convert tochar to a byte value
     btc  = (byte(tochar))[0]
 
     ; replace 
     bstr[w] = btc
 
     ; return result as string
     return,string(bstr)
 
end
 
