function [ cBsplines, breaks, bsplinemat ] = BSplineFit( x, y, varargin)
%BSPLINEFIT Summary of this function goes here
%   k = degree of spline (default: k = 4 for cubic)
%   x, y = input data
%   t - values at which we want to find estiamtes
    x = VertVect(x);
    y = VertVect(y);
    if ~isempty(varargin)
        k = varargin{1};
    else
        k = 4;
    end
    breaks = unique([x(1); x(1:2:end); x(end)]);
    bsplinemat = bsplineM(x, breaks, k);
    cBsplines = bsplinemat \ y;
end

