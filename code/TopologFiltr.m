function [ x, RunTimeS ] = TopologFiltr( A, b, Nhours)
    ts = tic;
    MaxTimeS = Nhours*60*60;
    fprintf('Compute maximum %u h\n', Nhours);

    N_re = size(A, 2);

    l = 1;
    x(:, l) = lsqnonneg(A, b);
    Ctime(l) = 0;
    
    indxPotentialRe = find(x(:, l)); % list of reactions from which we want to select next set
    NrePotential = length(indxPotentialRe);
    
    while (NrePotential > 2) && (Ctime(end) < MaxTimeS)
        clear score xl
        
        xl = zeros(N_re, NrePotential);
        
        % go through all potential reactions and set them to zero
        for reP = 1:NrePotential
            clear indx_reP
            indx_reP = indxPotentialRe;
            indx_reP(reP) = [];
            
            xl(indx_reP, reP) = lsqnonneg(A(:, indx_reP), b);
            
            score(reP) = sum((b - A*xl(:, reP)).^2);
        end
        
        [~, jbest] = min(score);
        l = l+1;
        x(:, l) = xl(:, jbest);
        indxPotentialRe(jbest) = [];
        
        Ctime(l) = toc(ts);
        NrePotential = length(indxPotentialRe);
    end
    RunTimeS = max(Ctime);
end

