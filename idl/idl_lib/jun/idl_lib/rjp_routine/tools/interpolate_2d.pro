function InterPolate_2D, Data, OldXMid, OldYMid, NewXMid, NewYMid, $
                         Double=Double
 
   ;====================================================================
   ; Error checking
   ;====================================================================
   if ( N_Params() ne 5 ) then begin
      Message,'Must supply DATA, OLDXMID, OLDYMID, NEWXMID, NEWYMID!' 
   endif
   
   ; Sizes of arrays
   SD  = Size( Data,    /Dim )
   SOX = Size( OldXMid, /Dim )  
   SOY = Size( OldYMid, /Dim )
   SNX = Size( NewXMid, /Dim )
   SNY = Size( NewYMid, /Dim )

   ; Check dimensions of arrays
   if ( N_Elements( SD  ) ne 2 ) then Message, 'DATA must be a 2-D array!'
   if ( N_Elements( SOX ) ne 1 ) then Message, 'OLDXMID must be a 1-D vector!'
   if ( N_Elements( SOY ) ne 1 ) then Message, 'OLDYMID must be a 1-D vector!'
   if ( N_Elements( SNX ) ne 1 ) then Message, 'NEWXMID must be a 1-D vector!'
   if ( N_Elements( SNY ) ne 1 ) then Message, 'NEWYMID must be a 1-D vector!'

   ; OLDXMID and DATA must conform
   if ( SD[0] ne SOX[0] ) $
      then Message, 'OLDXMID must match the 1st dimension of DATA!'
   
   ; OLDYMID and DATA must conform
   if ( SD[1] ne SOY[0] ) $
      then Message, 'OLDYMID must match the 2nd dimension of DATA!'
   
   ;====================================================================
   ; Define arrays
   ;====================================================================
   TmpArr = DblArr( SNX[0], SOY[0] )
   NewArr = DblArr( SNX[0], SNY[0] )

   ;====================================================================
   ; Interpolate
   ;====================================================================

   ; E-W direction
   for J = 0L, SOY[0] - 1L  do begin
      TmpArr[*, J] = InterPol( Data[*, J], OldXMid, NewXMid )
   endfor

   ; N-S direction
   for I = 0L, SNX[0] - 1L do begin
      NewArr[I, *] = Interpol( TmpArr[I, *], OldYMid, NewYMid )
   endfor

   ;====================================================================
   ; Cleanup and return
   ;====================================================================
   if ( not Keyword_Set( Double ) ) $
      then return, Float( NewArr )  $
      else return, NewArr
end
   
   
