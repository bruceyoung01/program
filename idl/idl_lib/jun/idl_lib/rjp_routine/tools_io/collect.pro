 function collect, dir

   case ( StrUpCase( !VERSION.OS_FAMILY ) ) of
      'UNIX'    : command = 'ls '       
      'WINDOWS' : command = 'dir /b /s '       
      else      : Message, '*** Operating system not supported! ***'
   endcase

   if StrUpCase( !VERSION.OS_FAMILY ) eq 'WINDOWS' then $
   name = exchar(dir, '/', '\') else name = dir

   spawn, command+name, files

 return, files

 end
