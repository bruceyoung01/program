% lsqfityz.m                                     by:  Edward T Peltzer, MBARI
%                                                revised:  2000 Jan 27.
%
% M-file to calculate a "MODEL-1" least squares fit to WEIGHTED x,y-data pairs:
%
%     The line is fit by MINIMIZING the WEIGHTED residuals in Y only.
%
%     The equation of the line is:     Y = mz * X + bz.
%
%     Equations are from Bevington & Robinson (1992)
%       Data Reduction and Error Analysis for the Physical Sciences, 2nd Ed."
%       for mz and bz, see p. 98, example calculation in Table 6.2;
%       for rz, see p. 199, and modify eqn 11.17 for a weighted regression by
%           substituting Sw for n, Swx for Sx, Swy for Sy, Swxy for Sxy, etc. 
%
%       smz, sbz are adapted from: York (1966) Canad. J. Phys. 44: 1079-1086.
%
%     Data are input and output as follows:
%
%         [mz,bz,rz,smz,sbz,xz,yz] = lsqfityz(X,Y,sY)
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
%             mz    =    slope
%             bz    =    y-intercept
%             rz    =    weighted correlation coefficient
%             smz   =    standard deviation of the slope
%             sbz   =    standard deviation of the y-intercept
%
%     NOTE that the line passes through the weighted centroid: (xz,yz).

function [mz,bz,rz,smz,sbz,xz,yz]=lsqfityw(X,Y,sY)

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

xz = Swx / Sw;
yz = Swy / Sw;

% Calculate re-used expressions

num = Sw * Swxy - Swx * Swy;
del1 = Sw * Swx2 - Swx^2;
del2 = Sw * Swy2 - Swy^2;

U = X - xz;
V = Y - yz;
U2 = U.^2;
V2 = V.^2;

% Calculate mw, bw, rw, smw, and sbw

mz = num / del1;
bz = (Swx2 * Swy - Swx * Swxy) / del1;

rz = num / (sqrt(del1 * del2));

sm2 = (1 / (n-2)) * (sum(W .* (((mz * U) - V) .^ 2)) / sum(W .* U2));
smz = sqrt(sm2);
sbz = sqrt(sm2 * (sum(W .* (X.^2)) / Sw));
