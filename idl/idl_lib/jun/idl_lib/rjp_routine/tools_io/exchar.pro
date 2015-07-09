 function exchar, str, old, new

   While (((I = STRPOS(str,old))) NE -1 ) DO $
   STRPUT, str, new, I

   return, str

 end
