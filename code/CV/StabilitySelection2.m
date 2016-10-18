function [xOpt, b_hat, ScoreFunctionNameList, mse, AIC, BIC, card, RunTimeS, RunTimeSname] = StabilitySelection2( FolderNames, ModelParams, ReNumList, xscore)
    FileNameOut = sprintf('%s/StabilitySelection.mat', FolderNames.Results);
%     if ~exist(FileNameOut, 'file')
        ts = tic;
        load(sprintf('%s/%s.mat', FolderNames.Data, FolderNames.PriorTopology));
        load(sprintf('%s/Data.mat', FolderNames.Data), 'Timepoints', 'SpeciesNames')
        
        %% perfrom cross-validation
        FolderNames = FolderNamesFun( FolderNames.ModelName, 1, ModelParams );
        [ E, V, C, E2, C3, E12] = PrepareMoments( FolderNames, ModelParams );
        [indx_I, indx_J, values, N_obs, N_re] = PrepareDesign(FolderNames, squeeze(E(:, :, 1)), squeeze(V(:, :, 1)), squeeze(C(:, :, 1)), squeeze(E2(:, :, 1)), squeeze(C3(:, :, 1)), squeeze(E12(:, :, 1)), stoich, 0);
        b = PrepareResponse( FolderNames, E, V, C, Timepoints);
        
        Ncv = 5;
        for cv = 1:5
            FolderNamesCV = FolderNamesFun( FolderNames.ModelName, cv, ModelParams );
            load(sprintf('%s/Covar.mat', FolderNamesCV.LinSystem), 'bStdEps')
            bStdEpsCV(:, cv) = bStdEps;
            load(sprintf('%s/%s_ComputationTime.mat', FolderNamesCV.ResultsCV, FolderNames.ModelName))
            RunTimeScv(:, cv) = RunTimeS;
        end
        RunTimeS = mean(RunTimeScv, 2);
        
        bStdEps = mean(bStdEpsCV, 2);
        [ b, bStdEps, values ] = NoiseNormalization( bStdEps, b, indx_I, values);
        [ values, weights ] = WeightDesignForRegression( indx_I, indx_J, values, N_obs, N_re );
        Aw = sparse(indx_I, indx_J, values, N_obs, N_re);
        
        UniqueXscore = sort(unique(xscore), 'descend'); 
        NreUni = length(UniqueXscore);
        
        mseXscore = zeros(NreUni, 1);
        card = zeros(NreUni, 1);        
        x = zeros(N_re, NreUni);
        b_hat = zeros(N_obs, NreUni);
        for i = 1:NreUni
            xset = ReNumList(find(ReNumList(xscore >= UniqueXscore(i))));                       
            constr = 1e-16*ones(length(xset), 1);
%             constr = zeros(length(xset), 1);
            constrW = constr .* weights(xset);
            xW = (constrW + lsqnonneg(Aw(:, xset), b - Aw(:, xset)*constrW));
%             xW = lsqnonneg(Aw(:, xset), b);
            mseXscore(i) = sum((b - Aw(:, xset)*xW).^2);                    
            x(xset, i) = xW ./ weights(xset);
            b_hat(:, i) = (Aw(:, xset)*xW) .* bStdEps;
            card(i) = length(find(xW));
        end

        BIC = length(b)*log(mseXscore) + log(length(b))*card;
        AIC = length(b)*log(mseXscore) + 2*card;
        mse = mseXscore;
        
        ICList = {'mse', 'BIC', 'AIC'};

        l = 0;
        for i = 1:length(ICList)
            clear indx
            indx = SelectOptimalSolution( eval(sprintf('%s', ICList{i})) );
            for j = 1:length(indx)
                l = l+1;
                ScoreFunctionNameList{l} = sprintf('%s_%u', ICList{i}, j);
                xOptIndx(l) = indx(j);
                xOpt(:, l) = x(:, indx(j));
            end
        end
        
        RunTimeS = max(RunTimeScv);
        RunTimeS(end+1) = toc(ts);
        RunTimeSname{end+1} = 'StabilitySelection';
        
        save(FileNameOut, 'x', 'mse', 'AIC', 'BIC', 'ScoreFunctionNameList', 'xOpt', 'xOptIndx', 'RunTimeS', 'RunTimeSname', 'card', 'b_hat')
%     else
%         load(FileNameOut)
%     end
end



function [xOpt, imin] = OptimalSolution(x, ScoreFunction)  
    [~, imin] = min(ScoreFunction);
    xOpt = x(:, imin);
    fprintf('%u reactions\n', length(find(xOpt)));
end