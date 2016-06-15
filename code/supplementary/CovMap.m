function [Cmap] = CovMap(N_sp)
    l = 0;
    l1 = 0;
    Cmap = zeros(N_sp, N_sp);
    for i = 1:N_sp
        for j = (i + 1):N_sp
            l = l+1;
            Cmap(i, j) = l;
            Cmap(j, i) = l;
        end
    end
end

