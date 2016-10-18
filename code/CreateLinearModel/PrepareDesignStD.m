function [indx_I, indx_J, values, N_obs, N_re, valuesStD, RunTimeS, RunTimeSname] = PrepareDesignStD( FolderNames, E, V, C, E2, C3, E12, stoich)
    RunTimeSname = 'PrepareDesignStD';
    Fname = sprintf('%s/DesignStD.mat', FolderNames.LinSystem);
    if ~exist(Fname, 'file')
        for boot = 1:size(E, 3)
            [indx_I, indx_J, values, N_obs, N_re, RunTimeS] = PrepareDesign(FolderNames, squeeze(E(:, :, boot)), squeeze(V(:, :, boot)), squeeze(C(:, :, boot)), squeeze(E2(:, :, boot)), squeeze(C3(:, :, boot)), squeeze(E12(:, :, boot)), stoich, 0);
            valuesBoot(:, boot) = values;        
        end
        valuesStD = std(valuesBoot, 0, 2);
        values = mean(valuesBoot, 2); 
        save(Fname, 'valuesStD', 'valuesBoot', 'indx_I', 'indx_J', 'values', 'N_obs', 'N_re')
    else
        load(Fname)
    end
    
end

