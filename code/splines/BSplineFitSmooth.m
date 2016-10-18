function [ cBsplines, breaks, bsplinemat ] = BSplineFitSmooth( lambda, x, y, b_hat, w, varargin)
%BSPLINEFIT Summary of this function goes here
%   k = degree of spline (default: k = 4 for cubic)
%   x, y = input data
%   t - values at which we want to find estiamtes
    x = VertVect(x);
    y = VertVect(y);
    w = VertVect(w);
    w(w == 0) = 1;
    
    b_hat = VertVect(b_hat);
    
    if ~isempty(varargin)
        k = varargin{1};
    else
        k = 4;
    end
    
    breaks = unique([x(1); x(1:2:end); x(end)]);
    bsplinemat = bsplineM(x, breaks, k);
    dbsplinemat = bsplineM(x(2:end), breaks, k, 1);
    
    for i = 1:size(bsplinemat, 1)
        bsplinemat(i, :) = bsplinemat(i, :) /w(i);
%         dbsplinemat(i, :) = dbsplinemat(i, :) /dw(i);
    end
    
%      cBsplines = bsplinemat \ y;
    dw = mean(b_hat);
%     dw = std(b_hat);
%     if dw == 0
%         dw = 1;
%     end
    cBsplines = [bsplinemat ; lambda*dbsplinemat/ dw] \ [y ./ w; lambda*b_hat / dw];
end

