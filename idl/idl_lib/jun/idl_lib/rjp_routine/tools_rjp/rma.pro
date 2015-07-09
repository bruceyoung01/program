; lsqfitgm.m                                     by:  Edward T Peltzer, MBARI
;                                                revised:  2000 Jan 31.
; 
; M-file to calculate a "MODEL-2" least squares fit.
;
;     The SLOPE of the line is determined by calculating the GEOMETRIC MEAN
;       of the slopes from the regression of Y-on-X and X-on-Y.
;
;     The equation of the line is:     y = mx + b.
;
;     This line is called the GEOMETRIC MEAN or the REDUCED MAJOR AXIS.
;
;     See Ricker (1973) Linear regressions in Fishery Research, J. Fish.
;       Res. Board Can. 30: 409-434, for the derivation of the geometric
;       mean regression.
;
;     Since no statistical treatment exists for the estimation of the
;       asymmetrical uncertainty limits for the geometric mean slope,
;       I have used the symmetrical limits for a model I regression
;       following Ricker's (1973) treatment.  For ease of computation,
;       equations from Bevington and Robinson (1992) "Data Reduction and
;       Error Analysis for the Physical Sciences, 2nd Ed."  pp: 104, and
;       108-109, were used to calculate the symmetrical limits: sm and sb.
;
;     Data are input and output as follows:
;
;	    [m,b,r,sm,sb] = lsqfitgm(X,Y)
;
;             X    =    x data (vector)
;             Y    =    y data (vector)
;
;             m    =    slope
;             b    =    y-intercept
;             r    =    correlation coefficient
;             sm   =    standard deviation of the slope
;             sb   =    standard deviation of the y-intercept
;
;     Note that the equation passes through the centroid:  (x-mean, y-mean)
 
pro rma, X, Y, Grad, Cept, R,  yfit

; Determine slope of Y-on-X regression

out = lsqfity(X,Y)
 my = out[0]

; Determine slope of X-on-Y regression

out = lsqfitxi(X,Y)
mxi = out[0]

; Calculate geometric mean slope

m = sqrt(my * mxi);

if (my < 0) and (mxi < 0) then m = -1*m;

; Determine the size of the vector
 
n = float(n_elements(X));
 
; Calculate sums and means
 
Sx = total(X);
Sy = total(Y);
xbar = Sx/n;
ybar = Sy/n;

; Calculate geometric mean intercept

b = ybar - m * xbar;

; Calculate more sums

Sxy = total(X * Y);
Sx2 = total(X^2);
Sy2 = total(Y^2);

; Calculate re-used expressions

num = n * Sxy - Sx * Sy;
den = n * Sx2 - Sx^2;

; Calculate r, sm, sb and s2

r = sqrt(my / mxi);

if (my < 0) and (mxi < 0) then r = -1*r;

diff = Y - b - m * X;

s2 = total(diff * diff) / (n-2);
sm = sqrt(n * s2 / den);
sb = sqrt(Sx2 * s2 / den);

Grad = m
Cept = b

yfit = X * Grad + Cept    

end