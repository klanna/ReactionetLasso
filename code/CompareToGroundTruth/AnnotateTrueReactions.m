function kTrue = AnnotateTrueReactions( k, stoichTR, stoich )
    N_re = size(stoich, 2);
    kTrue = zeros(N_re, 1);
    N_tr = length(k);
    for i = 1:N_tr
        s = stoichTR(:, i);
        [~,indx]=ismember(s', stoich', 'rows');
        if indx
            kTrue(indx) = k(i);
        end
    end
end

