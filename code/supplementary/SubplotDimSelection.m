function [ n ] = SubplotDimSelection( N_T )
    n(1) = floor(sqrt(N_T));
    n(2) = ceil(sqrt(N_T));
    
    if (n(1)*n(2)) < N_T
        n(1) = n(2);
    end
    
    if N_T == 3
        n(1) = 1;
        n(2) = 3;
    end
end

