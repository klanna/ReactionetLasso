function FolderName = FolderNamesFun( ModelName, nset, ModelParams)
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
    FolderName.SysName = sprintf('%s_%s%u_Boot%u_p%u%s', ModelName, ModelParams.Gradients, ModelParams.NMom, ModelParams.Nboot, FolderName.p*100);
    
    fprintf('=================%s=================\n', FolderName.SysName);
    
    FolderName.Data = sprintf('%s/data/%s/', folderpath, ModelName);
    FolderName.Results = sprintf('%s/results/%s/%s_%s/', folderpath, FolderName.SysName, FolderName.PriorTopology, FolderName.Prior);
    FolderName.Plots = sprintf('%s/plots/%s/%s_%s/', folderpath, FolderName.SysName, FolderName.PriorTopology, FolderName.Prior);
    
    if nset
        FolderName.Moments = sprintf('%s/Moments/%s/CV_%u/', folderpath, ModelName, nset); % supplementary
        FolderName.LinSystem = sprintf('%s/LinearSystem/%s/CV_%u/%s_%s/', folderpath, FolderName.SysName, nset, FolderName.PriorTopology, FolderName.Prior); % supplementary
        FolderName.ResultsCV = sprintf('%s/resultsCV/%s/CV_%u/%s_%s/', folderpath, FolderName.SysName, nset, FolderName.PriorTopology, FolderName.Prior);  % supplementary
        FolderName.PlotsCV = sprintf('%s/CV_%u/', FolderName.Plots, nset);
    else
        FolderName.Moments = sprintf('%s/Moments/%s/', folderpath, ModelName); % supplementary
        FolderName.LinSystem = sprintf('%s/LinearSystem/%s/%s_%s/', folderpath, FolderName.SysName, FolderName.PriorTopology, FolderName.Prior); % supplementary
        FolderName.ResultsCV = sprintf('%s/resultsCV/%s/%s_%s/', folderpath, FolderName.SysName, FolderName.PriorTopology, FolderName.Prior);  % supplementary
        FolderName.PlotsCV = sprintf('%s/', FolderName.Plots);
    end
    
    
end

