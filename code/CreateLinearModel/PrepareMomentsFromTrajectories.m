function [ E, V, C, E2, C3, Ci_ij ]= PrepareMomentsFromTrajectories( Trajectories, boot )
    [N_sp, N_sample] = size(Trajectories);
    if min(N_sample, N_sp) == 1
        N_sp = max(N_sample, N_sp);
        N_sample = 1;
    end

    [Cmap, C3map, E3map] = CovMap(N_sp);
    C = zeros(max(max(Cmap)), 1);
    E2 = zeros(max(max(Cmap)), 1);
    C3 = zeros(max(max(max(C3map))), 1);
    Ci_ij = zeros(max(max(Cmap))*2, 1);
    

    if N_sample > 1
        w = N_sample / (N_sample-1);
        
        rng(boot);
        if boot > 1            
            Trajectories = datasample(Trajectories, size(Trajectories, 2), 2);
        end

        E = mean(Trajectories, 2)';
        CV = cov(Trajectories');
        V = diag(CV);

        l = 0;
        E3 = [];
        for i = 1:N_sp
            X_i = Trajectories(i, :);
            for j = (i+1):N_sp
                l = l+1;
                X_ij = X_i .* Trajectories(j, :);

                C(l) = CV(i, j);
                E2(l) = CV(i, j)/w + E(i)*E(j);

                for k = (j+1):N_sp
                    E3(end+1) = mean(X_ij .* Trajectories(k, :), 2); % E X_i X_j X_k
                end
            end
        end

        l = 0;
        C3 = [];
        for i = 1:N_sp
            X_i = Trajectories(i, :) .^2 ;
            for j = 1:N_sp
                if i ~= j

                    X_j = Trajectories(j, :);                        
                    l = l+1;
                    Ci_ij(l) = mean(X_i .* X_j) - E(i)*E2(Cmap(i, j));

                    for k = 1:N_sp
                        if (j ~= k) && (i ~= k)
                            m = sort([i, j, k]);
                            l3 = E3map(m(1), m(2), m(3));
                            C3(end+1) = (E3(l3) - E(i).*E2(Cmap(j, k)));
                        end
                    end
                end
            end        
        end
    else
        E = Trajectories;
        V = zeros(N_sp, 1);
    end
end

function [Cmap, C3map, E3map] = CovMap(N_sp)
    l = 0;
    l1 = 0;
    Cmap = zeros(N_sp, N_sp);
    C3map = zeros(N_sp, N_sp, N_sp);
    E3map = zeros(N_sp, N_sp, N_sp);

    for i = 1:N_sp
        for j = (i + 1):N_sp
            l = l+1;
            Cmap(i, j) = l;
            Cmap(j, i) = l;
            for k = (j + 1):N_sp
                l1 = l1+1;
                E3map(i, j, k) = l1;
            end
        end
    end
    
    l1 = 0;
    for i = 1:N_sp
        for j = 1:N_sp
            for k = 1:N_sp
                if (i ~= j) && (j ~= k) && (i ~= k)
                    l1 = l1+1;
                    C3map(i, j, k) = l1;
                end
            end
        end
    end
    
end
