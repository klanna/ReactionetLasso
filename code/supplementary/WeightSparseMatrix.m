function [ ValuesWeighted ] = WeightSparseMatrix( indx_J, values, w)
% weights (multiplex) each column of a sparse matrix by value in vecor w
% Aw(:, j) = Aw(:, j) .* w(j);
    N = length(values);
    for i = 1:N
       ValuesWeighted(i) = values(i) * w(indx_J(i));
    end
end

