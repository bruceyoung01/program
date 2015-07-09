% lsqfityw.m                                     by:  Edward T Peltzer, MBARI
%                                                revised:  2000 Jan 27.
%
% M-file to calculate a "MODEL-1" least squares fit to WEIGHTED x,y-data pairs:
%
%     The line is fit by MINIMIZING the WEIGHTED residuals in Y only.
%
%     The equation of the line is:     Y = mw * X + bw.
%
%     Equations are from Bevington & Robinson (1992)
%       Data Reduction and Error Analysis for the Physical Sciences, 2nd Ed."
%       for mw, bw, smw and sbw, see p. 98, example calculation in Table 6.2;
%       for rw, see p. 199, and modify eqn 11.17 for a weighted regression by
%           substituting Sw for n, Swx for Sx, Swy for Sy, Swxy for Sxy, etc. 
%
%     Data are input and output as follows:
%
%         [mw,bw,rw,smw,sbw,xw,yw] = lsqfityw(X,Y,sY)
%
%             X     =    x data (vector)
%             Y     =    y data (vector)
%             sY    =    estimated uncertainty in y data (vector)
%
%             sy may be measured or calculated:
%                 sY = sqrt(Y), 2% of y, etc.
%             data points are then weighted by:
%                 w = 1 / sY-squared.
%
%             mw    =    slope
%             bw    =    y-intercept
%             rw    =    weighted correlation coefficient
%             smw   =    standard deviation of the slope
%             sbw   =    standard deviation of the y-intercept
%
%     NOTE that the line passes through the weighted centroid: (xw,yw).

function [mw,bw,rw,smw,sbw,xw,yw]=lsqfityw(X,Y,sY)

% Determine the size of the vector

n = length(X);

% Calculate the weighting factors

W = 1 ./ (sY.^2);

% Calculate the sums

Sw = sum(W);
Swx = sum(W .* X);
Swy = sum(W .* Y);
Swx2 = sum(W .* X.^2);
Swxy = sum(W .* X .* Y);
Swy2 = sum(W .* Y.^2);

% Determine the weighted centroid

xw = Swx / Sw;
yw = Swy / Sw;

% Calculate re-used expressions

num = Sw * Swxy - Swx * Swy;
del1 = Sw * Swx2 - Swx^2;
del2 = Sw * Swy2 - Swy^2;

% Calculate mw, bw, rw, smw, and sbw

mw = num / del1;
bw = (Swx2 * Swy - Swx * Swxy) / del1;

rw = num / (sqrt(del1 * del2));

smw = sqrt(Sw / del1);
sbw = sqrt(Swx2 / del1);
