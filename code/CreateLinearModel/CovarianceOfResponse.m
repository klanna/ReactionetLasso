function [bStdEps, RunTimeS, RunTimeSName] = CovarianceOfResponse( FolderNames, E, V, C, E2, C3, E12, stoich, b, bStd, kest)
    RunTimeSName = 'CovarianceOfResponse';
    OutFolderName = FolderNames.LinSystem;
    
    OutFileName = sprintf('%s/Covar.mat', OutFolderName);
    [N_sp, N_T, Nboot] = size(E);
    ts = tic;
   
    if ~exist(OutFileName, 'file')
        indxpos = find(kest);
        for boot = 1:Nboot
            [indx_I, indx_J, values, N_obs, N_re] = PrepareDesign(FolderNames, squeeze(E(:, :, boot)), squeeze(V(:, :, boot)), squeeze(C(:, :, boot)), squeeze(E2(:, :, boot)), squeeze(C3(:, :, boot)), squeeze(E12(:, :, boot)), stoich(:, indxpos));
            clearvars MeanPseudoProp CVxa 
            A = sparse(indx_I, indx_J, values, N_obs, N_re);
            rest(:, boot) = b - A*VertVect(kest(indxpos));
        end
        clear A values
        bStdEps = sqrt(var(rest, 0, 2) + bStd.^2);
        RunTimeS = toc(ts);
        save(OutFileName, 'rest', 'bStdEps', 'RunTimeS')   
    else
        load(OutFileName)
    end
    
    
end
