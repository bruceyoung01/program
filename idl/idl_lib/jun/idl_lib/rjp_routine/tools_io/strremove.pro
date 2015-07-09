 function strremove, str, target

 ; str is string
 ; target is single charater to be removed

   bit = byte(str)
   tag = byte(target)

   P   = where(bit eq tag[0], complement=I)
   new = bit[I]

   return, string(new)

 end
