function [dE, pp, t, E] = SplineGradientSM(y, x)    
    pp = spline(x,y); % fit cubic splines    
    t = min(x):1:max(x);
    E = VertVect(CubicSplineInterpolation( pp.coefs, x, x));
    dE = CubicSplineInterpolationDerivative( pp.coefs, x, x );
    dE(1) = [];
end

