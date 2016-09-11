function [indx_I, indx_J, values, N_obs, N_re, RunTimeS, RunTimeSname] = PrepareDesign(FolderNames, E, V, C, E2, C3, E12, stoich, varargin)    
    RunTimeSname = 'PrepareDesign';
    if ~exist(FolderNames.LinSystem, 'dir')
        mkdir(FolderNames.LinSystem)
    end
    OutFileName = sprintf('%s/Design.mat', FolderNames.LinSystem);
    E(:, 1) = [];
    V(:, 1) = [];
    C(:, 1) = [];
    E2(:, 1) = [];
    C3(:, 1) = [];
    E12(:, 1) = [];
    
    if ~isempty(varargin) 
        SaveFlag = 1;
    else
        SaveFlag = 0;
    end
    NMom = FolderNames.NMom;
    
    if ~exist(OutFileName, 'file') || ~SaveFlag
        % fprintf('ConstructDesignMatrix %s...\n', FolderNames.ModelNameT);
        ts = tic;

%%        init system
        [N_sp, N_re] = size(stoich);
        N_T = size(E, 2);
        N_mom = NMom*N_sp + (NMom-1)*N_sp*(N_sp-1)/2;
        N_obs = N_mom*N_T;
        
        indx_I = [];
        indx_J = [];
        values = [];
        
        Cmapping = CMap(N_sp);
        E12mapping = E12Map(N_sp);
        C3mapping = C3Map(N_sp);
%% start procedure        
        for l = 1:N_re              
            F = zeros(N_mom, N_T);
            s = stoich(:, l);
            s_indx = find(s);
            indxOUT = sort(find(s == -1));
            switch length(indxOUT)
                case 1
                    a_l = E(indxOUT(1), :);
                case 2
                    a_l = E2(Cmapping(indxOUT(1), indxOUT(2)), :);
            end           
            %%
            for i = 1:length(s_indx)
                s_i = s_indx(i);
                F(s_i, :) = s(s_i)*a_l; % Mean
                
                if s(s_i) == -1
                    switch length(indxOUT)
                        case 1
                            % i ->  j + k
                            cv_i = V(s_i, :); % cov(i, i) = var(i)
                        case 2
                            % i + j -> k cov(i, i*j) 
                            if s_i == indxOUT(1)
                                ii = indxOUT(2);
                            else
                                ii = indxOUT(1);
                            end
                            cv_i = E12(E12mapping(s_i, ii), :);
                    end
                else
                    switch length(indxOUT)
                        case 1
                            % j  -> i
                            cv_i = C(Cmapping(min(s_i, indxOUT(1)), max(s_i, indxOUT(1))), :);
                        case 2
                            % j + k -> i
                            cv_i = C3(C3mapping(s_i, indxOUT(1), indxOUT(2)), :);
                    end
                end
                
                F(N_sp + s_i, :) = a_l + 2*s(s_i)*cv_i;
                
                for s_j = 1:N_sp
                    if s_j ~= s_i
                        if s(s_j) == -1
                            switch length(indxOUT)
                                case 1
                                    cv_j = V(s_j, :);
                                case 2
                                    if s_j == indxOUT(1)
                                        ii = indxOUT(2);
                                    else
                                        ii = indxOUT(1);
                                    end
                                    cv_j = E12(E12mapping(s_j, ii), :);
                            end
                        else
                            switch length(indxOUT)
                                case 1
                                    cv_j = C(Cmapping(min(s_j, indxOUT(1)), max(s_j, indxOUT(1))), :);
                                case 2
                                    cv_j = C3(C3mapping(s_j, indxOUT(1), indxOUT(2)), :);
                            end
                        end
                        F(2*N_sp + Cmapping(min(s_i, s_j), max(s_i, s_j)), :) = s(s_i)*s(s_j)*a_l + s(s_i)*cv_j + s(s_j)*cv_i;
                    end
                end
            end 
            Feature = reshape(F, [], 1);
            indxF_i = find(Feature)';
            indxF_j = l*ones(size(indxF_i));
            indx_I = [indx_I indxF_i];
            indx_J = [indx_J indxF_j];
            values = [values Feature(indxF_i)'];
        end
        
        RunTimeS = toc(ts);
        if SaveFlag
            save(OutFileName, '-v7.3', 'indx_I', 'indx_J', 'values', 'N_obs', 'N_re', 'RunTimeS')
        end
        
        FormatTime( RunTimeS, 'ConstructDesignMatrix finished in ' );
    else
        load(OutFileName);
    end
end


function m = CMap(n)
    l = 0;
    for i = 1:n
        for j = (i+1):n
            l = l+1;
            m(i, j) = l;
        end
    end
end

function m = E12Map(n)
    l = 0;
    for i = 1:n
        for j = 1:n
            if i ~= j
                l = l+1;
                m(i, j) = l;
            end
        end        
    end
end

function m = C3Map(n)
    l = 0;
    for i = 1:n
        for j = 1:n
            for k = 1:n
                if (i ~= j) && (j ~= k) && (i ~= k)
                    l = l+1;
                    m(i, j, k) = l;
                end
            end
        end        
    end
end

