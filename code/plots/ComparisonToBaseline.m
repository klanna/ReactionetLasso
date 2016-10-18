function ComparisonToBaseline( ModelName, N_ch, TPModel, GradientType, ModelAugmentName, ModelAugmentList, NMom, StochDetFlag, Nboot, varargin )
    addpath(genpath('code'))
    FolderNames = FNamesFun( ModelName, N_ch, TPModel, GradientType, ModelAugmentName, ModelAugmentList, NMom, StochDetFlag, Nboot, '' );
    FolderNames1 = FNamesFun( ModelName, N_ch, TPModel, GradientType, ModelAugmentName, ModelAugmentList, 1, StochDetFlag, Nboot, '' );
    ResultFolderGeneral = sprintf('%s/', FolderNames.Res3);
    BaselineListType = {'TopFiltr', 'lasso'};
    BaselineListMom  = {'1st', '2nd'};
    %% load data
    load(sprintf('%s/Topology.mat', FolderNames.Data0))
%     [ indx_I, indx_J, values, N_obs, N_re ] = LoadDesign( FolderNames, stoich );
    load(sprintf('%s/Trajectories%s.mat', FolderNames.Data01, FolderNames.TPModel), 'indx');
    load(sprintf('%s/Response.mat', FolderNames.Data2));
    load(sprintf('%s/Covar.mat', FolderNames.Data3));
    N_T = length(indx);
    [N_sp, N_re] = size(stoich);
    clear indx
    
    %%
    r = 0;
    for i = 1:length(BaselineListMom)
        clear Aw bw
%         switch BaselineListMom{i}
%             case '1st'
%                 [indx_Iw, indx_Jw, valuesw, N_obsw, N_re, ~, NonEmptyIndx] = CutDesignRows(indx_I, indx_J, values, N_obs, N_re, N_sp, N_T); 
%                 [ valuesw, weights ] = WeightDesignForRegression( indx_Iw, indx_Jw, valuesw, N_obsw, N_re );
%                 Aw = sparse(indx_Iw, indx_Jw, valuesw, N_obsw, N_re);
%                 bw = b(NonEmptyIndx);
%             case '2nd'
%                 [ valuesw, weights ] = WeightDesignForRegression( indx_I, indx_J, values, N_obs, N_re );
%                 Aw = sparse(indx_I, indx_J, valuesw, N_obs, N_re);
%                 bw = b;
%             case '2ndWeighted'
%                 [ bw, bStdEps, valuesw ] = NoiseNormalization( bStdEps, b, indx_I, values, N_sp, N_T, N_obs);
%                 [ valuesw, weights ] = WeightDesignForRegression( indx_I, indx_J, valuesw, N_obs, N_re );
%                 Aw = sparse(indx_I, indx_J, valuesw, N_obs, N_re);
%         end
%         
        for j = 1:length(BaselineListType)
            method = sprintf('%s_%s', BaselineListType{j}, BaselineListMom{i});
            if ~strcmp('TopFiltr_2nd', method)
                fprintf('%s\n', method);
                ResultFolder = sprintf('%s/%s/', ResultFolderGeneral, method);
                if ~exist(ResultFolder, 'dir')
                    mkdir(ResultFolder);
                end
                FileNameOut = sprintf('%s/%s', ResultFolder, method);
                if ~exist(sprintf('%s.mat', FileNameOut), 'file') 
                    x0 = lsqnonneg(Aw, bw);
                    indxGood = find(x0);
                    indx_start = 1:length(indxGood);
                    switch BaselineListType{j}
                        case 'TopFiltr'
                            [ xx, MSEscore, FDRscore, Ctime ] = TopologFiltr( x0(indxGood), indx_start, Aw(:, indxGood), bw, weights(indxGood), k(indxGood), []);
                            x = zeros(N_re, size(xx, 2));
                            x(indxGood, :) = xx;
                            save(sprintf('%s.mat', FileNameOut), 'x', 'MSEscore', 'FDRscore', 'Ctime')
                        case 'lasso'
                            [xx, lambda_list, Ctime] = LassoPathChol(Aw(:, indxGood), bw, 1, weights(indxGood));
                            x = zeros(N_re, size(xx, 2));
                            x(indxGood, :) = xx;
                            for l = 1:size(x, 2),
                                FDRscore(l, :) = FDR(k, x(:, l));
                                MSEscore(l) = sum((bw - Aw*(x(:, l))).^2);
                                x(:, l) = x(:, l) ./ weights;
                            end  
                            save(sprintf('%s.mat', FileNameOut), 'x', 'MSEscore', 'FDRscore', 'Ctime', 'lambda_list')
                    end
                else
                    load(FileNameOut)
                end
                r = r+1;
                FDRscore = unique(FDRscore, 'rows');
                [~, indx] = sort(sum(FDRscore'));
                FDRscore = FDRscore(indx, :);
                FDRscoreMethod{r, 1} = FDRscore;
                LegendNames{r} = sprintf('%s %s', BaselineListType{j}, BaselineListMom{i});
                if strcmp('TopFiltr_1st', method)
                    LegendNames{r} = 'Topological filtering';
                end
                TotalTime(r) = Ctime(end);
                clear FDRscore
            end
        end      
    end
    
%     r = r+1;
%     StepNum = 4;
%     load(sprintf('%s/S_%u/%s_S%u', FolderNames.Res3, StepNum, FolderNames.SysName, StepNum));
% %     FDRscore(:, 1) = [StatLassoLL.TP];
% %     FDRscore(:, 2) = [StatLassoLL.FP];
%     FDRscoreMethod{r, 1} = FDRscore;
%     LegendNames{r} = sprintf('Topological filtering 2nd');
%     TotalTime(r) = max(Ctime);
%     clear FDRscore
% %     
%     r = r+1;
%     StepNum = 3;
%     sName = 'MSElast_5';
%     ResFolder = sprintf('%s/S_%u_StabilitySelection_%s/', FolderNames.Res3, StepNum, sName);
%     load(sprintf('%s/%s_S%u_StabilitySelection_%s.mat', ResFolder, FolderNames.SysName, StepNum, sName));
%     FDRscoreMethod{r, 1} = FDRscore;
%     LegendNames{r} = sprintf('Reactionet lasso (%s)', sName);
%     TotalTime(r) = Ctime(end);
%     clear FDRscore
%     
    
%     r = r+1;
%     load(sprintf('%s/ReactionScore.mat', FolderNames.Res3));
%     FDRscoreMethod{r, 1} = FDRscore;
%     LegendNames{r} = sprintf('StabilitySelection');
%     TotalTime(r) = Ctime(end);
%     clear FDRscore
    
%     r = r+1;
%     StepNum = 3;
%     sName = 'MSElast_5';
%     ResFolder = sprintf('%s/S_%u_StabilitySelection_%s/', FolderNames1.Res3, StepNum, sName);
%     load(sprintf('%s/%s_S%u_StabilitySelection_%s.mat', ResFolder, FolderNames1.SysName, StepNum, sName));
%     FDRscoreMethod{r, 1} = FDRscore;
%     LegendNames{r} = sprintf('Reactionet lasso 1st (%s)', sName);
%     TotalTime(r) = Ctime(end);
%     clear FDRscore
%     
    r = r+1;
    StepNum = 3;
    sName = 'MSE';
%     ResFolder = sprintf('%s/S_%u_StabilitySelection_%s/', FolderNames1.Res3, StepNum, sName);
%     load(sprintf('%s/%s_S%u_StabilitySelection_%s.mat', ResFolder, FolderNames1.SysName, StepNum, sName));
    load(sprintf('%s/ReactionScore.mat', FolderNames1.Res2));
    FDRscoreMethod{r, 1} = FDRscore;
    LegendNames{r} = sprintf('Reactionet lasso 1st');
    
    CTimeOUT = PrepareTime(FolderNames1);
    TotalTime(r) = sum(CTimeOUT(2:end));
    
    r = r+1;
    StepNum = 3;
    sName = 'MSE';
%     ResFolder = sprintf('%s/S_%u_StabilitySelection_%s/', FolderNames.Res3, StepNum, sName);
%     load(sprintf('%s/%s_S%u_StabilitySelection_%s.mat', ResFolder, FolderNames.SysName, StepNum, sName));
    load(sprintf('%s/ReactionScore.mat', FolderNames.Res2));
    FDRscoreMethod{r, 1} = FDRscore;
    LegendNames{r} = sprintf('Reactionet lasso 2nd');
    CTimeOUT = PrepareTime(FolderNames);
    TotalTime(r) = sum(CTimeOUT(2:end));
    clear FDRscore
    
        
%     StepNum = 3;
%     load(sprintf('%s/S_%u/StabilitySelectionOriginal.mat', FolderNames.Res3, 2));
%     r = r+1;
%     FDRscoreMethod{r, 1} = FDRscore1;
%     LegendNames{r} = sprintf('with cutoff (0.2)');
%     TotalTime(r) = Ctime;
%     r = r+1;
%     FDRscoreMethod{r, 1} = FDRscore2;
%     LegendNames{r} = sprintf('with cutoff (0.4)');
%     TotalTime(r) = Ctime;
%     r = r+1;
%     FDRscoreMethod{r, 1} = FDRscore3;
%     LegendNames{r} = sprintf('with cutoff (0.6)');
%     TotalTime(r) = Ctime;
%     clear FDRscore
%     
    
    SetMyColors
    
    figname = 'SupFig_5';
    Folder = sprintf('%s/PaperFigures/SupFigures/%s/', FolderNames.fpath, figname);
    if ~exist(Folder, 'dir')
        mkdir(Folder)
    end
    FileName = sprintf('%s/%s_%s', Folder, figname, ModelName);
    ModelNameMod = sprintf('%s (p = %.2f)', ModelName(1:regexp(ModelName, '[0-9]*')-1), FolderNames.p);
    
    if ~isempty(varargin)
        FileName = varargin{1};
    end
    
    MyColorTF = [228,26,28;
                204,229,255;
                55,126,184;
                204,255,204;
                77,175,74;
                152,78,163;
                255,127,0;
                255,255,51;
                166,86,40;
                247,129,191;
                153,153,153]/255;
    
%     CompareTrueFalseBaseline( FDRscoreMethod, ModelNameMod, {ModelNameMod}, {LegendNames}, MyColorTF, FileName, 4, 4);
    size1 = 3.5;
    CompareTrueFalseBaseline( FDRscoreMethod, ModelNameMod, {ModelNameMod}, {LegendNames}, MyColorTF, FileName, size1, size1);
    PlotCompTime( FileName, ModelNameMod, TotalTime, LegendNames, MyColorTF);
%     figure('Name', 'Time')
%     bar(TotalTime, MyColor(2, :))
end

