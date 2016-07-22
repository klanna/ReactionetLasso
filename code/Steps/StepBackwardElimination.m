function [StatLassoLL, RunTimeS, RunTimeSname] = StepBackwardElimination( FolderNames, indx_I, indx_J, values, N_obs, N_re, N_sp, b, bStdEps, constr, BestResStat, prior_indx, N_T )
    ts = tic;
    RunTimeSname = 'StepBackwardElimination';
    fprintf('----------------%s----------------\n', RunTimeSname);
    OutFolder = sprintf('%s/', FolderNames.ResultsCV);
    OutFileName = sprintf('%s/%s.mat', OutFolder,RunTimeSname);
%     if ~exist(OutFileName, 'file')
        x1 = VertVect([BestResStat.xOriginal]);
        x1(prior_indx) = 1;
    %% shorten design A
        N_reOri = N_re;
        [indx_I, indx_J, values, N_obs, N_re, indxNeg, indxPos] = CutDesign(indx_I, indx_J, values, N_obs, N_re, x1);
        
        x1(indxNeg) = [];
        constr(indxNeg) = [];
    %% weight on error distribution
        [ values, weights ] = WeightDesignForRegression( indx_I, indx_J, values, N_obs, N_re ); %  weight design
        Aw = sparse(indx_I, indx_J, values, N_obs, N_re);  
        constrW = constr .* weights;
    %% start
        [ xBest, BestRSS, residualsBest ] = BackwardElimination( Aw, b );
        for i = 1:size(xBest, 2)
            xOri = zeros(N_reOri, 1);
            xOri(indxPos) = xBest(:, i) ./ weights;
            
            StatLassoLL(i).xOriginal = xOri;
            StatLassoLL(i).rss = BestRSS(i);
            StatLassoLL(i).r = residualsBest(i).*bStdEps;
            StatLassoLL(i).card = length(find(StatLassoLL(i).xOriginal));
        end
        RunTimeS = toc(ts);
        save(OutFileName, 'StatLassoLL', 'RunTimeS');
        FormatTime( RunTimeS, 'finished in ' );
%     else
%         load(OutFileName)
%     end
end

function [AIC, BIC, cPm] = ICfunc(ll, df, N, S)
    AIC = log(ll) + 2*df/N;
    BIC = log(ll) + log(N)*df/N;
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

