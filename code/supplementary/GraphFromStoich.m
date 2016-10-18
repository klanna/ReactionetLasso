function [ G ] = GraphFromStoich( stoich )
% Creates adjacency matrix from stoichiometric matrix
    [N_sp, N_re] = size(stoich);
    G = zeros(N_sp, N_sp);
    
    for re = 1:N_re
        s = stoich(:, re);
        idx_reactants = find(s == -1);
        idx_products = find(s == 1);
        for i = idx_reactants
            for j = idx_products
                G(i, j) = 1;
            end
        end
    end
    
end

