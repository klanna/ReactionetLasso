function StepStabilitySelection( FolderNames, ModelParams, bNoiseNorm, bStdEps, E, V, C, E2, C3, E12, stoich, constr, xW, lambda_list, N_reOri, indxPos )
% Performs proper stability selection algorithm from Meinshausen
    ts = tic;
    RunTimeSname = 'StepStabilitySelection';
    fprintf('----------------%s----------------\n', RunTimeSname);
    
    OutFolder = sprintf('%s/', FolderNames.ResultsCV);
    OutFileName = sprintf('%s/%s.mat', OutFolder, RunTimeSname);
    
    pi_cut = 0.5;
    
    NLam = length(lambda_list);
    x = zeros(N_reOri, NLam, ModelParams.Nboot);
    
    for boot = 1:ModelParams.Nboot
        [indx_I, indx_J, values, N_obs, N_re] = PrepareDesign(FolderNames, squeeze(E(:, :, boot)), squeeze(V(:, :, boot)), squeeze(C(:, :, boot)), squeeze(E2(:, :, boot)), squeeze(C3(:, :, boot)), squeeze(E12(:, :, boot)), stoich);
        valuesNoiseNorm = WeightSparseMatrix( indx_I, values, 1 ./ bStdEps);
        [x(indxPos, :, boot)] = StepLASSOStability(boot, FolderNames, indx_I, indx_J, valuesNoiseNorm, N_obs, N_re, bNoiseNorm, constr, xW, lambda_list);
    end
    
    FreqXboot = x;
    FreqXboot(find(FreqXboot)) = 1;
    FreqX = mean(FreqXboot, 3);
    FreqX(find(FreqX < pi_cut)) = 0;
    
    RunTimeS = toc(ts);
    save(OutFileName, 'FreqX', 'RunTimeS');
    FormatTime( RunTimeS, 'finished in ' );
end

