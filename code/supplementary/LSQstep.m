function xLSQ = LSQstep( A, b, xlasso )
    indxPos = find(xlasso); % keep only non-zero features    
    xLSQ = zeros(size(xlasso));     
    xLSQ(indxPos) = lsqnonneg(A(:, indxPos), b);
end

