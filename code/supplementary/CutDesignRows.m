function [indx_I, indx_J, values, N_obs, N_re, EmptyIndx, NonEmptyIndx] = CutDesignRows(indx_I, indx_J, values, N_obs, N_re, N_sp, N_T)
    A = sparse(indx_I, indx_J, values, N_obs, N_re);
    wmask = WeightsMask( N_sp, N_T, N_obs, [1 0 0], 2 );
    EmptyIndx = find( wmask == 0);
    NonEmptyIndx = find(wmask);
    A(EmptyIndx, :) = [];
    [indx_I, indx_J, values] = find(A);
    [N_obs, N_re] = size(A);
    clear A
end