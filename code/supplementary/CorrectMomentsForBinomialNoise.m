function [ E, V, C, E2, C3, E12 ] = CorrectMomentsForBinomialNoise( E, V, C, E2, C3, E12, p )
    E = E / p;
    V = max(0, (V - (1-p)*p*E) / (p^2));
%     V = (V - (1-p)*p*E) / (p^2);
%     V = V / (p^2);
    C = C / (p^2);
    E2 = E2  / (p^2);
    C3 = C3 / (p^3);
    
    N_sp = size(E, 1);
    [Cmap] = CovMap(N_sp);
    l = 0;
    for i = 1:N_sp
        for j = 1:N_sp
            if i ~= j
                l = l+1;
                E12(l, :, :) = (E12(l, :, :) - (1-p)*p*p*E2(Cmap(i, j), :, :))/ (p^3);
            end
        end
    end
end

