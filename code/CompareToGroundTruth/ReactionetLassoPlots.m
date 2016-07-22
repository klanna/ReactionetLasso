function FDRscore = ReactionetLassoPlots( PlotType, ModelName, varargin )
% Main procedure PlotType = 'CV' | 'all' | 'FDR'
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

        load(sprintf('%s/%s.mat', FolderNames.Data, FolderNames.PriorTopology))
        load(sprintf('%s/TrueStruct.mat', FolderNames.Data))
        load(sprintf('%s/Data.mat', FolderNames.Data), 'Timepoints', 'SpeciesNames')
        load(sprintf('%s/Response.mat', FolderNames.LinSystem))
        
        N_T = length(Timepoints)-1;
        N_sp = length(SpeciesNames);
        kTrue = AnnotateTrueReactions( k, stoichTR, stoich );

%         StepName = 'BoostFeatureSelecion';
%         FName = sprintf('%s/%s', FolderNames.ResultsCV, StepName);
%         load(sprintf('%s.mat', FName));    
%         xb = mean(sign(xboost), 2);
%         PlotScatterCons( sign(kTrue), xb, StepName, sprintf('%s/%s', FolderNames.PlotsCV, StepName), pic);
        if strcmp(PlotType, 'all')
            StepName = 'StepOLS';
            FName = sprintf('%s/%s', FolderNames.ResultsCV, StepName);
            load(sprintf('%s.mat', FName));    
            PlotScatterCons( kTrue, BestResStat.xOriginal, StepName, sprintf('%s/%s', FolderNames.PlotsCV, StepName), pic);
            PlotFitToLinearSystem( FolderNames.NMom, b, BestResStat.b_hat, N_T, N_sp, sprintf('%s/%s', FolderNames.PlotsCV, StepName), pic);

            StepName = 'StepFG';
            FName = sprintf('%s/%s', FolderNames.ResultsCV, StepName);
            load(sprintf('%s.mat', FName));    
            PlotScatterCons( kTrue, BestResStat.xOriginal, StepName, sprintf('%s/%s', FolderNames.PlotsCV, StepName), pic);
            PlotFitToLinearSystem( FolderNames.NMom, b, BestResStat.b_hat, N_T, N_sp, sprintf('%s/%s', FolderNames.PlotsCV, StepName), pic);
        end
        
        StepName = 'StepLASSO';
        FName = sprintf('%s/%s', FolderNames.ResultsCV, StepName);
        load(sprintf('%s.mat', FName));    
        for i = 1:length([StatLassoLL])
            FDRscore(i, :) = FDR(kTrue, StatLassoLL(i).xOriginal);
        end
        AA{nset} = FDRscore;
        clear FDRscore
        
%         StepName = 'StepBackwardElimination';
%         FName = sprintf('%s/%s', FolderNames.ResultsCV, StepName);
%         load(sprintf('%s.mat', FName));    
%         for i = 1:length([StatLassoLL])
%             FDRscoreBE(i, :) = FDR(kTrue, StatLassoLL(i).xOriginal);
%         end
%         BE{nset} = FDRscoreBE;
%         clear FDRscore
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
    
%     A{3} = BE;
%     titlename{3} = 'BE';
%     LegendNames{3} = {};
    
    FileName = sprintf('%s/CVandStabilitySelection', FolderNames.Plots);
    CompareTrueFalsePos( A, titlename, LegendNames, FileName);
    
    load(sprintf('%s/ReactionFrequency.mat', FolderNames.Results));
    
    ResScore = zeros(size(stoich, 2), 1);
    ResScore(ReNumList) = xscore;
    
    indx_k = find(kTrue);
    
    save(sprintf('%s/StabilitySelection.mat', FolderNames.Results), '-append', 'FDRscore')
    
    FileName = sprintf('%s/StabilitySelection_%s', FolderNames.Plots, ModelName);
    StabilitySelectionPlot( FDRscore, '', ScoreFunctionNameList, FileName, xOptIndx);
    
    if strcmp(PlotType, 'all')
        for i = 1:length(ScoreFunctionNameList)
            OptName = ScoreFunctionNameList{i};
            FName = sprintf('%s/%s_%s', FolderNames.Plots, OptName, ModelName);
            PlotScatterCons( kTrue, xOpt(:, i), OptName, FName, pic, PriorGraph.indx);

            indxPos = find(xOpt(:, i));

            PriorListIndx = [PriorGraph.indx];
            if ~isempty(PriorListIndx)
                for p = 1:lenght(PriorListIndx)
                    PriorList(p) = find(indxPos == PriorListIndx(p));
                end
            else
                PriorList = [];
            end

            FPList = [];
            FPList0 = setdiff(indxPos, indx_k);
            for j = 1:length(FPList0)
                FPList(j) = find(indxPos == FPList0(j));
            end

            TPList = [];
            TPList0 = setdiff(indxPos, FPList0);
            for j = 1:length(TPList0)
                TPList(j) = find(indxPos == TPList0(j));
            end

            PrintGraphWithScore( FName, stoich(:, indxPos), SpeciesNames, TPList, FPList, PriorList, ResScore(indxPos) );

            clear FPList TPList PriorList
        end
    end
end

