function StatLassoLL = BruntonMethod2(MethodName, ModelName, varargin )
    Nhours = 24;
    ts = tic; % start time
    fpath = regexprep(pwd, 'ReactionetLasso/.*', 'ReactionetLasso/'); % path to the code-folder
    addpath(genpath(sprintf('%s/code/', fpath))); % add code directory to matlab path
    
    ModelParams = ReadInputParameters( varargin ); % identify default settings
    
    nset = 0;
    
    FolderNames = FolderNamesFunAltMethods(MethodName, ModelName, nset, ModelParams );
    RunTimeSname = {};
    RunTimeS = [];
    
    load(sprintf('%s/Data.mat', FolderNames.Data), 'Timepoints', 'SpeciesNames')
    [stoich, RunTimeS(end+1), RunTimeSname{end+1} ] = PrepareTopology( FolderNames );
    
    boot = 1;
    [ E(:, :, boot), V(:, :, boot), C(:, :, boot), E2(:, :, boot), C3(:, :, boot), E12(:, :, boot)] = PrepareMomentsBoot( boot, FolderNames.ModelName, FolderNames.CV, varargin );
    
    [indx_I, indx_J, values, N_obs, N_re] = PrepareDesign(FolderNames, squeeze(E(:, :, 1)), squeeze(V(:, :, 1)), squeeze(C(:, :, 1)), squeeze(E2(:, :, 1)), squeeze(C3(:, :, 1)), squeeze(E12(:, :, 1)), stoich, 0);
    b = PrepareResponse( FolderNames, squeeze(E(:, :, 1)), squeeze(V(:, :, 1)), squeeze(C(:, :, 1)), Timepoints);
    A = sparse(indx_I, indx_J, values, N_obs, N_re);
    [constr, ~] = ReadConstraints( FolderNames, stoich ); % Model Augmentation

    load(sprintf('%s/TrueStruct.mat', FolderNames.Data))
    kTrue = AnnotateTrueReactions( k, stoichTR, stoich );
        
    switch MethodName
        case 'TopFiltr'
            [ StatLassoLL, RunTimeS(end+1), RunTimeSname{end+1} ] = MethodTopFiltr( FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, kTrue, A, b, Nhours);
        case 'lasso'
            [StatLassoLL, RunTimeS(end+1), RunTimeSname{end+1}] = MethodLasso( FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, kTrue, A, b);
        case 'SeqThresLSQ'
            [StatLassoLL, RunTimeS(end+1), RunTimeSname{end+1}] = MethodSeqThresLSQ( FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, kTrue, A, b, Nhours);
        case 'lassoLSQ'
            [StatLassoLL, RunTimeS(end+1), RunTimeSname{end+1}] = MethodLassoLSQ( FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, kTrue, A, b);
    end
    
    ICList = {'mse'};
    fdr = reshape([StatLassoLL.fdr]', 2, [])';
    mse = [StatLassoLL.rss];
    AIC = [StatLassoLL.AIC_reg];
    BIC = [StatLassoLL.BIC_reg];
    
    clear indx
    l = 0;
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
    StabilitySelectionPlot( fdr, sprintf('%s: %s', MethodName, ModelName), {}, FileName, xOptIndx, []);
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
