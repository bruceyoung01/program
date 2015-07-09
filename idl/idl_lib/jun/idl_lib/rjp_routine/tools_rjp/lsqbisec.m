% lsqbisec.m                                     by:  Edward T Peltzer, MBARI
%                                                revised:  2000 Feb 10.
% 
% M-file to calculate a "MODEL-2" least squares fit.
%
%     The SLOPE of the line is determined by calculating the slope of the line
%       that bisects the minor angle between the regression of Y-on-X and X-on-Y.
%
%     The equation of the line is:     y = mx + b.
%
%     This line is called the LEAST SQUARES BISECTOR.
%
%     See: Sprent and Dolby (1980). The Geometric Mean Functional Relationship.
%       Biometrics 36: 547-550, for the rationale behind this regression.
%
%     Sprent and Dolby (1980) did not present a statistical treatment for the
%       estimation of the uncertainty limits for the least squares bisector
%       slope, or intercept.
%
%     I have used the symmetrical limits for a model I regression following
%       Ricker's (1973) treatment.  For ease of computation, equations from
%       Bevington and Robinson (1992) "Data Reduction and Error Analysis for
%       the Physical Sciences, 2nd Ed."  pp: 104, and 108-109, were used to
%       calculate the symmetrical limits: sm and sb.
%
%     Data are input and output as follows:
%
%	    [m,b,r,sm,sb] = lsqbisec(X,Y)
%
%             X    =    x data (vector)
%             Y    =    y data (vector)
%
%             m    =    slope
%             b    =    y-intercept
%             r    =    correlation coefficient
%             sm   =    standard deviation of the slope
%             sb   =    standard deviation of the y-intercept
%
%     Note that the equation passes through the centroid:  (x-mean, y-mean)
 
function [m,b,r,sm,sb]=lsqbisec(X,Y)

% Determine slope of Y-on-X regression

[my] = lsqfity(X,Y);

% Determine slope of X-on-Y regression

[mxi] = lsqfitxi(X,Y);

% Calculate the least squares bisector slope

theta = (atan(my) + atan(mxi)) / 2;
m = tan(theta);

% Determine the size of the vector
 
n = length(X);
 
% Calculate sums and means
 
Sx = sum(X);
Sy = sum(Y);
xbar = Sx/n;
ybar = Sy/n;

% Calculate the least squares bisector intercept

b = ybar - m * xbar;

% Calculate more sums

Sxy = sum(X .* Y);
Sx2 = sum(X.^2);
Sy2 = sum(Y.^2);

% Calculate re-used expressions

num = n * Sxy - Sx * Sy;
den = n * Sx2 - Sx^2;

% Calculate r, sm, sb and s2

r = sqrt(my / mxi);

if (my < 0) & (mxi < 0)
	r = -r;
end

diff = Y - b - m .* X;

s2 = sum(diff .* diff) / (n-2);
sm = sqrt(n * s2 / den);
sb = sqrt(Sx2 * s2 / den);
