function ReactionetLasso( ModelName, nset, varargin )
    fprintf('ReactionetLasso cv = %u\n', nset);
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
        
        if strcmp(FolderNames.PriorTopology, 'PriorTopologyFG') || strcmp(FolderNames.PriorTopology, 'PriorTopologyODE')
            CreatePriorTopology( ModelName, ModelParams );
        end
            
        [stoich, RunTimeS(end+1), RunTimeSname{end+1} ] = PrepareTopology( FolderNames );        
        [ E, V, C, E2, C3, E12, RunTimeS(end+1), RunTimeSname{end+1} ] = PrepareMoments( FolderNames, varargin );
        
        N_T = size(E, 2)-1;
        N_sp = size(stoich, 1);
        
%         [indx_I, indx_J, values, N_obs, N_re, valuesStD] = PrepareDesignStD( FolderNames, E, V, C, E2, C3, E12, stoich);
        [indx_I, indx_J, values, N_obs, N_re, RunTimeS(end+1), RunTimeSname{end+1}] = PrepareDesign(FolderNames, squeeze(E(:, :, 1)), squeeze(V(:, :, 1)), squeeze(C(:, :, 1)), squeeze(E2(:, :, 1)), squeeze(C3(:, :, 1)), squeeze(E12(:, :, 1)), stoich, 1);
        [b, bStd, RunTimeS(end+1), RunTimeSname{end+1} ] = PrepareResponse( FolderNames, E, V, C, Timepoints);
        [constr, PriorGraph] = ReadConstraints( FolderNames, stoich ); % Model Augmentation
        %%
        try
            load(sprintf('%s/TrueStruct.mat', FolderNames.Data))
            kTrue = VertVect(AnnotateTrueReactions( k, stoichTR, stoich ));
        catch
            kTrue = zeros(N_re, 1);
        end
        %% OLS step (step zero)
%         [indxPos, b] = StepOLStakeOneSpecieOut(FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, N_T, N_sp);
        [BestResStat, RunTimeS(end+1), RunTimeSname{end+1}] = StepOLS(FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, N_T, N_sp, kTrue, 1:N_re);
        [bStdEps, RunTimeS(end+1), RunTimeSname{end+1}] = CovarianceOfResponse( FolderNames, E, V, C, E2, C3, E12, stoich, b, bStd, BestResStat.xOriginal);
        [ bNoiseNorm, bStdEps, valuesNoiseNorm ] = NoiseNormalization( bStdEps, b, indx_I, values);
        [BestResStat, RunTimeS(end+1), RunTimeSname{end+1}] = StepFG( FolderNames, indx_I, indx_J, valuesNoiseNorm, N_obs, N_re, bNoiseNorm, bStdEps, constr, 1:N_re, stoich, kTrue, N_T);
        
        if strcmp( FolderNames.Gradients, 'ramsayFG')
            RamsayMse(1) = sum(b.^2) / N_obs + 1;
            RamsayMse(2) = BestResStat.mse / N_obs;
            i = 2;
            % addpath(genpath(sprintf('%s/fdaM/', fpath)));
            while RamsayMse(i-1) < RamsayMse(i)
                i = i+1;
                [b, bStd, RunTimeS(end+1), RunTimeSname{end+1} ] = PrepareResponse( FolderNames, E, V, C, Timepoints, BestResStat.b_hat);
                [BestResStat, RunTimeS(end+1), RunTimeSname{end+1}] = StepOLS(FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, N_T, N_sp, 1:N_re);

                % Prepare covariance matrix
                [bStdEps, RunTimeS(end+1), RunTimeSname{end+1}] = CovarianceOfResponse( FolderNames, E, V, C, E2, C3, E12, stoich, b, bStd, BestResStat.xOriginal); % Prepare Covariance Matrix

                % normalize linear system on covariance
                [ bNoiseNorm, bStdEps, valuesNoiseNorm ] = NoiseNormalization( bStdEps, b, indx_I, values);    %  b-cov weightening

                % Feasible Generalized Least Squares Step
                [BestResStat, RunTimeS(end+1), RunTimeSname{end+1}] = StepFG( FolderNames, indx_I, indx_J, valuesNoiseNorm, N_obs, N_re, bNoiseNorm, bStdEps, constr, 1:N_re, stoich, kTrue, N_T);        
                RamsayMse(i) = BestResStat.mse / N_obs;
            end
            fprintf('%u Ramsay steps\n', i-2);
        end
                
        %% Adaptive Relaxed Lasso Step         
        [StatLassoLL, RunTimeS(end+1), RunTimeSname{end+1}] = StepLASSO( FolderNames, indx_I, indx_J, valuesNoiseNorm, N_obs, N_re, N_sp, bNoiseNorm, bStdEps, constr, BestResStat, PriorGraph.indx, kTrue);

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
