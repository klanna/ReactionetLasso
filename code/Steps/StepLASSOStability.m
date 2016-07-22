function [xCorrect, RunTimeS, RunTimeSname] = StepLASSOStability( boot, FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, xW, lambda_list )
    ts = tic;
    RunTimeSname = sprintf('StepLASSOStability_boot%u', boot);
    fprintf('----------------%s----------------\n', RunTimeSname);
    OutFolder = sprintf('%s/Boot/', FolderNames.ResultsCV);
    if ~exist(OutFolder, 'dir')
        mkdir(OutFolder)
    end
    OutFileName = sprintf('%s/%s.mat', OutFolder, RunTimeSname);
    if ~exist(OutFileName, 'file')
    %% weight on error distribution
        [ values, xAW ] = AdaptationDesign( indx_J, values, xW ); %  adaptive method
        [ values, weights ] = WeightDesignForRegression( indx_I, indx_J, values, N_obs, N_re ); %  weight design
        Aw = sparse(indx_I, indx_J, values, N_obs, N_re);  
        constrW = (constr ./ xAW) .* weights;
    %% start
        x0 = LassoVpathCholBoot(Aw, b, weights, lambda_list, constrW);
        
        for i = 1:size(x0, 2)
            xCorrect(:, i) = x0(:, i) .* xAW ./ weights;
            StatLassoLL(i).xOriginal = xCorrect(:, i);        
        end
        RunTimeS = toc(ts);
        save(OutFileName, 'StatLassoLL', 'RunTimeS');
        FormatTime( RunTimeS, 'finished in ' );
    else
        load(OutFileName)
        xCorrect = [StatLassoLL.xOriginal];
    end
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

