function [ A, b ] = DefineSplineMatrix( x, y )
% y_i = a_i + b_i * h + c_i * h^2 + d_i * h^3
% h = x_i = x_[i-1]
    h = diff(x);
    n = length(h);
    b = zeros(4*n, 1);
    A = zeros(4*n, 4*n);
    
    for i = 1:n
        idx = 4*(i-1) + [1:4];
        idx_next = 4*i + [1:4];
        
        b(idx(1)) = y(i);
        
        A(idx(1), idx) = h(i) .^ [3:-1:0];
        
        if i < n
            % S_i-1 = S_i
            A(idx(2), idx) = h(i) .^ [3:-1:0];
            A(idx(2), idx_next) = - h(i) .^ [3:-1:0];
            % S'_i-1 = S'_i
            A(idx(3), idx(1:3)) = [3:-1:1].* (h(i) .^ [2:-1:0]);
            A(idx(3), idx_next(1:3)) = - [3:-1:1].* (h(i) .^ [2:-1:0]);
            % S''_i-1 = S''_i
            A(idx(4), idx(1:2)) = [6*h(i) 2];
            A(idx(4), idx_next(1:2)) = - [6*h(i) 2];
        end
    end
    
    % S''(x_0) = 0
    A(end-1, 3)= 1;
    A(end-1, 4)= 3*h(1);
    
    % S''(x_n) = 0
    A(end, end-1)= 1;
    A(end, end)= 3*h(end);     
end

