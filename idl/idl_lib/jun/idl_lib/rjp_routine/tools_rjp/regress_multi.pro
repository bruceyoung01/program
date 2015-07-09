 Function regress_multi, X, Y, Const, YFIT, CONZERO=CONZERO

 ; X is matrix in nterms+1 by npoints
 ; Y is vector in npoints
 ; S is solution vector in nterms+1 [Const,s1,s2,s....]

 ; X # S = Y
 ; XX = Transpose(X)
 ; 
 ; S =  ( Y # XX ) # revert(XX # X) 

   SY = SIZE(Y)            ;Get dimensions of x and y.   
   SX = SIZE(X)

  If Keyword_set(CONZERO) then begin

   XX = Transpose(X)
   S  = ( Y # XX ) # Invert( X # XX )

   Slope = Reform(S)
   Const = 0.
  Endif else Begin

   Xnew = Replicate(1., SY[1])
   For D = 0, SX[1]-1 do $
     Xnew = [[Xnew], [Reform(X[D,*])]]

   XX   = Xnew
   Xnew = Transpose(XX)

   S = ( Y # XX ) # Invert( Xnew # XX )

   Slope = S[0,1:SX[1]]
   Const = S[0,0]
  Endelse

 return, Slope

 End

   
