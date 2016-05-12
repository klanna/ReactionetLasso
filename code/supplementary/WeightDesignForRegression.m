function [ values, weights ] = WeightDesignForRegression( indx_I, indx_J, values, N_obs, N_re )
% weight design to improve cond(A'A)
% indx_I, indx_J, values, N_obs, N_re - design
% (A/weights)*(x*weights), x_w = x*weights
    tsld = tic;
    fprintf('weight design...\t');
    
    A = sparse(indx_I, indx_J, values, N_obs, N_re);
    
    weights = VertVect(full(max(abs(A))));
    clear A
    weights(weights == 0) = 1;
    values = WeightSparseMatrix( indx_J, values, 1 ./ weights);

    fprintf('%.2f sec\n', toc(tsld));
end

