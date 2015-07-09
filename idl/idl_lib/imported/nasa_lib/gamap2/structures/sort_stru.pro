; $Id: sort_stru.pro,v 1.2 2007/08/03 18:59:51 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        SORT_STRU
;
; PURPOSE:
;        Returns an sort index array a structure data field.
;
; CATEGORY:
;        Structures
;
; CALLING SEQUENCE:
;        INDEX = SORT_STRU( STRU, SORT_TAG )
;
; INPUTS:
;        STRU -> The structure containing the data to be sorted.
;
;        SORT_TAG -> A string containing the name of the structure
;             tag for which to compute the sort index array.
;
; KEYWORD PARAMETERS:
;        /REVERSE_SORT -> Set this switch to return an sort 
;             index array in reverse order.
;
; OUTPUTS:
;        None
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
; EXAMPLES:
;        (1)
;        STRU = { DATA : [5,3,2,1,4] }
;        IND  = SORT_STRU( STRU, 'DATA' )
;        PRINT, STRU.DATA[IND]
;           1   2   3   4   5
;    
;             ; Returns an sort index array for the DATA
;             ; tag of the structure STRU.  STRU.DATA[IND]
;             ; will be in ascending order.
;
;        (2)
;        STRU = { DATA : [5,3,2,1,4] }
;        IND  = SORT_STRU( STRU, 'DATA', /REVERSE_SORT  );         
;        PRINT, STRU.DATA[IND]
;           5   4   3   2   1
;    
;             ; Returns an sort index array for the DATA
;             ; tag of the structure STRU.  STRU.DATA[IND]
;             ; will be in descending order.
;
; MODIFICATION HISTORY:
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2007,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine sort_stru"
;-----------------------------------------------------------------------


function Sort_Stru, Stru, Sort_Tag, Reverse_Sort=Reverse_Sort, _EXTRA=e
   
   ; Get a list of tag names in STRU
   Names  = Tag_Names( Stru )

   ; Find the location of SORT_TAG in the STRU
   TagInd = Where( Names eq StrUpCase( Sort_Tag ) )
 
   ; Error check
   if ( TagInd[0] lt 0 ) then begin
      S = 'Could not find ' + Sort_Tag + ' in structure!'
      Message, S, /Cont
      return, -1
   endif
 
   ; Compute the sort index array (i.e. output of 
   ; the SORT command) for the given structure tag
   Ind = Sort( Stru.(TagInd), _EXTRA=e )
      
   ; Reverse the sort index array if necessary
   if ( Keyword_Set( Reverse_Sort ) ) then Ind = Reverse( Temporary( Ind ) )

   ; Return index array to calling program
   return, Ind
end
