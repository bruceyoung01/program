function Sort_Stru, Stru, Sort_Tag
   
   Fields = ['ILUN', 'TAU0', 'CATEGORY', 'TRACER', 'TRACERNAME' ]

   Names  = Tag_Names( Stru )
   TagInd = Where( Names eq StrUpCase( Sort_Tag ) )

   if ( TagInd[0] lt 0 ) then begin
      S = 'Could not find ' + Sort_Tag + ' in structure!'
      Message, S, /Cont
      return, -1
   endif

   Ind = Sort( Stru.(TagInd) )
      
   return, Ind
end
