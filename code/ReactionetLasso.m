function ReactionetLasso( ModelName, nset, varargin )
% Main procedure
    ts = tic; % start time
    fpath = regexprep(pwd, 'ReactionetLasso/.*', 'ReactionetLasso/'); % path to the code-folder
    addpath(genpath(sprintf('%s/code/', fpath))); % add code directory to matlab path
    
    ModelParams = ReadInputParameters( varargin ); % identify default settings
    
    FolderNames = FolderNamesFun( ModelName, nset, ModelParams );
    
    RunTimeSname = {};
    RunTimeS = [];
    
    ReactionetLassoFile = sprintf('%s/Step_LASSO.mat', FolderNames.ResultsCV);
    
%     if ~exist(ReactionetLassoFile, 'file')
        load(sprintf('%s/Data.mat', FolderNames.Data), 'Timepoints', 'SpeciesNames')
        
        [stoich, RunTimeS(end+1), RunTimeSname{end+1} ] = PrepareTopology( FolderNames );        
        [ E, V, C, E2, C3, E12, RunTimeS(end+1), RunTimeSname{end+1} ] = PrepareMoments( FolderNames, varargin );
        
        N_T = size(E, 2)-1;
        N_sp = size(stoich, 1);
        
        [b, bStd, RunTimeS(end+1), RunTimeSname{end+1} ] = PrepareResponse( FolderNames, E, V, C, Timepoints);        
        [indx_I, indx_J, values, N_obs, N_re, RunTimeS(end+1), RunTimeSname{end+1}] = PrepareDesign(FolderNames, squeeze(E(:, :, 1)), squeeze(V(:, :, 1)), squeeze(C(:, :, 1)), squeeze(E2(:, :, 1)), squeeze(C3(:, :, 1)), squeeze(E12(:, :, 1)), stoich, 1);
        
        [constr, PriorGraph] = ReadConstraints( FolderNames, stoich ); % Model Augmentation
        %% OLS step (step zero)
%         [indxPos, b] = StepOLStakeOneSpecieOut(FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, N_T, N_sp);
        [BestResStat, RunTimeS(end+1), RunTimeSname{end+1}] = StepOLS(FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, N_T, N_sp, 1:N_re);  
        
        %% Prepare covariance matrix
        [bStdEps, RunTimeS(end+1), RunTimeSname{end+1}] = CovarianceOfResponse( FolderNames, E, V, C, E2, C3, E12, stoich, b, bStd, BestResStat.xOriginal); % Prepare Covariance Matrix
        
%         [xb, RunTimeS, RunTimeSName] = BoostFeatureSelecion( FolderNames, E, V, C, E2, C3, E12, stoich, b, constr, bStdEps);
        %% normalize linear system on covariance
        [ bNoiseNorm, bStdEps, valuesNoiseNorm ] = NoiseNormalization( bStdEps, b, indx_I, values);    %  b-cov weightening
        
        %% Feasible Generalized Least Squares Step
%         [xb, RunTimeS, RunTimeSName] = BoostFeatureSelecion( FolderNames, E, V, C, E2, C3, E12, stoich, b, constr);
        [BestResStat, RunTimeS(end+1), RunTimeSname{end+1}] = StepFG( FolderNames, indx_I, indx_J, valuesNoiseNorm, N_obs, N_re, bNoiseNorm, bStdEps, constr, 1:N_re);        
        
        xW = BestResStat.xOriginal;
        %% Adaptive Relaxed Lasso Step 
%         [StatLassoLL, RunTimeS(end+1), RunTimeSname{end+1}] = StepLASSO( FolderNames, indx_I, indx_J, valuesNoiseNorm, N_obs, N_re, N_sp, bNoiseNorm, bStdEps, constr, BestResStat, PriorGraph.indx);
        if strcmp(FolderNames.connect, 'connected') 
            [ BestResStat.xOriginal ] = CheckConnected( stoich, BestResStat.xOriginal );
        end
        
        [StatLassoLL, RunTimeS(end+1), RunTimeSname{end+1}] = StepLASSO( FolderNames, indx_I, indx_J, valuesNoiseNorm, N_obs, N_re, N_sp, bNoiseNorm, bStdEps, constr, BestResStat, PriorGraph.indx);
%         [StatLassoLL, RunTimeS(end+1), RunTimeSname{end+1}] = StepBackwardElimination( FolderNames, indx_I, indx_J, values, N_obs, N_re, N_sp, b, ones(size(bStdEps)), constr, BestResStat, PriorGraph.indx, N_T);
        
        indxPos = find(xW);
        lambdalist = SelectLambdaList(StatLassoLL);
%         StepStabilitySelection( FolderNames, ModelParams, bNoiseNorm, bStdEps, E, V, C, E2, C3, E12, stoich(:, indxPos), constr(indxPos), xW(indxPos), lambdalist, N_re, indxPos );
        
        PlotComputationTime( FolderNames.ResultsCV, ModelName, RunTimeS, RunTimeSname);
%     end
    FormatTime( toc(ts), 'Total RunTime: ' );
end

function lambdalist = SelectLambdaList(StatLassoLL)
    lambdalist = [];
    idxOld = [];
    Nlam = length(StatLassoLL);
    for i = 1:Nlam
        lam = StatLassoLL(i).lambda;
        x = StatLassoLL(i).xOriginal;
        idx = find(x);
        if ~isequal(idx, idxOld)
            lambdalist = [lambdalist lam];
            idxOld = idx;
        end
    end
end
