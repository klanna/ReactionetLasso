function ReactionetLassoResultPlots( ModelName, varargin )
% Main procedure
    ts = tic; % start time
    fpath = regexprep(pwd, 'ReactionetLasso/.*', 'ReactionetLasso/'); % path to the code-folder
    addpath(genpath(sprintf('%s/code/', fpath))); % add code directory to matlab path
    
    ModelParams = ReadInputParameters( varargin ); % identify default settings
    
    pic = 'off';
    Ncv = 5;
    A = {};
    titlename{1} = 'Cross Validation';
    LegendNames{1} = {};
    for nset = 1:Ncv
        FolderNames = FolderNamesFun( ModelName, nset, ModelParams );

        load(sprintf('%s/Topology.mat', FolderNames.Data))
        load(sprintf('%s/TrueStruct.mat', FolderNames.Data))
        load(sprintf('%s/Data.mat', FolderNames.Data), 'Timepoints', 'SpeciesNames')
        load(sprintf('%s/Response.mat', FolderNames.LinSystem))
        
        N_T = length(Timepoints)-1;
        N_sp = length(SpeciesNames);
        kTrue = AnnotateTrueReactions( k, stoichTR, stoich );
        
        StepName = 'StepLASSO';
        FName = sprintf('%s/%s', FolderNames.ResultsCV, StepName);
        load(sprintf('%s.mat', FName));    
        for i = 1:length([StatLassoLL])
            FDRscore(i, :) = FDR(kTrue, StatLassoLL(i).xOriginal);
        end
        AA{nset} = FDRscore;
        clear FDRscore
    end
    A{1} = AA;
%     
    [~, PriorGraph] = ReadConstraints( FolderNames, size(stoich, 2) );
    
    load(sprintf('%s/StabilitySelection.mat', FolderNames.Results))
    for i = 1:size(x, 2)
        FDRscore(i, :) = FDR(kTrue, x(:, i));
    end
    A{2} = {FDRscore};
    titlename{2} = 'Stability Selection';
    LegendNames{2} = {};
    
    FileName = sprintf('%s/CVandStabilitySelection', FolderNames.Plots);
    CompareTrueFalsePos( A, titlename, LegendNames, FileName);
    
    load(sprintf('%s/ReactionFrequency.mat', FolderNames.Results));
    
    ResScore = zeros(size(stoich, 2), 1);
    ResScore(ReNumList) = xscore;
    
    FileName = sprintf('%s/StabilitySelection_%s', FolderNames.Plots, ModelName);
    StabilitySelectionPlot( FDRscore, sort(ResScore, 'descend'), '', ScoreFunctionNameList(2:end), FileName, xOptIndx(2:end));
    
    for i = 2:length(ScoreFunctionNameList)
        OptName = ScoreFunctionNameList{i};
        FName = sprintf('%s/%s_%s', FolderNames.Plots, OptName, ModelName);
        PlotScatterCons( kTrue, xOpt(:, i), OptName, FName, pic, PriorGraph.indx);
        [ indxPos, TPList, FPList, PriorList ] = FDRgraph( xOpt(:, i), kTrue, PriorGraph.indx);
        
        PrintGraphWithScore( FName, stoich(:, indxPos), SpeciesNames, TPList, FPList, PriorList, ResScore(indxPos) );
        
        clear FPList TPList PriorList
    end
end

