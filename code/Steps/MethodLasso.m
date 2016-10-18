function [StatLassoLL, RunTimeS, RunTimeSname] = MethodLasso( FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, kTrue, Av, bv )
    ts = tic;
    RunTimeSname = 'MethodLasso';
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
%         weights = ones(N_re, 1);
        Aw = sparse(indx_I, indx_J, values, N_obs, N_re);  
        constrW = constr .* weights;
    %%  start
        StatLassoLL = LassoVpathCholSP(Aw, b, weights, [], constrW); % Main procedure
    %%  evaluate metrics
        xLSQw = lsqnonneg(Aw, b);
        Sigma2 = sum((b - Aw*xLSQw).^2);

        for i = 1:length(StatLassoLL)
            StatLassoLL(i).xOriginal = StatLassoLL(i).z ./ weights;
            StatLassoLL(i).fdr = FDR(kTrue, StatLassoLL(i).xOriginal);
            StatLassoLL(i).r  = Aw*(StatLassoLL(i).xOriginal .* weights);
            StatLassoLL(i).rTrain  = Av*(StatLassoLL(i).xOriginal);
            StatLassoLL(i).rss = sum((bv - [StatLassoLL(i).r]).^2);
            StatLassoLL(i).rssTrain = sum((b - [StatLassoLL(i).rTrain]).^2);
            StatLassoLL(i).card = length(find(StatLassoLL(i).xOriginal));
     
            % regression IC
            [StatLassoLL(i).AIC_reg, StatLassoLL(i).BIC_reg, StatLassoLL(i).cPm_reg] = ICfunc(StatLassoLL(i).rss, StatLassoLL(i).card, N_obs, Sigma2);
        end
        
        RunTimeS = toc(ts);
        save(OutFileName, 'StatLassoLL', 'RunTimeS');
        FormatTime( RunTimeS, 'finished in ' );
%     else
%         load(OutFileName)
%     end
end

function [AIC, BIC, cPm] = ICfunc(ll, df, N, S)
    BIC = N*log(ll) + log(N)*df;
    AIC = N*log(ll) + 2*df;
    cPm = ll/S + 2*df;
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

