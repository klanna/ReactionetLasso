function [ E, V, C, E2, C3, E12, RunTimeS, RunTimeName ] = PrepareMoments( FolderNames, varargin )
%% Prepare moments on training set
    RunTimeName = 'PrepareMoments';
    fprintf('%s...\n', RunTimeName);
    
    
    OutFileName = sprintf('%s/TrainingSet_Nb%u_cv%u.mat', FolderNames.Data, FolderNames.Nboot, FolderNames.CV);
    if ~exist(OutFileName, 'file')
        for boot = 1:FolderNames.Nboot
            [ E(:, :, boot), V(:, :, boot), C(:, :, boot), E2(:, :, boot), C3(:, :, boot), E12(:, :, boot), RunTime(boot)] = PrepareMomentsBoot( boot, FolderNames.ModelName, FolderNames.CV, varargin );
        end
        
        RunTimeS = mean(RunTime);
        save(OutFileName, '-v7.3', 'E', 'V', 'C', 'E2', 'C3', 'E12', 'RunTimeS');
        FormatTime( RunTimeS, 'finished in ' );
        
    else
        OutFileNameVal = sprintf('%s/ValidationSet_cv%u.mat', FolderNames.Data, FolderNames.Nboot, FolderNames.CV);
        if ~exist(OutFileNameVal, 'file')
            boot = 1;
            [ E(:, :, boot), V(:, :, boot), C(:, :, boot), E2(:, :, boot), C3(:, :, boot), E12(:, :, boot), RunTime(boot)] = PrepareMomentsBoot( boot, FolderNames.ModelName, FolderNames.CV, varargin );
        end
        load(OutFileName) 
    end        
    
        %% correction
    
    [ E, V, C, E2, C3, E12 ] = CorrectMomentsForBinomialNoise( E, V, C, E2, C3, E12, FolderNames.p );

    if strcmp(FolderNames.MomentClosure, 'close0')
        C3 = zeros(size(C3));
    end

end

