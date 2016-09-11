function [b, bStd, RunTimeS, RunTimeSname] = PrepareResponse( FolderNames, E, V, C, Timepoints)   
    RunTimeSname = 'PrepareResponse';
    
    if ~exist(FolderNames.LinSystem, 'dir')
        mkdir(FolderNames.LinSystem)
    end

    OutFileName = sprintf('%s/Response.mat', FolderNames.LinSystem);
    
    if ~exist(OutFileName, 'file')
        ts = tic;
        fprintf('%s %s...\t', RunTimeSname, FolderNames.ModelName);
        
        if strcmp( FolderNames.Gradients, 'FDS')
            for Sample = 1:size(E, 3)
                if FolderNames.NMom == 2
                    dMom_sm = GradientsFD([squeeze(E(:, : , Sample)); squeeze(V(:, : , Sample)); squeeze(C(:, : , Sample))], Timepoints);
                else
                    dMom_sm = GradientsFD(squeeze(E(:, : , Sample)), Timepoints);
                end
                bBoot(:, Sample) = reshape(dMom_sm, [], 1);
            end
        else 
            for Sample = 1:size(E, 3)
                if FolderNames.NMom == 2
                    dMom_sm = GradientsSplines([squeeze(E(:, : , Sample)); squeeze(V(:, : , Sample)); squeeze(C(:, : , Sample))], Timepoints, FolderNames.Gradients);
                else
                    dMom_sm = GradientsSplines(squeeze(E(:, : , Sample)), Timepoints, FolderNames.Gradients);
                end
                bBoot(:, Sample) = reshape(dMom_sm, [], 1);
            end
        end    
        b = bBoot(:, 1);
        
        if strcmp( FolderNames.Gradients, 'adaptive')
            FolderName = strrep(FolderName, 'adaptive', 'splines2');
            load(sprintf('%s/BestResponse.mat', FolderName), 'b')
        end
        
        %% prepare response    
        bStd = std(bBoot, 0, 2);
        RunTimeS = toc(ts);
        save(OutFileName, 'b', 'bBoot', 'bStd', 'RunTimeS')
        FormatTime( RunTimeS, ' finished in ' );
    else
        load(OutFileName)
    end
end