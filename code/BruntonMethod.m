function StatLassoLL = BruntonMethod(MethodName, ModelName, varargin )
% Main procedure
    ts = tic; % start time
    fpath = regexprep(pwd, 'ReactionetLasso/.*', 'ReactionetLasso/'); % path to the code-folder
    addpath(genpath(sprintf('%s/code/', fpath))); % add code directory to matlab path
    
    ModelParams = ReadInputParameters( varargin ); % identify default settings
    
    for nset = 1:5
        FolderNames = FolderNamesFunAltMethods(MethodName, ModelName, nset, ModelParams );
        RunTimeSname = {};
        RunTimeS = [];

        load(sprintf('%s/Data.mat', FolderNames.Data), 'Timepoints', 'SpeciesNames')

        [stoich, RunTimeS(end+1), RunTimeSname{end+1} ] = PrepareTopology( FolderNames );        
        [ E, V, C, E2, C3, E12, RunTimeS(end+1), RunTimeSname{end+1} ] = PrepareMoments( FolderNames, varargin );

        N_T = size(E, 2)-1;
        N_sp = size(stoich, 1);

        [indx_I, indx_J, values, N_obs, N_re, RunTimeS(end+1), RunTimeSname{end+1}] = PrepareDesign(FolderNames, mean(E, 3), mean(V, 3), mean(C, 3), mean(E2, 3), mean(C3, 3), mean(E12, 3), stoich, 0);

        [b, bStd, RunTimeS(end+1), RunTimeSname{end+1}, bBoot ] = PrepareResponse( FolderNames, E, V, C, Timepoints);
        
        b = mean(bBoot, 2);
        if nset == 1
            
        end
        
        [constr, ~] = ReadConstraints( FolderNames, stoich ); % Model Augmentation

        load(sprintf('%s/TrueStruct.mat', FolderNames.Data))
        kTrue = AnnotateTrueReactions( k, stoichTR, stoich );
        
        load(sprintf('%s/ValidationSet_cv%u.mat', FolderNames.Data, nset))
        [ E, V, C, E2, C3, E12 ] = CorrectMomentsForBinomialNoise( E, V, C, E2, C3, E12, FolderNames.p );
        [indx_Iv, indx_Jv, valuesV, N_obs, N_re] = PrepareDesign(FolderNames, E, V, C, E2, C3, E12, stoich, 0);
        Av = sparse(indx_Iv, indx_Jv, valuesV, N_obs, N_re);
        [bv, ~, RunTimeS(end+1), RunTimeSname{end+1}] = PrepareResponseVal( FolderNames, E, V, C, Timepoints);
        clear indx_Iv indx_Jv valuesV
        
        switch MethodName
            case 'TopFiltr'
                [ StatLassoLL, RunTimeS(end+1), RunTimeSname{end+1} ] = MethodTopFiltr( FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, kTrue, Av, bv);
            case 'lasso'
                [StatLassoLL, RunTimeS(end+1), RunTimeSname{end+1}] = MethodLasso( FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, kTrue, Av, bv);
            case 'SeqThresLSQ'
                [StatLassoLL, RunTimeS(end+1), RunTimeSname{end+1}] = MethodSeqThresLSQ( FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, kTrue, Av, bv);
            case 'lassoLSQ'
                [StatLassoLL, RunTimeS(end+1), RunTimeSname{end+1}] = MethodLassoLSQ( FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, kTrue, Av, bv);
        end
        
        PlotComputationTime( FolderNames.ResultsCV, ModelName, RunTimeS, RunTimeSname);
        FormatTime( toc(ts), 'Total RunTime: ' );

        fdr = reshape([StatLassoLL.fdr]', 2, [])';

        mse = [StatLassoLL.rss];
        AIC = [StatLassoLL.AIC_reg];
        BIC = [StatLassoLL.BIC_reg];
        
        mseCV(:, nset) = mse;
        aicCV(:, nset) = AIC;
        bicCV(:, nset) = BIC;
        
        ICList = {'mse', 'BIC', 'AIC'};
        l = 0;
        for i = 1:length(ICList)
            clear indx
            indx = SelectOptimalSolution( eval(sprintf('%s', ICList{i})) );
            for j = 1:length(indx)
                l = l+1;
                ScoreFunctionNameList{l} = sprintf('%s_%u', ICList{i}, j);
                fprintf('%s optimal: TP = %u\tFP = %u\n', ScoreFunctionNameList{l}, fdr(indx(j), :));
                xOptIndx(l) = indx(j);
            end
            FileName = sprintf('%s/%s_%s', FolderNames.ResultsCV, MethodName, FolderNames.SysName);
            AICandSSplot( [StatLassoLL.card], eval(sprintf('%s', ICList{i})), fdr, {ICList{i}, MethodName}, FileName);
        end
        
        FileName = sprintf('%s/SS%s_%s', FolderNames.ResultsCV, MethodName, FolderNames.SysName);
        StabilitySelectionPlot( fdr, sprintf('%s: %s (CV = %u)', MethodName, ModelName, nset), ScoreFunctionNameList, FileName, xOptIndx, fdr(xOptIndx, :));
    end
    
    FolderNames = FolderNamesFunAltMethods(MethodName, ModelName, 0, ModelParams );
    [ E, V, C, E2, C3, E12 ] = PrepareMoments( FolderNames, varargin );
    [indx_I, indx_J, values, N_obs, N_re] = PrepareDesign(FolderNames, squeeze(E(:, :, 1)), squeeze(V(:, :, 1)), squeeze(C(:, :, 1)), squeeze(E2(:, :, 1)), squeeze(C3(:, :, 1)), squeeze(E12(:, :, 1)), stoich, 0);
    b = PrepareResponse( FolderNames, squeeze(E(:, :, 1)), squeeze(V(:, :, 1)), squeeze(C(:, :, 1)), Timepoints);
    A = sparse(indx_I, indx_J, values, N_obs, N_re);
    
    switch MethodName
        case 'TopFiltr'
            [ StatLassoLL, RunTimeS(end+1), RunTimeSname{end+1} ] = MethodTopFiltr( FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, kTrue, A, b);
        case 'lasso'
            [StatLassoLL, RunTimeS(end+1), RunTimeSname{end+1}] = MethodLasso( FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, kTrue, A, b);
        case 'SeqThresLSQ'
            [StatLassoLL, RunTimeS(end+1), RunTimeSname{end+1}] = MethodSeqThresLSQ( FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, kTrue, A, b);
        case 'lassoLSQ'
            [StatLassoLL, RunTimeS(end+1), RunTimeSname{end+1}] = MethodLassoLSQ( FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, kTrue, A, b);
    end
    
    fdr = reshape([StatLassoLL.fdr]', 2, [])';
    
    mse = mean(mseCV, 2);
    AIC = mean(aicCV, 2);
    BIC = mean(bicCV, 2);
        
    clear indx
    for i = 1:length(ICList)
        indx = SelectOptimalSolution( eval(sprintf('%s', ICList{i})) );
        for j = 1:length(indx)
            l = l+1;
            ScoreFunctionNameList{l} = sprintf('%s_%u', ICList{i}, j);
            fprintf('%s optimal: TP = %u\tFP = %u\n', ScoreFunctionNameList{l}, fdr(indx(j), :));
            xOptIndx(l) = indx(j);
        end
        FileName = sprintf('%s/%s_%s', FolderNames.Results, MethodName, FolderNames.SysName);
        AICandSSplot( [StatLassoLL.card], eval(sprintf('%s', ICList{i})), fdr, {ICList{i}, MethodName}, FileName);
    end
    
    FileName = sprintf('%s/SS%s_%s', FolderNames.Results, MethodName, FolderNames.SysName);
    StabilitySelectionPlot( fdr, sprintf('%s: %s', MethodName, ModelName), ScoreFunctionNameList, FileName, xOptIndx, fdr(xOptIndx, :));
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
