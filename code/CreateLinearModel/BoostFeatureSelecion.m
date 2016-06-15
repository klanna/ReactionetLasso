function [xb, RunTimeS, RunTimeSName] = BoostFeatureSelecion( FolderNames, E, V, C, E2, C3, E12, stoich, b, constr, bStdEps)
    RunTimeSName = 'BoostFeatureSelecion';
    OutFolder = sprintf('%s/', FolderNames.ResultsCV);
    OutFileName = sprintf('%s/%s.mat', OutFolder, RunTimeSName);
    
    [N_sp, N_T, Nboot] = size(E);
    ts = tic;
    N_re = size(stoich, 2);
    
    xboost = zeros(N_re, Nboot);
    
    if ~exist(OutFileName, 'file')
        for boot = 1:Nboot
            [indx_I, indx_J, values, N_obs, N_re] = PrepareDesign(FolderNames, squeeze(E(:, :, boot)), squeeze(V(:, :, boot)), squeeze(C(:, :, boot)), squeeze(E2(:, :, boot)), squeeze(C3(:, :, boot)), squeeze(E12(:, :, boot)), stoich);
            [ bNoiseNorm, bStdEps, valuesNoiseNorm ] = NoiseNormalization( bStdEps, b, indx_I, values);
            BestResStat = StepBoostingPool(FolderNames, indx_I, indx_J, valuesNoiseNorm, N_obs, N_re, bNoiseNorm, constr, N_T, N_sp, boot);
            xboost(:, boot) = BestResStat.xOriginal;
        end
        RunTimeS = toc(ts);
        FormatTime( RunTimeS, 'StepBoostingPool finished in ');

        xb = mean(xboost, 2);
        save(OutFileName, 'xb', 'xboost', 'RunTimeS');      
    else
        load(OutFileName);
    end
end
