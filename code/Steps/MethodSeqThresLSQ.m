function [StatLassoLL, RunTimeS, RunTimeSname] = MethodSeqThresLSQ( FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, kTrue, Av, bv, Nhours)
    MaxTimeS = Nhours*60*60;
    
    ts = tic;
    RunTimeSname = 'SeqThresLSQ';
    fprintf('----------------%s----------------\n', RunTimeSname);
    if FolderNames.CV
        OutFolder = sprintf('%s/', FolderNames.ResultsCV);
    else
        OutFolder = sprintf('%s/', FolderNames.Results);
    end
    OutFileName = sprintf('%s/%s.mat', OutFolder, RunTimeSname);
    
    if ~exist(OutFolder, 'dir')
        mkdir(OutFolder)
    end
    
%     if ~exist(OutFileName, 'file')
    %%  weight on error distribution
        [ values, weights ] = WeightDesignForRegression( indx_I, indx_J, values, N_obs, N_re ); %  weight design
        Aw = sparse(indx_I, indx_J, values, N_obs, N_re);  
        constrW = constr .* weights;
        
        xLSQw = lsqnonneg(Aw, b);
        Sigma2 = sum((b - Aw*xLSQw).^2);
        Xi = xLSQw;
        
        i = 0;
        deg = 4;
        RunTimeS = 0;
        cc = 0;
        while (cc < 200) && (RunTimeS < MaxTimeS)
            i = i+1;
            lambda = 10^deg;
            fprintf('lambda(%u) = 10^{%u}\n', i, deg);
            StatLassoLL(i).lambda = lambda;
            
            Xi = xLSQw; % initial guess: Least-squares
            biginds_old = VertVect(zeros(length(Xi), 1));
            biginds =  VertVect(1:length(Xi));
            iter = 0;
            
            while ~isequal(biginds_old, biginds) 
                Xi(find( Xi < lambda )) = 0; % and threshold
                biginds_old = biginds;
                biginds =  VertVect(find(Xi));
                % Regress dynamics onto remaining terms to find sparse Xi
                Xi(biginds) = lsqnonneg(Aw(:, biginds), b);
                iter = iter + 1;
            end
            fprintf('TOTAL %u ITERATIONS\n', iter);
            
            StatLassoLL(i).iter = iter;
            StatLassoLL(i).xOriginal =  Xi ./ weights;
            StatLassoLL(i).fdr = FDR(kTrue, StatLassoLL(i).xOriginal);
            StatLassoLL(i).rTrain  = Aw*(StatLassoLL(i).xOriginal .* weights);
            StatLassoLL(i).r  = Av*(StatLassoLL(i).xOriginal);
            StatLassoLL(i).rss = sum((bv - [StatLassoLL(i).r]).^2);
            StatLassoLL(i).rssTrain = sum((b - [StatLassoLL(i).rTrain]).^2);
            StatLassoLL(i).card = length(find(StatLassoLL(i).xOriginal));
            [StatLassoLL(i).AIC_reg, StatLassoLL(i).BIC_reg, StatLassoLL(i).cPm_reg] = ICfunc(StatLassoLL(i).rss, StatLassoLL(i).card, N_obs, Sigma2);
            deg = deg - 1;
            fprintf('card = %u\tTP = %u\tFP = %u\n', StatLassoLL(i).card, StatLassoLL(i).fdr(1), StatLassoLL(i).fdr(2));
            RunTimeS = toc(ts);
            save(OutFileName, '-append', 'StatLassoLL', 'RunTimeS');
            cc = length(find(Xi));
        end
        FormatTime( RunTimeS, 'finished in ' );
        
%     else
%         load(OutFileName)
%     end
end

function [AIC, BIC, cPm] = ICfunc(ll, df, N, S)
    cPm = ll/S + 2*df;
    BIC = N*log(ll) + log(N)*df;
    AIC = N*log(ll) + 2*df;
end

function [indx_I, indx_J, values, N_obs, N_re, indxNeg, indxPos] = CutDesign(indx_I, indx_J, values, N_obs, N_re, x0)
    A = sparse(indx_I, indx_J, values, N_obs, N_re);
    indxNeg = find( x0 == 0 );
    indxPos = find( x0 );
    A(:, indxNeg) = [];
    [indx_I, indx_J, values ] = find(A);
    [N_obs, N_re] = size(A);
    clear A
end

function [ values, xAW ] = AdaptationDesign( indx_J, values, xAW)
% Adapting design and corresponding rate constants
% xAW - values to use for adaptation
% indx_J, values - design matrix
% k - rate constants
% Method:
% (A * xAw)*(x / xAw), x_adapt = x / xAw
% WarmStart - warm start for regressin problem
    tsld = tic;
    fprintf('Adapting design...\t');
    
    xAW(xAW == 0) = 1;
    values = WeightSparseMatrix( indx_J, values, xAW);     
    
    fprintf('%.5f sec\n', toc(tsld));
end

