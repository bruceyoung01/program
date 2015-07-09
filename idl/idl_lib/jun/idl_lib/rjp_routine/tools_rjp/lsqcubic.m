% lsqcubic.m                                     by:  Edward T Peltzer, MBARI
%                                                revised:  2000 Jan 28.
% 
% M-file to calculate a MODEL-2 least squares fit from weighted data.
%
%     The line is fit by MINIMIZING the weighted residuals in both x & y.
%
%     The equation of the line is:     y = mx + b,
%
%       where m is determined by finding the roots to the cubic equation:
%
%               m^3 + P * m^2 + Q * m + R = 0.
%
%     Eqs for P, Q and R are from York (1966) Canad. J. Phys. 44: 1079-1086.
%
%     Data are input and output as follows:
%
%         [m,b,rc,sm,sb,xc,yc,ct] = lsqcubic(X,Y,sX,sY,tl)
%
%             X    =    x data (vector)
%             Y    =    y data (vector)
%             sX   =    uncertainty of x data (vector)
%             sY   =    uncertainty of y data (vector)
%
%             tl   =    test limit for difference between slope iterations  
%
%             m    =    slope
%             b    =    y-intercept
%             rq   =    weighted correlation coefficient
%
%             sm   =    standard deviation of the slope
%             sb   =    standard deviation of the y-intercept
%
%             xq   =    WEIGHTED mean of x values
%             yq   =    WEIGHTED mean of y values
%
%             ct   =    count: number of iterations
%
%     Notes:  1.  (xc,yc) is the WEIGHTED centroid.
%             2.  Iteration of slope continues until successive differences
%                 are less than the user-set limit "tl".  Smaller values of
%                 tl require more iterations to find the slope.
%             3.  Suggested values of tl = 1e-4 to 1e-6.
 
function [m,b,rc,sm,sb,xc,yc,ct]=lsqcubic(X,Y,sX,xY,tl)
 
 
% Find the number of data points and make one time calculations:
 
n = length(X);
wX = 1 ./ (sX .^ 2);
wY = 1 ./ (xY .^ 2);


% Set-up a few initial conditions:

ct = 0;
ML = 1;
 
 
% ESTIMATE the slope by calculating the major axis according
%   to Pearson's (1901) derivation, see: lsqfitma.m
 
MC = lsqfitma(X,Y);
 
test = abs((ML - MC) / ML);
 
 
% Calculate the least-squares-cubic
 
% Make iterative calculations until the relative difference is
%   less than the test conditions
 
while test > tl
 
        % Calculate sums and other re-used expressions:
 
        MC2 = MC ^ 2;
        W = (wX .* wY) ./ ((MC2 .* wY) + wX);
        W2 = W .^ 2;
 
        SW = sum(W);
        xc = (sum(W .* X)) / SW;
        yc = (sum(W .* Y)) / SW;
 
        U = X - xc;
        V = Y - yc;
 
        U2 = U .^ 2;
        V2 = V .^ 2;
 
        SW2U2wX = sum(W2 .* U2 ./ wX);
 
        % Calculate coefficients for least-squares cubic:
 
        P = -2 * sum(W2 .* U .* V ./ wX) / SW2U2wX;
        Q = (sum(W2 .* V2 ./ wX) - sum(W .* U2)) / SW2U2wX;
        R = sum(W .* U .* V) / SW2U2wX;
 
        % Find the roots to the least-squares cubic:
 
        LSC = [1 P Q R];
        MR = roots(LSC);
 
        % Find the root closest to the slope:
 
                DIF = abs(MR - MC);
                [MinDif,Index] = min(DIF);
 
        ML = MC;
        MC = MR(Index);
        test = abs((ML - MC) / ML);
        ct = ct + 1;
 
end
 
% Calculate m, b, rc, sm, and sb
 
m = MC;
b = yc - m * xc;
 
rc = sum(U .* V) / sqrt(sum(U2) * sum(V2));
 
sm2 = (1 / (n - 2)) * (sum(W .* (((m * U) - V) .^ 2)) / sum(W .* U2));
sm = sqrt(sm2);
sb = sqrt(sm2 * (sum(W .* (X .^ 2)) / SW));
