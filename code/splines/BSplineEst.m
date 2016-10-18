function [ y_hat, dy_hat ] = BSplineEst( k, breaks, cBsplines, t)
%BSPLINEEST Summary of this function goes here
%   k = degree of spline (k = 4 for cubic)
%   x, y = input data
%   t - values at which we want to find estiamtes
    bsplinemat = bsplineM(t, breaks, k);
    y_hat = bsplinemat*cBsplines;
    dbsplinemat = bsplineM(t, breaks, k, 1);
    dy_hat = dbsplinemat*cBsplines;
end

