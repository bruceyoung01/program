; $Id: expand_category.pro,v 1.1.1.1 2007/07/17 20:41:47 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        EXPAND_CATEGORY  (function)
;
; PURPOSE:
;        Replace wildcards in a multilevel diagnostic category
;        and return a string array with one entry for each 
;        level.
;
; CATEGORY:
;        GAMAP Internals
;
; CALLING SEQUENCE:
;        xcatgeory = EXPAND_CATEGORY(category)
;
; INPUTS:
;        CATGEORY -> The original category name containing one
;            wildcard character (see CTM_DIAGINFO). If category 
;            does not contain a wildcard character, the category
;            will be returned unchanged.
;
; KEYWORD PARAMETERS:
;        RANGE -> A level index or range of level indices (2-elements)
;            to be returned. Default is to return the maximum
;            possible range (currently 1..24).
;
;        WILDCHARD -> a character value that is searched for as
;            wildchard. Default is '$' which is used in CTM_DIAGINFO
;            to denote a varying level index.
;
;        /NO_DELETE -> if set, will return category with wildcard as
;            first entry in result list. Default is to delete the 
;            wildcard string. 
;
; OUTPUTS:
;        A string array with category names.
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
;        PRINT, EXPAND_CATEGORY('IJ-AVG-$')
;
;             ; prints IJ-AVG-1 IJ-AVG-2 IJ-AVG-3 ... 
;             ;        ... IJ-AVG-A IJ-AVG-B ...
;
;        print, EXPAND_CATEGORY( 'IJ-AVG-$', range=5 )
;
;             ; prints IJ-AVG-5 
;
; MODIFICATION HISTORY:
;        mgs, 19 Aug 1998: VERSION 1.00
;        mgs, 26 Oct 1998: added no_delete keyword
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - added extra letters for grids w/
;                            more than about 30 layers
;
;-
; Copyright (C) 1998-2007, Martin Schultz,
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine expand_category"
;-----------------------------------------------------------------------


function expand_category,incat,range=range,wildcard=wildcard, $
              no_delete=no_delete
 
 
    ; set '$' as default wildcard
    if (n_elements(wildcard) eq 0) then wildcard = '$'
 
    ; check if category name contains wildcard
    p = strpos(incat,'$')
 
    ; if not: simply return category name as is
    if (p lt 0) then return,incat
 
    ; otherwise create string array with '$' replaced by
    ; level identifiers
 
    levelchar = [ '1', '2', '3', '4', '5', '6', '7', '8', '9', $
                  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', $
                  'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', $
                  'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', $
                  'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', $
                  'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', $
                  't', 'u', 'v', 'w', 'x', 'y', 'z' ]

    MAXRANGE = n_elements(levelchar)
    if (n_elements(range) eq 0) then range = [ 1, MAXRANGE ]
    if (n_elements(range) eq 1) then range = [ range, range ]
   
    range = ( range > 1 ) < MAXRANGE 
 
    result = strmid( incat, 0, p )              + $
             levelchar[ range[0]-1:range[1]-1 ] + $
             strmid( incat, p+1, 255 )

    if (keyword_set(no_delete)) then result = [ incat, result ]

    return,result
 
end
 
 
