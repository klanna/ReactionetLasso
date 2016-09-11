function ReactionetLassoCompareSettings( ModelName, p, MNameOut, PriorTop, PriorStoichList)
% Main procedure
    ModelNameOut = sprintf('%s_%s_p%u', ModelName, PriorTop, p*100);
    fpath = regexprep(pwd, 'ReactionetLasso/.*', 'ReactionetLasso/'); % path to the code-folder
    addpath(genpath(sprintf('%s/code/', fpath))); % add code directory to matlab path
    
%     GradientsList = {'splines', 'splines2', 'FDS'};
    GradientsList = {'splines'};
    ConnectList = {'', 'connected'};
%     ConnectList = {''};
    
    SettingName = {};
    ROCscoreList = {};
    FDRscoreList = {};
        for j = 1:length(PriorStoichList)
            PriorStoich = PriorStoichList{j};
%             PriorTop = PriorTopList{i};
            for ig = 1:length(GradientsList)
                for ic = 1:length(ConnectList)
                    ModelParams = ReadInputParameters( GradientsList{ig}, ConnectList{ic}, p, PriorTop, PriorStoich ); % identify default settings
                    FolderNames = FolderNamesFun( ModelName, 0, ModelParams );
                    try
                        load(sprintf('%s/StabilitySelection.mat', FolderNames.Results), 'FDRscore', 'FDRscoreOpt', 'ROCscoreOpt', 'ROCscore')
                        if strcmp(PriorStoich, '')
                           PriorStoichName = 'ab initio'; 
                        else
                           PriorStoichName = 'prior ';
                        end
                        if strcmp(ConnectList{ic}, 'connected')                        
%                             SettingName{end+1} = sprintf('%s%s %s (Opt)', PriorStoichName, GradientsList{ig}, ConnectList{ic});
%                             SettingName{end+1} = sprintf('%s', PriorStoichName);
%                             ROCscoreList{end+1} = ROCscoreOpt;
%                             FDRscoreList{end+1} = FDRscoreOpt;
                            FDRscore = unique([FDRscoreList{end}; FDRscoreOpt(end, :)], 'rows');
%                             FDRscore 
                            FDRscoreList{end} = FDRscore;
%                             tmp = ROCscoreList{end};
%                             maxtmp = tmp(end, :);
%                             for i = 1:size(ROCscoreOpt, 1)
%                                 ROCscoreOpt(:, 1)
%                             end
                        else
                            SettingName{end+1} = sprintf('%s', PriorStoichName);
                            ROCscoreList{end+1} = ROCscore;
                            FDRscoreList{end+1} = FDRscore;
                        end
                    catch
                        fprintf('NOT FOUND: %s\n', sprintf('%s %s %s', PriorStoich, GradientsList{ig}, ConnectList{ic}));
                    end
                end
            end 
        end
    
    OutFolder = sprintf('%s/CompareSettings', fpath);
    if ~exist(OutFolder, 'dir')
        mkdir(OutFolder)
    end
    
    FileName = sprintf('%s/ROC_%s', OutFolder, ModelNameOut);
    ROCPlot( ROCscoreList, MNameOut, FileName, SettingName);
    ROCPlot( ROCscoreList, MNameOut, FileName, SettingName, 'off');
    
    FileName = sprintf('%s/FDR_%s', OutFolder, ModelNameOut);
    FDRPlot( FDRscoreList, MNameOut, FileName, SettingName);
    FDRPlot( FDRscoreList, MNameOut, FileName, SettingName, 'off');
    
end

