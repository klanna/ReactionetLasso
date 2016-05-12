function TopologicalFiltering(ModelName, varargin)
    fpath = regexprep(pwd, 'ReactionetLasso/.*', 'ReactionetLasso/'); % path to the code-folder
    addpath(genpath(sprintf('%s/code/', fpath))); % add code directory to matlab path
    
    ModelParams = ReadInputParameters( varargin );
    FolderNames = FolderNamesFun( ModelName, 0, ModelParams );
    
    RunTimeSname = 'TopologicalFiltering';
    fprintf('----------------TopologicalFiltering----------------\n');
    OutFolder = sprintf('%s/TopologicalFiltering/', FolderNames.Results);
    
    if ~exist(OutFolder, 'dir')
       mkdir(OutFolder) 
    end
    
    OutFileName = sprintf('%s/%s.mat', OutFolder, RunTimeSname);
    ts = tic;
    
    load(sprintf('%s/Topology.mat', FolderNames.Data));
    load(sprintf('%s/Data.mat', FolderNames.Data), 'Timepoints', 'SpeciesNames')
    
    [ E, V, C, E2, C3, E12 ] = PrepareMomentsFull( FolderNames );
    [b, bStd] = PrepareResponse( FolderNames, E, V, C, Timepoints);        
    [indx_I, indx_J, values, N_obs, N_re] = PrepareDesign(FolderNames, E, V, C, E2, C3, E12, stoich, 0);

    
    N_sp = size(stoich, 1);
    N_T = length(Timepoints);
    
    if FolderNames.NMom == 2
        [indx_I, indx_J, values, N_obs, N_re, EmptyIndx, NonEmptyIndx] = CutDesignRows(indx_I, indx_J, values, N_obs, N_re, N_sp, N_T);         
    else
        NonEmptyIndx = find(WeightsMask( N_sp, N_T, length(b), [1 0 0], 2 ));
    end
    b(EmptyIndx) = [];
%% weigth matrix
    [ values, weights ] = WeightDesignForRegression( indx_I, indx_J, values, N_obs, N_re );
    Aw = sparse(indx_I, indx_J, values, N_obs, N_re);

    [ x, mse, card, Ctime ] = BackwardsSelection( Aw, b, weights );

    BIC = length(b)*log(mse) + log(length(b))*card;
    AIC = length(b)*log(mse) + 2*card;

    ScoreFunctionNameList = {'mse', 'AIC', 'BIC'};
    for i = 1:length(ScoreFunctionNameList)
        fprintf('%s optimal: \t', ScoreFunctionNameList{i});
        [xOpt(:, i), xOptIndx(i)] = OptimalSolution(x, eval(ScoreFunctionNameList{i}));
    end

    RunTimeS = toc(ts);
    save(OutFileName, 'mse', 'x', 'Ctime', 'x', 'BIC', 'AIC', 'xOpt', 'xOptIndx');      

    FormatTime( RunTimeS, 'TopologicalFiltering finished in ' );

    if ~exist(FolderNames.PlotsCV, 'dir')
        mkdir(FolderNames.PlotsCV)
    end
    
    load(sprintf('%s/Data.mat', FolderNames.Data), 'SpeciesNames');
    
    for i = 1:length(ScoreFunctionNameList)
        SolName = sprintf('Opt_%s', ScoreFunctionNameList{i});
        filename = sprintf('%s/%s_%s', OutFolder, RunTimeSname, SolName);
        
        indxPos = find(xOpt(:, i));

        PrintGraphWithScore( filename, stoich(:, indxPos), SpeciesNames, [1:length(indxPos)], [], [], ones(length(indxPos),1) );
    end
end

function [xOpt, imin] = OptimalSolution(x, ScoreFunction)  
    [~, imin] = min(ScoreFunction);
    xOpt = x(:, imin);
    fprintf('%u reactions\n', length(find(xOpt)));
end
