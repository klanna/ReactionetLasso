function SimulateODEfit( ModelName, varargin )
%%
    fpath = regexprep(pwd, 'ReactionetLasso/.*', 'ReactionetLasso/'); % path to the code-folder
    addpath(genpath(sprintf('%s/code/', fpath))); % add code directory to matlab path
    
    ModelParams = ReadInputParameters( varargin ); % identify default settings
    FolderNames = FolderNamesFun( ModelName, 0, ModelParams );
    FileNameIn = sprintf('%s/StabilitySelection', FolderNames.Results);
    load(sprintf('%s.mat', FileNameIn))
    
    FolderOut = sprintf('%s/ODEfit/', FolderNames.Plots);
    if ~exist(FolderOut, 'dir')
        mkdir(FolderOut)
    end

    load(sprintf('%s/%s.mat', FolderNames.Data, FolderNames.PriorTopology));
    load(sprintf('%s/Data.mat', FolderNames.Data), 'Timepoints', 'SpeciesNames')
    
    for cv = 1:5
        FolderNamesCV = FolderNamesFun( ModelName, cv, ModelParams );
        load(sprintf('%s/ValidationSet_cv%u.mat', FolderNamesCV.Data, cv))
        [ Ecv(:, :, cv) ] = CorrectMomentsForBinomialNoise( E, V, C, E2, C3, E12, FolderNames.p );
    end
    mE = mean(Ecv, 3);
    StdE = std(Ecv, 0, 3)/ 5;
    
    for i = 1:length(ScoreFunctionNameList)
        %% pick up one of the solutions
        FileNameOut = sprintf('%s/ODEfit_%s_%s%u_%s_%s_%s', FolderOut, ModelName, ModelParams.Gradients, 100*ModelParams.p, ModelParams.PriorTopology, ModelParams.Prior, ScoreFunctionNameList{i});
        x = xOpt(:, i);
        indxPos = find(x);
        %% function that translates to xml-model
        MakeSBMLfile( FileNameOut, stoich(:, indxPos), x(indxPos), SpeciesNames, mE(:, 1));
        %% function that performs simulation
        [Simtime, Simdata] = SimulateModelSBML(FileNameOut, Timepoints, mE, StdE);
        %% plot the simulation
        ODEfitPlot( ScoreFunctionNameList{i}, FileNameOut, Simtime, Simdata, Timepoints, mE, StdE, SpeciesNames, 'on');
        ODEfitPlot( ScoreFunctionNameList{i}, FileNameOut, Simtime, Simdata, Timepoints, mE, StdE, SpeciesNames, 'off');
    end
    
end

