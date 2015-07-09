; lsqfitxi.m                                     by:  Edward T Peltzer, MBARI
;                                                revised:  2000 Jan 31.
;
; M-file to calculate a "MODEL-1" least squares fit.
;
;     The line is fit by MINIMIZING the residuals in X only.
;
;     The equation of the line is:     Y = mxi * X + bxi.
;
;     Equations are modified from those in Bevington & Robinson (1992)
;       Data Reduction and Error Analysis for the Physical Sciences, 2nd Ed."
;       pp: 104, 108-109, 199.
;
;     Data are input and output as follows:
;
;         [mxi,bxi,rxi,smxi,sbxi] = lsqfitxi(X,Y)
;
;             X     =    x data (vector)
;             Y     =    y data (vector)
;
;             mxi    =    slope
;             bxi    =    y-intercept
;             rxi    =    correlation coefficient
;             smxi   =    standard deviation of the slope
;             sbxi   =    standard deviation of the y-intercept

function lsqfitxi, X, Y

; Determine the size of the vector

n = float(N_elements(X));

; Calculate the sums

Sx = total(X);
Sy = total(Y);
Sx2 = total(X^2);
Sxy = total(X*Y);
Sy2 = total(Y^2);

; Calculate re-used expressions

num = n * Sxy - Sy * Sx;
den = n * Sy2 - Sy^2;

; Calculate m, a, rx, s2, sm, and sb

mx = num / den;
a = (Sy2 * Sx - Sy * Sxy) / den;
rxi = num / (sqrt(den) * sqrt(n * Sx2 - Sx^2));

diff = X - a - mx * Y;

s2 = total(diff * diff) / (n-2);
sm = sqrt(n * s2 / den);
sa = sqrt(Sy2 * s2 / den);

; Transpose coefficients

mxi = 1 / mx;
bxi = -a / mx;

smxi = mxi * sm / mx;
sbxi = abs(sa / mx);

return, [mxi,bxi,rxi,smxi,sbxi]
end