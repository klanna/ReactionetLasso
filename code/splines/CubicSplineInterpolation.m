function f = CubicSplineInterpolation( c, x, knots )
%CUBICSPLINEINTERPOLATION f = cx
    m = length(x);
    for i = 1:m-1
        f(i) = polyval(c(i, :), x(i) - knots(i));
    end
    f(m) = polyval(c(m-1, :),  x(m) - knots(m-1));
end
