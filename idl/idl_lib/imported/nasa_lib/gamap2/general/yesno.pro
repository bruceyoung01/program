; $Id: yesno.pro,v 1.1.1.1 2007/07/17 20:41:40 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        YESNO
;
; PURPOSE:
;        Query user for decisions with only two possible answers.
;
; CATEGORY:
;        General
;
; CALLING SEQUENCE:
;        ANSWER = YESNO( QUESTION [,DEFAULT=DEFAULT ,/STRING ] )
;
; INPUTS:
;        QUESTION -> A string containing the query. The following
;            will automatically be added to QUESTION: ' (Y/N) [x] : '
;            where x is replaced by the default selection.
;
; KEYWORD PARAMETERS:
;        DEFAULT -> either 0 (for 'NO') or 1 (for 'YES'). Default is 0.
;
;        /QUIT_OPTION -> if set, the user can quit with 'Q'. This
;            option is appended to the (Y/N) string. YesNo returns
;            -1 if quit was selected.
;
;        /STRING -> set this keyword to return a 'Y' or 'N' instead
;            of the numerical values 0 or 1.
;
; OUTPUTS:
;        ANSWER -> An integer 0 or 1 that can be used in boolean 
;            expressions, or a 1 character string if /STRING is set. 
;            -1 is returned if /QUIT was allowed and used.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        '0' or '1' are also accepted as input. Everything but 
;        'y', 'Y', '1' is treated as 'N'. 'Q' or 'C' can both
;        be used to quit.
;
; EXAMPLES:
;        (1)
;        IF ( YESNO( 'Shall we meet today?', DEFAULT=1) ) $
;           THEN GOTO, MEETING
;
;        (2)
;        ANS = YESNO( 'Do you really want to quit?' )
;        if ( ans ) then return
;
;        (3)
;        ANS = YESNO( 'Save data ?', /QUIT, default=1 )
;        IF ( ANS LT 0 ) THEN RETURN
;
; MODIFICATION HISTORY:
;        mgs, 22 Jan 1999: VERSION 1.00
;        mgs, 23 Mar 1999: - added /QUIT option
;                          - bug fix: '0' was recognized as 'Y'
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
; or phs@io.harvard.edu with subject "IDL routine yesno"
;-----------------------------------------------------------------------


function yesno,question,default=default,string=return_string, $
          quit_option=quit_option
 
    if (n_elements(question) eq 0) then question = 'Question '
 
    if (n_elements(default) eq 0) then default = 0  ; No
    default = fix( (default > 0) < 1 )
    if (default) then DefStr = 'Y' else DefStr = 'N'

    quit_option = keyword_set(quit_option)
    if (quit_option) then $ 
       Question = Question + ' (Y/N/Q) [' + DefStr + '] : '   $
    else $
       Question = Question + ' (Y/N) [' + DefStr + '] : '   
    
 
    LStr = ''
    read,LStr,prompt=Question
    if (LStr eq '') then LStr = DefStr
 
 
    FirstChar = strupcase(strmid(strtrim(LStr,2),0,1))

    result = (FirstChar eq 'Y' OR FirstChar eq '1')
    ; defaults to 0 (='No')
 
    if (quit_option) then begin
       if (Firstchar eq 'Q' OR FirstChar eq 'C') then result = -1
    endif

    ; override result with character if so selected
    if (keyword_set(return_string)) then begin
       if (result eq -1) then result = 'Q' $
       else if (result eq 0) then result = 'N' $
       else result = 'Y'
    endif


    return,result
end
