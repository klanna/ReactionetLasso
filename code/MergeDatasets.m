function MergeDatasets( DatasetNamesList, ModelName, ValidationSet, varargin )
% function for dose-response measurements and similar inference
    tic
    fpath = regexprep(pwd, 'ReactionetLasso/.*', 'ReactionetLasso/'); % path to the code-folder
    addpath(genpath(sprintf('%s/code/', fpath))); % add code directory to matlab path
    ModelParams = ReadInputParameters( varargin ); % identify default settings
        
    for nset = 1:5   
        FolderNamesOut = FolderNamesFun( ModelName, nset, ModelParams );
        FolderNamesVal = FolderNamesFun( ValidationSet, nset, ModelParams );

        bStdEpsM = [];
        bM = [];
        A = [];
        wmask = [];
        TimepointsAll = [];
        
        for i = 1:length(DatasetNamesList)
            FolderNames = FolderNamesFun( DatasetNamesList{i}, nset, ModelParams );
            load(sprintf('%s/%s.mat', FolderNames.Data, FolderNames.PriorTopology))
            load( sprintf('%s/Response.mat', FolderNames.LinSystem))
            load(sprintf('%s/Data.mat', FolderNames.Data), 'SpeciesNames', 'Timepoints')
            bM = [bM; b];
            load(sprintf('%s/Design.mat', FolderNames.LinSystem))
            A = [A ; sparse(indx_I, indx_J, values, N_obs, N_re)];  
            load(sprintf('%s/Covar.mat', FolderNames.LinSystem))
            bStdEpsM = [bStdEpsM; bStdEps];
            wmask = [wmask; VertVect(WeightsMask( length(SpeciesNames), length(Timepoints), N_obs, [1 0 0], 2 ))];
            TimepointsAll = [TimepointsAll; VertVect(Timepoints)];
        end
        
        if ~exist(FolderNamesOut.Data, 'dir')
            mkdir(FolderNamesOut.Data)
        end
        
        if ~exist(FolderNamesOut.ResultsCV, 'dir')
            mkdir(FolderNamesOut.ResultsCV)
        end
        
        if ~exist(FolderNamesOut.LinSystem, 'dir')
            mkdir(FolderNamesOut.LinSystem)
        end
        
        load(sprintf('%s/Data.mat', FolderNamesVal.Data), 'SpeciesNames', 'Timepoints')
        
        if ~exist(FolderNamesOut.Moments, 'dir')
            mkdir(FolderNamesOut.Moments)
        end
        
        if exist(sprintf('%s/TrueStruct.mat', FolderNames.Data), 'file')
            copyfile( sprintf('%s/TrueStruct.mat', FolderNames.Data), sprintf('%s/TrueStruct.mat', FolderNamesOut.Data) );
        end
        copyfile(sprintf('%s/%s.mat', FolderNamesVal.Data, FolderNamesVal.PriorTopology), sprintf('%s/%s.mat', FolderNamesOut.Data, FolderNamesOut.PriorTopology))
        copyfile(sprintf('%s/%s_ComputationTime.mat', FolderNamesVal.ResultsCV, FolderNamesVal.ModelName), sprintf('%s/%s_ComputationTime.mat', FolderNamesOut.ResultsCV, FolderNamesOut.ModelName))
        copyfile(sprintf('%s/ValidationSet_cv%u.mat', FolderNamesVal.Data, nset), sprintf('%s/ValidationSet_cv%u.mat', FolderNamesOut.Data, nset))
        copyfile(sprintf('%s/TrainingSet_Nb%u_cv%u.mat', FolderNamesVal.Data, FolderNamesVal.Nboot, FolderNames.CV), sprintf('%s/TrainingSet_Nb%u_cv%u.mat', FolderNamesOut.Data, FolderNamesOut.Nboot, FolderNamesOut.CV))
        copyfile(sprintf('%s/TrainingSet_Nb%u_cv%u.mat', FolderNamesVal.Data, FolderNamesVal.Nboot, 0), sprintf('%s/TrainingSet_Nb%u_cv%u.mat', FolderNamesOut.Data, FolderNamesOut.Nboot, 0))
        
        [N_obs, N_re] = size(A);
        [indx_I, indx_J, values] = find(A);
        b = bM;
        
        clear A bM  
        [N_sp, N_re] = size(stoich);
        [constr, PriorGraph] = ReadConstraints( FolderNames, stoich ); % Model Augmentation
        
        %% OLS step (step zero)
        [BestResStat] = StepOLS(FolderNamesOut, indx_I, indx_J, values, N_obs, N_re, b, constr, 0, N_sp, 1:N_re, find(wmask));  

        %% normalize linear system on covariance
        [ bNoiseNorm, bStdEpsM, valuesNoiseNorm ] = NoiseNormalization( bStdEpsM, b, indx_I, values);    %  b-cov weightening

        %% Feasible Generalized Least Squares Step
    %         [xb, RunTimeS, RunTimeSName] = BoostFeatureSelecion( FolderNames, E, V, C, E2, C3, E12, stoich, b, constr);
        [BestResStat] = StepFG( FolderNamesOut, indx_I, indx_J, valuesNoiseNorm, N_obs, N_re, bNoiseNorm, bStdEpsM, constr, 1:N_re, stoich);        

        %% Adaptive Relaxed Lasso Step 
        [StatLassoLL] = StepLASSO( FolderNamesOut, indx_I, indx_J, valuesNoiseNorm, N_obs, N_re, N_sp, bNoiseNorm, bStdEpsM, constr, BestResStat, PriorGraph.indx);
        toc
        
        save( sprintf('%s/Response.mat', FolderNamesOut.LinSystem), 'b', 'bStd')
        save( sprintf('%s/Design.mat', FolderNamesOut.LinSystem), 'indx_I', 'indx_J', 'values', 'N_obs', 'N_re')
        load(sprintf('%s/Covar.mat', FolderNamesVal.LinSystem), 'bStdEps')
        save(sprintf('%s/Covar.mat', FolderNamesOut.LinSystem), 'bStdEpsM', 'bStdEps')
        save(sprintf('%s/Data.mat', FolderNamesOut.Data), 'SpeciesNames', 'Timepoints', 'TimepointsAll')
    end
    ReactionetLassoSSmerge( ModelName, varargin );
    MergeDatasetsStabilitySelection( DatasetNamesList, ModelName, varargin);
end

