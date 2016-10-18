function f = CubicSplineInterpolationDerivative( c, x, knots )
%CUBICSPLINEINTERPOLATION f = cx
    [m, n] = size(c);
    for i = 1:m
        f(i) = polyval(c(i, 1:end-1) .* [n-1:-1:1], x(i) - knots(i));
    end
    f(m+1) = polyval(c(m, 1:end-1) .* [n-1:-1:1], x(m+1) - knots(m));    
end
