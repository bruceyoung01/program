 function make_zero, data, val=val

   if n_elements(val) eq 0 then val=0.

   dim = size(data,/dim)

   i = where(data le 0. or finite(data) eq 0)
   array = data
   if i[0] ne -1 then array[i] = val

   return, array

 end
