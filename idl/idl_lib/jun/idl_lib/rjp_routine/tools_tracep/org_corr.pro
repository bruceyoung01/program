Pro Org_Corr, X, Y, Grad, Cept, R,  Grad_Err, Cept_Err,  yfit

;-----------------------------------------------------------------------------
; Calculate reduced major axis. Given two arrays X(NPOINTS) and
; Y(NPOINTS) this subroutine compute the Gradient and Y intercept
; of the line given by the reduced major axis. The main advantage
; of this is that the best fit line of X and Y will be the same
; as the best fit line of Y and X.
; More details are in Hirsch and Gilroy, Water Res. Bull., 20(5), Oct
; 1984
; Standard errors also calculated according to Miller and Kahn,
; Statistical Analysis in the Geological Sciences, 1962, p. 204-210
;-----------------------------------------------------------------------------
npoints = n_elements(x)
if (n_elements(y) ne npoints) then begin
   print,  'Number of elements of X is not the same as Y'
   stop
endif

R = correlate(x, y)
R2 = R^2
Fac = 0

Case 1 of
    R GT 0.0 : Fac = 1.0
    R EQ 0.0 : Fac = 0.0
    R LT 0.0 : Fac = -1.0
    else : fac = 0.0
EndCase

Xbar = Total(X(0:NPoints-1))/Float(NPoints)
Ybar = Total(Y(0:NPoints-1))/Float(NPoints)

Xbar2 = Xbar^2
Ybar2 = Ybar^2
Sx = 0.0
Sy = 0.0
For I = 0, NPoints-1 Do Begin
   Sx = Sx + ( X(I) - XBar)^2.0
   Sy = Sy + ( Y(I) - YBar)^2.0
EndFor
Sx = Sqrt(Sx / Float(NPoints))
Sy = Sqrt(Sy / Float(NPoints))

Sx2 =  Sx^2
Sy2 = Sy^2
YNew = Y

For I = 0, NPoints-1 Do Begin
   YNew(I) = YBar + (Fac*(Sy/Sx)*(X(I)-XBar))
EndFor

Grad = (YNew(0) - YNew(NPoints-1))/(X(0)-X(NPoints-1))
Cept = YBar + (Fac*(Sy/Sx)*(-XBar))
Grad_Err = Sy/Sx * sqrt( (1-R2)/NPoints )
Cept_Err = Sy * sqrt( (1-R2)/NPoints*(1+Xbar2/Sx2) )

yfit = Cept+Grad*x
End

