function FolderName = FolderNamesFunAltMethods( MethodName, ModelName, nset, ModelParams)
%% varargin - path to the folder with data and results
    if regexp(pwd, 'cluster')
        folderpath = '/cluster/scratch/klanna/ReactionetLasso/';
    else
        folderpath = regexprep(pwd, 'ReactionetLasso/.*', 'ReactionetLasso/');
    end    
    %% save parameter
    FolderName = ModelParams;
    FolderName.fpath = folderpath;
    FolderName.ModelName = ModelName;
    FolderName.CV = nset;
    FolderName.SysName = sprintf('%s_%s%u_Boot%u_p%u%s', ModelName, ModelParams.Gradients, ModelParams.NMom, ModelParams.Nboot, round(FolderName.p*100));
    FolderName.connect = ModelParams.connect;
    FolderName.MomentClosure = ModelParams.MomentClosure;
    FolderName.Method = MethodName;
    
    fprintf('=================%s=================\n', FolderName.SysName);
    
    FolderName.Data = sprintf('%s/data/%s/', folderpath, ModelName);
    FolderName.Results = sprintf('%s/%s/results/%s/%s%s_%s%s/', folderpath, MethodName, FolderName.SysName, FolderName.connect, FolderName.PriorTopology, FolderName.Prior, FolderName.MomentClosure);
    FolderName.Plots = sprintf('%s/%s/plots/%s/%s%s_%s%s/', folderpath, MethodName, FolderName.SysName, FolderName.connect, FolderName.PriorTopology, FolderName.Prior, FolderName.MomentClosure);
    
    if nset
        FolderName.Moments = sprintf('%s/Moments/%s/CV_%u/', folderpath, ModelName, nset); % supplementary
        FolderName.LinSystem = sprintf('%s/LinearSystem/%s/CV_%u/%s%s_%s%s/', folderpath, FolderName.SysName, nset, FolderName.connect, FolderName.PriorTopology, FolderName.Prior, FolderName.MomentClosure); % supplementary
        FolderName.ResultsCV = sprintf('%s/%s/resultsCV/%s/CV_%u/%s%s_%s%s/', folderpath, MethodName, FolderName.SysName, nset, FolderName.connect, FolderName.PriorTopology, FolderName.Prior, FolderName.MomentClosure);  % supplementary
        FolderName.PlotsCV = sprintf('%s/CV_%u/', FolderName.Plots, nset);
    else
        FolderName.Moments = sprintf('%s/Moments/%s/', folderpath, ModelName); % supplementary
        FolderName.LinSystem = sprintf('%s/LinearSystem/%s/%s%s_%s%s/', folderpath, FolderName.SysName, FolderName.connect, FolderName.PriorTopology, FolderName.Prior, FolderName.MomentClosure); % supplementary
        FolderName.ResultsCV = sprintf('%s/%s/resultsCV/%s/%s%s_%s%s/', folderpath, MethodName, FolderName.SysName, FolderName.connect, FolderName.PriorTopology, FolderName.Prior, FolderName.MomentClosure);  % supplementary
        FolderName.PlotsCV = sprintf('%s/%s/', FolderName.Plots, MethodName);
    end
    
    
end

