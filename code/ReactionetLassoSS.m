function ReactionetLassoSS( ModelName, varargin )
    fprintf('ReactionetLassoSS\n');
    fpath = regexprep(pwd, 'ReactionetLasso/.*', 'ReactionetLasso/'); % path to the code-folder
    addpath(genpath(sprintf('%s/code/', fpath))); % add code directory to matlab path
    
    ModelParams = ReadInputParameters( varargin ); % identify default settings
    FolderNames = FolderNamesFun( ModelName, 0, ModelParams );
%     FileNameOut = sprintf('%s/StabilitySelection_%s_%s%u_%s_%s', FolderNames.Plots, ModelName, ModelParams.Gradients, 100*ModelParams.p, ModelParams.PriorTopology, ModelParams.Prior);
    FileNameOut = sprintf('%s/StabilitySelection', FolderNames.Plots);
    if ~exist(FolderNames.Plots, 'dir')
       mkdir(FolderNames.Plots) 
    end
    % addpath(genpath(sprintf('%s/fdaM/', fpath)));
    
    [xscore, ReNumList] = GetScore( FolderNames, ModelParams );
%     [xscore, ReNumList] = GetScoreSS( FolderNames, ModelParams );
    
    [x, b_hat, ScoreFunctionNameList, mse, AIC, BIC, card, RunTimeS, RunTimeSname] = StabilitySelection2( FolderNames, ModelParams, ReNumList, xscore);
    
    PlotComputationTime( FolderNames.Results, ModelName, RunTimeS, RunTimeSname);
    
    M = [VertVect(mse) VertVect(AIC) VertVect(BIC)];
    
    ICplot( card, M, {'mse', 'AIC', 'BIC'}, FileNameOut);
    
    load(sprintf('%s/%s.mat', FolderNames.Data, FolderNames.PriorTopology));
    load(sprintf('%s/Data.mat', FolderNames.Data), 'SpeciesNames');
    
    [~, PriorGraph] = ReadConstraints( FolderNames, stoich);
    
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
            for p = 1:length(PriorListIndx)
                PriorList(p) = find(indxPos == PriorListIndx(p));
            end
        else
            PriorList = [];
        end
        
        if exist(sprintf('%s/Blocks.mat', FolderNames.Data), 'file')
            load(sprintf('%s/Blocks.mat', FolderNames.Data));
        else
            Blocks = ones(length(SpeciesNames), 1);
        end
        PrintGraphWithScore( filename, stoich(:, indxPos), SpeciesNames, [1:N_re], [], PriorList, ResScore(indxPos), Blocks, []);
    end
    
    SimulateODEfit( ModelName, varargin );
    
    try
        ComputeODEfit( ModelName, varargin );
    catch
    end
    
    if exist(sprintf('%s/TrueStruct.mat', FolderNames.Data), 'file')
		ReactionetLassoPlots( 'all', ModelName, varargin );
    end
end

