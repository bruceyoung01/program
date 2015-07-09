 function chk_undefined, data

   i = where(finite(data) eq 1)
   if i[0] ne -1 then array = data[i] else return, -1
   i = where(array gt 0.)
   array = array[i]

   return, array
 end
