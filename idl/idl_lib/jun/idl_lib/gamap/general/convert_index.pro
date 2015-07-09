; $Id: convert_index.pro,v 1.1.1.1 2007/07/17 20:41:41 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CONVERT_INDEX
;
; PURPOSE:
;        Converts a 1-D array index (such as is returned from 
;        WHERE, UNIQ, etc) to the appropriate 1-D, 2-D, or 3-D
;        array indices
;
; CATEGORY:
;        General
;
; CALLING SEQUENCE:
;        RESULT = CONVERT_INDEX( Index, Dim )
;
; INPUTS:
;        INDEX -> The 1-D array index to be converted to 
;             multi-dimensional indices.  INDEX is returned
;             to the calling program unchanged.
; 
;        DIM -> A vector containing the dimensions of the array
;             for which multi-dimensional indices are required.
;
; KEYWORD PARAMETERS:
;        FORTRAN -> Interpret array indices as FORTRAN indices, i.e.
;             starting from 1 instead of 0. This applies to INPUT 
;             and OUTPUT indices!
;
; OUTPUTS:
;        RESULT -> Returns either a vector index or a vector of 
;             multi-dimensional array indices as the value of the 
;             function. If INDEX is a 1-dimensional parameter, the 
;             result will have n_elements(dim) dimensions. If INDEX 
;             is a multidimensional parameter, the result will be 
;             a scalar.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        Right now only works for 3-D arrays and smaller.  Will
;        eventually do the general case...
;
; EXAMPLES:
;        (1) 
;        PRINT, CONVERT_INDEX( [1,1], [2,2] )
;           3
;
;        (2)
;        PRINT, CONVERT_INDEX( [2,2], [2,2] )
;           % CONVERT_INDEX: Index[0] greater than Dim[0]
;           % CONVERT_INDEX: Index[1] greater than Dim[1]
;           6
;
;        (3)
;        PRINT, CONVERT_INDEX( [2,2], [2,2], /FORTRAN )
;           4       ; <<<-- shifted by 1 !
;
;        (4)
;        PRINT, CONVERT_INDEX( 72, [72,46,20] )
;           0  1  0
; 
;        (5)
;        PRINT, CONVERT_INDEX( 72, [72,46,20], /FORTRAN )
;           72           1           1
; 
; MODIFICATION HISTORY:
;        bmy, 07 Oct 1998: VERSION 1.00
;        mgs, 07 Oct 1998: VERSION 1.20
;               - made result etc LONG arrays
;               - allow sany dimensions now
;               - added reverse operation if index is multidimensional
;               - added FORTRAN keyword 
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
; or phs@io.harvard.edu with subject "IDL routine convert_index"
;-----------------------------------------------------------------------


function Convert_Index, Index, Dim, Fortran=Fortran
   
   ;==================
   ; Error checking
   ;==================
   if ( N_Elements( Index ) eq 0 OR N_Elements(Dim) eq 0) then begin
      Message, 'INDEX and DIM must be specified!', /Continue
      return, -1
   endif

   if ( N_Elements( Index ) gt 1 AND  $
        n_elements(Index) ne n_elements(Dim)) then begin
      Message, 'Dimensions of INDEX and DIM do not agree!', /Continue
      return, -1
   endif


   ;===========================================
   ; Simple case first: convert from array dims
   ; to vector dim
   ;===========================================

   if (N_Elements(Index) gt 1) then begin
      NewIndex = Index-keyword_set(Fortran)     ; make working copy

      ; check validity of indices and print warning
      for i=0,N_Elements(Dim)-1 do $
         if (NewIndex[i] ge Dim[i]) then Message,'Index['+strtrim(i,2)+ $
             '] greater than Dim['+strtrim(i,2)+']',/Cont

      ; compute vector index
      result = long(NewIndex[n_elements(Dim)-1])
      for i=N_elements(Dim)-2,0,-1 do result = result*Dim[i]+NewIndex[i]
      return,result+keyword_set(FORTRAN)
   endif


   ;===========================================
   ; Define output array
   ; Also save INDEX in a temporary variable
   ;===========================================
   Result = LonArr( N_Elements( Dim ) ) 
   MaxInd = LonArr( N_Elements( Dim ) )

   MaxInd[0] = Dim[0]
   for i=1,n_elements(Dim)-1 do MaxInd[i] = MaxInd[i-1]*Dim[i]
   MaxInd = [ 1L, MaxInd ]

   NewIndex = Index - keyword_set(FORTRAN)
   for i=n_elements(Dim)-1,0,-1 do begin
       Result[i] = NewIndex / MaxInd[i]    ; result is type long !
       NewIndex = NewIndex - MaxInd[i]*Result[i]
   endfor

   return,result+keyword_set(FORTRAN)


end
 
 
 
