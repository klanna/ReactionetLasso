function ComputeODEfit( ModelName, varargin )
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
        load(sprintf('%s/Response.mat', FolderNamesCV.LinSystem))
        bM(:, cv) = b;
    end
    b = VertVect(mean(bM, 2));
    mE = mean(Ecv, 3);
    StdE = std(Ecv, 0, 3)/ 5;
    
    
    ode0 = mE;
    for i = 1:size(ode0, 1)
        ode0(i, 2:end) = ode0(i, 1);
    end
    
    i = size(x, 2);
    OdeDist0 = OdeDist( ode0, mE, StdE);
    ODEdist = ones(i, 1)*OdeDist0;
    
    while (i > 1)
        %% pick up one of the solutions
        FileNameOut = sprintf('%s/ODEfit_%s_%s%u_%s_%s_%u', FolderOut, ModelName, ModelParams.Gradients, 100*ModelParams.p, ModelParams.PriorTopology, ModelParams.Prior, i);
        xx = x(:, i);
        indxPos = find(xx);
        %% function that translates to xml-model
        MakeSBMLfile( FileNameOut, stoich(:, indxPos), xx(indxPos), SpeciesNames, mE(:, 1));
        %% function that performs simulation
        [Simtime, Simdata, ODEdist(i)] = SimulateModelSBML(FileNameOut, Timepoints, mE, StdE);
        ii = i;
        if  ODEdist(i) == OdeDist0
            i = 0;
        end
        i = i - 1;
        
        %% plot the simulation
%         ODEfitPlot( ScoreFunctionNameList{i}, FileNameOut, Simtime, Simdata, Timepoints, mE, StdE, SpeciesNames, 'on');
%         ODEfitPlot( ScoreFunctionNameList{i}, FileNameOut, Simtime, Simdata, Timepoints, mE, StdE, SpeciesNames, 'off');
    end
    
    n = size(mE, 1)*size(mE, 2);
    BIC = n*log(ODEdist) + log(n)*card';
    AIC = n*log(ODEdist) + 2*card';
    
    FileNameOut = sprintf('%s/ComputeODEfit_%s_%s%u_%s_%s', FolderNames.Plots, ModelName, ModelParams.Gradients, 100*ModelParams.p, ModelParams.PriorTopology, ModelParams.Prior);
    M = [VertVect(ODEdist) VertVect(AIC) VertVect(BIC)];
    ICplot( card(ii:end), M(ii:end, :), {'ODEdist', 'AIC', 'BIC'}, FileNameOut);
    
    FileNameDist = sprintf('%s/ComputeODEfit_%s_%s%u_%s_%s.mat', FolderNames.Results, ModelName, ModelParams.Gradients, 100*ModelParams.p, ModelParams.PriorTopology, ModelParams.Prior);
    save(FileNameDist, 'ODEdist', 'AIC', 'BIC')
    
    [~, i] = min(ODEdist);
    xx = x(:, i);
    indxPos = find(xx);
    FileNameOut = sprintf('%s/BestODEfit_%s_%s%u_%s_%s', FolderNames.Plots, ModelName, ModelParams.Gradients, 100*ModelParams.p, ModelParams.PriorTopology, ModelParams.Prior);
    %% function that translates to xml-model
    MakeSBMLfile( FileNameOut, stoich(:, indxPos), xx(indxPos), SpeciesNames, mE(:, 1));
    %% function that performs simulation
    [Simtime, Simdata] = SimulateModelSBML(FileNameOut, Timepoints, mE, StdE);
    %% plot the simulation
    ODEfitPlot( 'BestODEfit', FileNameOut, Simtime, Simdata, Timepoints, mE, StdE, SpeciesNames, 'on');
    ODEfitPlot( 'BestODEfit', FileNameOut, Simtime, Simdata, Timepoints, mE, StdE, SpeciesNames, 'off');
    
    PlotFitToLinearSystem( FolderNames.NMom, b, b_hat(:, i), length(Timepoints)-1, length(SpeciesNames), FileNameOut, 'off');
    
    b = b_hat(:, i);
    save(sprintf('%s/BestResponse.mat', FolderNames.Results), 'b')
end

function [l2dist, r] = OdeDist( ODEDataPoints, meanTraject, stdTrajectPos)
    stdTrajectPos(stdTrajectPos <= 0 ) = 1;
    
    r = ODEDataPoints - meanTraject;
    absdist = abs(r);
 
    reldist = reshape(absdist ./ stdTrajectPos, [], 1);

    l2distr = sqrt(sum(reldist.^2));
    l2dista = sqrt(sum(sum(absdist.^2)));
    
    % fprintf('l2dist abs = %1.1e\n', l2dista);
    % fprintf('l2dist rel = %1.1e\n', l2distr);
    
    l2dist = l2dista;
end

