function RunTopologicalFiltering( ModelName, varargin )
    
    fpath = regexprep(pwd, 'ReactionetLasso/.*', 'ReactionetLasso/'); % path to the code-folder
    addpath(genpath(sprintf('%s/code/', fpath))); % add code directory to matlab path
    
    ModelParams = ReadInputParameters( varargin ); % identify default settings
    
    Nsets = 5;
    for nset = 1:Nsets
        FolderNames = FolderNamesFun( ModelName, nset, ModelParams );
        TopologicalFiltering(FolderNames);
    end
end

