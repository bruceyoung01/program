
 function csvconvert, input, char=char

 If N_elements(char) eq 0 then char = ','

 string = string(input)
 pos = strpos(string,char)

 if pos[0] eq -1 then begin
   print, 'there is no '+char+' in the string'
   return, 0
 endif

 len = strlen(string)
 array = ''

 while pos[0] ne -1 do begin
   if strpos(string,'"') eq 0 then pos = strpos(string,'"',1)+1

   var = strmid(string,0,pos[0])
   array = [array, var]
   string = strmid(string,pos[0]+1,len)
   pos = strpos(string,char)
 end
  if strlen(string) ne 0 then array = [array, string]

  return, strtrim(array[1:*],2)

 end
