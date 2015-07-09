
 function sign_for, A, B

  if (B lt 0) then sgn = -1. else sgn = 1.

 return, abs(A) * sgn

 end
