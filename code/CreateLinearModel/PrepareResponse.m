function [b, bStd, RunTimeS, RunTimeSname] = PrepareResponse( FolderNames, E, V, C, Timepoints)   
    RunTimeSname = 'PrepareResponse';
    
    if ~exist(FolderNames.LinSystem, 'dir')
        mkdir(FolderNames.LinSystem)
    end

    OutFileName = sprintf('%s/Response.mat', FolderNames.LinSystem);
    
    if ~exist(OutFileName, 'file')
        ts = tic;
        fprintf('%s %s...\t', RunTimeSname, FolderNames.ModelName);
        
        switch FolderNames.Gradients
            case 'FDS'
                for Sample = 1:size(E, 3)
                    if FolderNames.NMom == 2
                        dMom_sm = GradientsFD([squeeze(E(:, : , Sample)); squeeze(V(:, : , Sample)); squeeze(C(:, : , Sample))], Timepoints);
                    else
                        dMom_sm = GradientsFD(squeeze(E(:, : , Sample)), Timepoints);
                    end
                    bBoot(:, Sample) = reshape(dMom_sm, [], 1);
                end
            case 'splines'
                for Sample = 1:size(E, 3)
                    if FolderNames.NMom == 2
                        dMom_sm = GradientsSplines([squeeze(E(:, : , Sample)); squeeze(V(:, : , Sample)); squeeze(C(:, : , Sample))], Timepoints);
                    else
                        dMom_sm = GradientsSplines(squeeze(E(:, : , Sample)), Timepoints);
                    end
                    bBoot(:, Sample) = reshape(dMom_sm, [], 1);
                end
        end    
        b = bBoot(:, 1);
        %% prepare response    
        bStd = std(bBoot, 0, 2);
        RunTimeS = toc(ts);
        save(OutFileName, 'b', 'bBoot', 'bStd', 'RunTimeS')
        FormatTime( RunTimeS, ' finished in ' );
    else
        load(OutFileName)
    end
end