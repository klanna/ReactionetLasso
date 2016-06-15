function ReactionetLassoSS( ModelName, varargin )
    fpath = regexprep(pwd, 'ReactionetLasso/.*', 'ReactionetLasso/'); % path to the code-folder
    addpath(genpath(sprintf('%s/code/', fpath))); % add code directory to matlab path
    
    ModelParams = ReadInputParameters( varargin ); % identify default settings
    FolderNames = FolderNamesFun( ModelName, 0, ModelParams );
    FileNameOut = sprintf('%s/StabilitySelection', FolderNames.Plots);
    if ~exist(FolderNames.Plots, 'dir')
       mkdir(FolderNames.Plots) 
    end
    
    [xscore, ReNumList] = GetScore( FolderNames, ModelParams );
    [x, ScoreFunctionNameList, mse, AIC, BIC, card, RunTimeS, RunTimeSname] = StabilitySelection( FolderNames, ModelParams, ReNumList, xscore);
    
    PlotComputationTime( FolderNames.Results, ModelName, RunTimeS, RunTimeSname);
    
    M = [VertVect(mse) VertVect(AIC) VertVect(BIC)];
    ICplot( card, M, {'mse', 'AIC', 'BIC'}, FileNameOut);
    
    load(sprintf('%s/Topology.mat', FolderNames.Data));
    load(sprintf('%s/Data.mat', FolderNames.Data), 'SpeciesNames');
    [~, PriorGraph] = ReadConstraints( FolderNames, size(stoich, 2) );
    
    ResScore = zeros(size(stoich, 2), 1);
    ResScore(ReNumList) = xscore;
    
    for i = 1:length(ScoreFunctionNameList)
        SolName = sprintf('Opt_%s', ScoreFunctionNameList{i});
        xOpt = x(:, i);
        indxPos = find(xOpt);
        N_re = length(find(xOpt));
        fprintf('%s: card = %u\n', SolName, N_re);
        filename = sprintf('%s_%s', FileNameOut, SolName);
        PriorListIndx = [PriorGraph.indx];
        if ~isempty(PriorListIndx)
            for p = 1:lenght(PriorListIndx)
                PriorList(p) = find(indxPos == PriorListIndx(p));
            end
        else
            PriorList = [];
        end
        PrintGraphWithScore( filename, stoich(:, indxPos), SpeciesNames, [1:N_re], [], PriorList, ResScore(indxPos) );
    end

    if exist(sprintf('%s/TrueStruct.mat', FolderNames.Data), 'file')
		ReactionetLassoPlots( ModelName, varargin );
    end
end

