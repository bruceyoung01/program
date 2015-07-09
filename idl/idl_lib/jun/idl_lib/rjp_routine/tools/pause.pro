; Pauses program execution
pro Pause, Msg

   ; Print message if passed
   if ( N_Elements( Msg ) gt 0 ) then begin
      Message, Msg, /Info
   endif

   ; Halt with a READ statement
   Str = ''
   Read, Str, Prompt='% Hit RETURN to continue...'

   ; Quit
   return
end
