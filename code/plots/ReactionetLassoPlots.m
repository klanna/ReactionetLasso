function ReactionetLassoPlots( ModelName, varargin )
% Main procedure
    ts = tic; % start time
    fpath = regexprep(pwd, 'ReactionetLasso/.*', 'ReactionetLasso/'); % path to the code-folder
    addpath(genpath(sprintf('%s/code/', fpath))); % add code directory to matlab path
    
    ModelParams = ReadInputParameters( varargin ); % identify default settings
    
    Ncv = 5;
    A = {};
    titlename{1} = 'Cross Validation';
    LegendNames{1} = {};
    for nset = 1:Ncv
        FolderNames = FolderNamesFun( ModelName, nset, ModelParams );

        load(sprintf('%s/Topology.mat', FolderNames.Data))
        load(sprintf('%s/TrueStruct.mat', FolderNames.Data))
        kTrue = AnnotateTrueReactions( k, stoichTR, stoich );

        StepName = 'StepOLS';
        FName = sprintf('%s/%s', FolderNames.ResultsCV, StepName);
        load(sprintf('%s.mat', FName));    
        FName = sprintf('%s/%s', FolderNames.PlotsCV, StepName);
        PlotScatterCons( kTrue, BestResStat.xOriginal, StepName, FName, 'on');

        StepName = 'StepFG';
        FName = sprintf('%s/%s', FolderNames.ResultsCV, StepName);
        load(sprintf('%s.mat', FName));    
        FName = sprintf('%s/%s', FolderNames.PlotsCV, StepName);
        PlotScatterCons( kTrue, BestResStat.xOriginal, StepName, FName, 'on');

        StepName = 'StepLASSO';
        FName = sprintf('%s/%s', FolderNames.ResultsCV, StepName);
        load(sprintf('%s.mat', FName));
        FName = sprintf('%s/%s', FolderNames.PlotsCV, StepName);  
        for i = 1:length([StatLassoLL])
            FDRscore(i, :) = FDR(kTrue, StatLassoLL(i).xOriginal);
        end
        A{nset, 1} = FDRscore;
        clear FDRscore
    end
    
    load(sprintf('%s/StabilitySelection.mat', FolderNames.Results))
    for i = 1:size(x, 2)
        FDRscore(i, :) = FDR(kTrue, x(:, i));
    end
    A{1, 2} = FDRscore;
    titlename{1} = 'Stability Selection';
    
    FileName = sprintf('%s/StabilitySelection', FolderNames.Plots);
    CompareTrueFalsePos( A, titlename, LegendNames, FileName);
end

