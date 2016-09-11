function MergeDatasetsStabilitySelection( DatasetNamesList, ModelName, varargin)
% Merges data sets in stability selection style
    fpath = regexprep(pwd, 'ReactionetLasso/.*', 'ReactionetLasso/'); % path to the code-folder
    addpath(genpath(sprintf('%s/code/', fpath))); % add code directory to matlab path
    ModelParams = ReadInputParameters( varargin ); % identify default settings
    
    FolderNamesOut = FolderNamesFun( ModelName, 0, ModelParams );        
    FileNameOut = sprintf('%s/MergeStabilitySelection.mat', FolderNamesOut.Results);
    FileNameOutPlot = sprintf('%s/MergeStabilitySelection', FolderNamesOut.Plots);
    
    if ~exist(FileNameOut, 'file')
        for i = 1:length(DatasetNamesList)
            FolderNamesIn = FolderNamesFun( DatasetNamesList{i}, 0, ModelParams );
            load(sprintf('%s/StabilitySelection.mat', FolderNamesIn.Results))
            %%
            x1 = x;
            x1(find(x1)) = 1;
            FreqPerDataset(:, i) = mean(x1, 2);
        end
        FrequencyTotal = mean(FreqPerDataset, 2);
        [ReScore, ReIndx] = sort(FrequencyTotal, 'descend');
        
        N_re = length(ReIndx);
        N_re_good = length(find(ReScore));
        
        xStruct = zeros(N_re, N_re_good);
        for i = 1:N_re_good
            xStruct(ReIndx(i), i:end) = 1;
        end
        
        save(FileNameOut, 'FreqPerDataset', 'FrequencyTotal', 'ReScore', 'ReIndx', 'xStruct')
    else
        load(FileNameOut)
    end
    
    if exist(sprintf('%s/TrueStruct.mat', FolderNamesOut.Data), 'file')
        load(sprintf('%s/%s.mat', FolderNamesOut.Data, FolderNamesOut.PriorTopology))
		load(sprintf('%s/TrueStruct.mat', FolderNamesOut.Data))
        kTrue = AnnotateTrueReactions( k, stoichTR, stoich );
        for i = 1:size(xStruct, 2)
            FDRscore(i, :) = FDR(kTrue, xStruct(:, i));
        end
        save(FileNameOut, '-append', 'FDRscore')
        A{1} = FDRscore;
        
        load(sprintf('%s/StabilitySelection.mat', FolderNamesOut.Results))
        A{2} = FDRscore;
        
        CompareTrueFalsePos( {A}, {ModelName}, {{'SS', 'matrix'}}, FileNameOutPlot);
    end
    
end

