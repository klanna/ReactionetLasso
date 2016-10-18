function [ A, b ] = DefineSplineMatrix2( x, y )
% y_i = a_i + b_i * h + c_i * h^2 + d_i * h^3
% h = x_i = x_[i-1]
    h = diff(x);
    n = length(h);
    b = zeros(4*n, 1);
    A = zeros(4*n, 4*n);
    
    for i = 1:n
        G(:, i) = BasisVector(x(i), k, knots);
    end
   
end

function y = BasisVector(x, k, knots)
    for i = 1:k+1
        y(i) = x^(i-1);
    end
    
    for j = 1:lenght(knots)
        y(k + 1 + j) = max(0, (x - knots(j))^k);
    end
end