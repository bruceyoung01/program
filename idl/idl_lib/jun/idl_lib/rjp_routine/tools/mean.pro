; $Id: mean.pro,v 1.1.1.1 2003/10/22 18:09:40 bmy Exp $
function mean,x,dim,_EXTRA=e

   ; multidimensional version from Kevin Ivory (04/03/1997)

   on_error,2

   if (n_elements(dim) eq 0) then dim = 0
   return,total(x,dim,_EXTRA=e)/(total(finite(x),dim)>1)

end
