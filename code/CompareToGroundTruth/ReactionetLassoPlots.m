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
    load(sprintf('%s/ReactionFrequency.mat', FolderNames.Results))
    
    UniqueXscore = sort(unique(xscore), 'descend'); 
    NreUni = length(UniqueXscore);
        
    for i = 1:NreUni
        x0 = zeros(length(kTrue), 1);
        idx = find(xscore >= UniqueXscore(i));
        x0(ReNumList(idx)) = 1;
        FDRscore(i, :) = FDR(kTrue, x0);
    end
    
    A{2} = {FDRscore};
    titlename{2} = 'Reaction Frequency';
    LegendNames{2} = {};

    %%
    [~, PriorGraph] = ReadConstraints( FolderNames, stoich );
    
    load(sprintf('%s/StabilitySelection.mat', FolderNames.Results))
    for i = 1:size(x, 2)
        FDRscore(i, :) = FDR(kTrue, x(:, i));
    end
    
    for i = 1:length(ScoreFunctionNameList)
        FDRscoreOpt(i, :) = FDR(kTrue, xOpt(:, i));
    end
    
    A{3} = {FDRscore};
    titlename{3} = 'Stability Selection';
    LegendNames{3} = {};
    
    FileName = sprintf('%s/CVandStabilitySelection', FolderNames.Plots);
    FdrCVandFreq( A, titlename, LegendNames, FileName);
    
%     A{3} = BE;
%     titlename{3} = 'BE';
%     LegendNames{3} = {};
    
    
    ResScore0 = zeros(size(stoich, 2), 1);
    ResScore0(ReNumList) = xscore;
    
    indx_k = find(kTrue);
    
    ROCscore(:, 1) = FDRscore(:, 1) / length(indx_k);
    ROCscore(:, 2) = FDRscore(:, 2) ./ (size(stoich, 2) - (FDRscore(:, 1) + FDRscore(:, 2) ) );
    
    ROCscoreOpt = FDRscoreOpt;
    ROCscoreOpt(:, 1) = FDRscoreOpt(:, 1) / length(indx_k);
    ROCscoreOpt(:, 2) = FDRscoreOpt(:, 2) ./ (size(stoich, 2) - (FDRscoreOpt(:, 1) + FDRscoreOpt(:, 2) ));
    
    save(sprintf('%s/StabilitySelection.mat', FolderNames.Results), '-append', 'FDRscore', 'FDRscoreOpt', 'ROCscoreOpt', 'ROCscore')
    
    FileName = sprintf('%s/StabilitySelection_%s', FolderNames.Plots, ModelName);
    StabilitySelectionPlot( FDRscore, '', ScoreFunctionNameList, FileName, xOptIndx, FDRscoreOpt);
    
    FileName = sprintf('%s/ROC_%s', FolderNames.Plots, ModelName);
    ROCPlot( {ROCscore}, ModelName, FileName, {sprintf('%s %s, p = %.2f', ModelParams.Gradients, ModelParams.connect, ModelParams.p)});
    
    
    for i = 1:length(ScoreFunctionNameList)
        OptName = ScoreFunctionNameList{i};
        FName = sprintf('%s/%s_%s', FolderNames.Plots, OptName, ModelName);
        PlotScatterCons( kTrue, xOpt(:, i), '', FName, pic, PriorGraph.indx);
        PlotScatterCons_off( kTrue, xOpt(:, i), '', FName, pic, PriorGraph.indx);

        indxPos = find(xOpt(:, i));

        PriorListIndx = [PriorGraph.indx];
        if ~isempty(PriorListIndx)
            for p = 1:length(PriorListIndx)
                PriorList(p) = find(indxPos == PriorListIndx(p));
            end
        else
            PriorList = [];
        end

        [TPList, FPList, FNList] = FDRList(indx_k, xOpt(:, i));
        indxPos = sort([VertVect(TPList); VertVect(FPList); VertVect(FNList)]);
        
        BlockFile = sprintf('%s/Blocks.mat', FolderNames.Data);
        if exist(BlockFile)
            load(BlockFile)                
        else
            Blocks = ones(length(SpeciesNames), 1);
        end
        
        ResScore = zeros(size(stoich, 2), 1);
        ResScore(TPList) = ResScore0(TPList);
        ResScore(FPList) = ResScore0(FPList);
        ResScore(FNList) = min(xscore)/10;
        PrintGraphWithScore( FName, stoich, SpeciesNames, TPList, FPList, PriorList, ResScore, Blocks, FNList);

        clear FPList TPList PriorList
    end
    
    %% corner solutions
    [ idx ] = FindCornerSolutions( FDRscore );
    
    for i = 1:length(idx)
        OptName = sprintf('C%u', i);
        FName = sprintf('%s/%s_%s', FolderNames.Plots, OptName, ModelName);
        xO = x(:, idx(i));
        PlotScatterCons( kTrue, xO, OptName, FName, pic, PriorGraph.indx);

        indxPos = find(xO);

        PriorListIndx = [PriorGraph.indx];
        if ~isempty(PriorListIndx)
            for p = 1:length(PriorListIndx)
                PriorList(p) = find(indxPos == PriorListIndx(p));
            end
        else
            PriorList = [];
        end

        [TPList, FPList, FNList] = FDRList(indx_k, xO);
        indxPos = sort([VertVect(TPList); VertVect(FPList); VertVect(FNList)]);
        
        BlockFile = sprintf('%s/Blocks.mat', FolderNames.Data);
        if exist(BlockFile)
            load(BlockFile)                
        else
            Blocks = ones(length(SpeciesNames), 1);
        end
        
        ResScore = zeros(size(stoich, 2), 1);
        ResScore(TPList) = ResScore0(TPList);
        ResScore(FPList) = ResScore0(FPList);
        ResScore(FNList) = min(xscore)/10;
        PrintGraphWithScore( FName, stoich, SpeciesNames, TPList, FPList, PriorList, ResScore, Blocks, FNList);
%         
%         FileNameOut = sprintf('%s/ComputeODEfit_%s_%s%u_%s_%s_%s', FolderNames.Plots, ModelName, ModelParams.Gradients, 100*ModelParams.p, ModelParams.PriorTopology, ModelParams.Prior, OptName);
%         MakeSBMLfile( FileNameOut, stoich(:, indxPos), xO(indxPos), SpeciesNames, mE(:, 1));
%         %% function that performs simulation
%         [Simtime, Simdata] = SimulateModelSBML(FileNameOut, Timepoints, mE, StdE);
%         %% plot the simulation
%         ODEfitPlot( 'BestODEfit', FileNameOut, Simtime, Simdata, Timepoints, mE, StdE, SpeciesNames, 'on');
%         ODEfitPlot( 'BestODEfit', FileNameOut, Simtime, Simdata, Timepoints, mE, StdE, SpeciesNames, 'off');
    
        clear FPList TPList PriorList
    end
end

function [TPList, FPList, FNList] = FDRList(indx_k, x)
    indxPos = find(x); % idx of positive reactions
    
    FPList = setdiff(indxPos, indx_k);
    TPList = setdiff(indxPos, FPList);
    FNList = setdiff(indx_k, TPList);

end
