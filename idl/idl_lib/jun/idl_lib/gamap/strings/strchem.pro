; $Id: strchem.pro,v 1.1.1.1 2007/07/17 20:41:48 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        STRCHEM (function)
;
; PURPOSE:
;        Superscripts or subscripts numbers and special
;        characters ('x', 'y') found in strings containing 
;        names of chemical species.
;
; CATEGORY:
;        Strings
;
; CALLING SEQUENCE:
;        RESULT = STRCHEM( STR [,keywords] )
;
; INPUTS:
;        STR -> The input string containing the name of the
;             chemical species (e.g. 'NOx', 'H2O', CxO2, etc, ) 
;
; KEYWORD PARAMETERS:
;        /SUB -> Will cause numbers and special characters to 
;             be subscripted.  This is the default.
;
;        /SUPER -> Will cause numbers and special characters to
;             be superscripted.
;
;        SPECIALCHARS -> a string with characters that shall be sub- 
;             or superscripted. Defaults are '0123456789xyXY' for
;              /SUB and '+-0123456789' for /SUPER
;
;        PROTECT -> internal keyword used to protect certain characters
;             from being super or subscripted. May be useful to
;             circumvent troubles. See example below. 
;
;        /TRIM -> perform a strtrim( ,2) on the result
;
; OUTPUTS:
;        RESULT -> String with formatting characters included
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        (1)
;        PRINT, STRCHEM( 'C2H5O2 [pptv]' )
;          C!l2!nH!l5!nO!l2!n [pptv]"
;
;        (2)
;        PRINT, STRCHEM( STRCHEM('NH4+',/sub), /SUPER, SPECIAL='+-' )
;          NH!l4!n!u+!n.
;
;        (3)
;        S0      = '(H2O2)2'                   ; supposed to be H2O2 squared
;        PROTECT = STRLEN( s0 )-1              ; protect last character
;        S1      = STRCHEM(S0,PROTECT=PROTECT)
;        S2      = STRCHEM(S1,/SUPER,PROTECT=PROTECT)
;        PRINT, S1, '->', S2
;          (H!l2!nO!l2!n)2->(H!l2!nO!l2!n)!u2!n
;
;             ; without protect the "square" would have been subscripted
;
; MODIFICATION HISTORY:
;        bmy, 01 Jun 1998: VERSION 1.00
;        mgs, 02 Jun 1998: VERSION 1.10 - rewritten
;        mgs, 11 Jun 1998: - removed IS_ION keyword
;                          - changed default specialchars for SUPER
;        mgs, 22 Sep 1998: - added TRIM keyword
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Updated comments, cosmetic changes
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
; or phs@io.as.harvard.edu with subject "IDL routine strchem"
;-----------------------------------------------------------------------


Function StrChem, Str,                                        $
                  Super=Super,               Sub=Sub,         $
                  SpecialChars=SpecialChars, Protect=Protect, $
                  Trim=Trim
 
   ; Error checking
   on_error, 2
 
   ; Return empty string if no string is passed
   if ( n_elements( Str ) eq 0 ) then return, ''

   ; temporary copy of Str 
   tmp = Str


   ; Keyword default settings 
   Sub   = ( keyword_set( Sub   ) )
   Super = ( keyword_set( Super ) ) * (1 - Sub)

   ; set up string with characters to sub(super)script
   if (n_elements(specialchars) eq 0) then begin
     if (sub)                                $
        then specialchars = '0123456789xyXY' $
        else specialchars = '+-0123456789' 
   endif

   ; convert to byte array
   BS = byte(specialchars)


   ; here are the formatting characters
   BE = (byte('!'))[0]
   BA = (byte('l'))[0]
   if (Super) then BA = (byte('u'))[0]
   BN = (byte('n'))[0]


   ; convert string argument to byte array and loop through,
   ; inserting the formatting characters at each occurence of
   ; a specialchar
   ; (obsolete Trick: loop backwards in order to simplify ionic case)
   BStr = byte(tmp)
   Res = 0B

   ; create local protect array and expand protect if passed
   LProtect = intarr(n_elements(BStr))
   if (n_elements(Protect) gt 0) then $
      LProtect[Protect] = 1

   RProtect = 0   ; resulting Protect array
   
   done = 0
   i = n_elements(BStr)-1

   while (not done) do begin
      ind = where(BS eq BStr[i])
      if (ind(0) ge 0 AND not LProtect[i]) then begin
         Res = [ Res, BN, BE, BStr[i], BA, BE ] 
         RProtect = [ RProtect, 1, 1, 1, 1, 1 ]
      endif else begin
         Res = [ Res, BStr[i] ]
         RProtect = [ RProtect, 0 ]
      endelse

      i = i - 1

      if (i lt 0) then Done = 1
   endwhile

   ; eliminate first (zero) character and revert "string"
   Res = Reverse(Res[1:*])

   ; same with new Protect array which will be returned
   RProtect = Reverse(RProtect[1:*])
   Protect = where(RProtect gt 0)

   ; convert byte array back to string and return
   result = string(Res)
   if (keyword_set(TRIM)) then result = strtrim(result,2)
   return,result
 
end
