function [ Eb, Vb, Cb, E2b, C3b, E12b, RunTimeS ] = PrepareMomentsBoot( boot, ModelName, nset, varargin )
% PrepareMoments( 'ARS', 100, 'DT', 1, 1 )
    RunTimeName = 'PrepareMomentsBoot';
    fprintf('%s (CV = %u) boot = %u...\n', RunTimeName, nset, boot);
    
    fpath = regexprep(pwd, 'ReactionetLasso/.*', 'ReactionetLasso/'); % path to the code-folder
    addpath(genpath(sprintf('%s/code/', fpath))); % add code directory to matlab path
    
    ModelParams = ReadInputParameters( varargin ); % identify default settings
    FolderNames = FolderNamesFun( ModelName, nset, ModelParams );
    
    [dataTR, dataVal, Timepoints] = ReadTrajectories( FolderNames );

    OutFolder = sprintf('%s/Bootstrap/', FolderNames.Moments);
    if ~exist(OutFolder, 'dir')
       mkdir(OutFolder); 
    end
    
    OutFileName = sprintf('%s/Boot_%u.mat', OutFolder, boot);    
    OutFileNameVal = sprintf('%s/ValidationSet_cv%u.mat', FolderNames.Data, nset);
    
    if ~exist(FolderNames.Moments, 'dir')
        mkdir(FolderNames.Moments)
    end
    % LOAD DATA
    
    ts = tic;
    if boot == 1
        for t = 1:length(Timepoints)
            Trajectories = dataVal{t};
            [ E(:, t), V(:, t), C(:, t), E2(:, t), C3(:, t), E12(:, t) ] = PrepareMomentsFromTrajectories( Trajectories, boot );
        end
        RunTimeS = toc(ts);
        save(OutFileNameVal, 'E', 'V', 'C', 'E2', 'C3', 'E12', 'RunTimeS');
    end
        
    if ~exist(OutFileName, 'file')        
        ts = tic;
        for t = 1:length(Timepoints)
            Trajectories = dataTR{t};
            [ Eb(:, t), Vb(:, t), Cb(:, t), E2b(:, t), C3b(:, t), E12b(:, t) ] = PrepareMomentsFromTrajectories( Trajectories, boot );
        end
        RunTimeS = toc(ts);
        save(OutFileName, '-v7.3', 'Eb', 'Vb', 'Cb', 'E2b', 'C3b', 'E12b', 'RunTimeS');
        FormatTime( RunTimeS, 'PrepareMomentsBoot finished in ' );
    else
        load(OutFileName) 
    end      
    
end

