function [StatLassoLL, RunTimeS, RunTimeSname] = StepLASSO( FolderNames, indx_I, indx_J, values, N_obs, N_re, N_sp, b, bStdEps, constr, BestResStat, prior_indx, kTrue)
    ts = tic;
    RunTimeSname = 'StepLASSO';
    fprintf('----------------%s----------------\n', RunTimeSname);
    OutFolder = sprintf('%s/', FolderNames.ResultsCV);
    OutFileName = sprintf('%s/%s.mat', OutFolder,RunTimeSname);
%     if ~exist(OutFileName, 'file')
        x1 = VertVect([BestResStat.xOriginal]);
        x1(prior_indx) = 1;
    %% shorten design A
        N_reOri = N_re;
        [indx_I, indx_J, values, N_obs, N_re, indxNeg, indxPos] = CutDesign(indx_I, indx_J, values, N_obs, N_re, x1);
        x1(indxNeg) = [];
        constr(indxNeg) = [];
    %% weight on error distribution
        [ values, xAW ] = AdaptationDesign( indx_J, values, x1 ); %  adaptive method
        [ values, weights ] = WeightDesignForRegression( indx_I, indx_J, values, N_obs, N_re ); %  weight design
        Aw = sparse(indx_I, indx_J, values, N_obs, N_re);  
        constrW = (constr ./ xAW) .* weights;
    %% start
        StatLassoLL = LassoVpathChol(Aw, b, weights, [], constrW);
    %%    
        xLSQw = lsqnonneg(Aw, b);
        Sigma2 = sum(abs((b - Aw*xLSQw).*bStdEps).^2);


        for i = 1:length(StatLassoLL)
            xCorrectW = (constrW + VertVect(LSQstep( Aw, b - Aw*constrW, StatLassoLL(i).z )));
            xCorrect = xCorrectW .* xAW ./ weights;

            xOri = zeros(N_reOri, 1);
            xOri(indxPos) = xCorrect;
            xOri(xOri < 1e-12) = 0;
            
            StatLassoLL(i).r  = (Aw*xCorrectW).*bStdEps;
            StatLassoLL(i).rss = sum(abs(b.*bStdEps - [StatLassoLL(i).r]).^2);

            StatLassoLL(i).rssOri = sum((b.*bStdEps - [StatLassoLL(i).r]).^2);
            StatLassoLL(i).xOriginal = xOri;
            StatLassoLL(i).card = length(find(xOri));

            if StatLassoLL(i).lambda
                fname = sprintf('lambda_log_%.0f', log(StatLassoLL(i).lambda));
            else
                fname = sprintf('lambda_0');
            end    
            
            if any(kTrue)
                f(i, :) = FDR(kTrue, xOri);
                StatLassoLL(i).fdr = f(i, :);
                
                fprintf('TP = %u,\tFP = %u\n', f(i, 1), f(i, 2));
            end
    %         StatLassoLL(i).ODEdist = ModelSBML( ResFolder, fname, xOri, stoich, SpeciesNames, initialAmount, Timepoints, mean(E, 3), std(E, 0, 3), pic);  
            %% regression IC
            [StatLassoLL(i).AIC_reg, StatLassoLL(i).BIC_reg, StatLassoLL(i).cPm_reg] = ICfunc(StatLassoLL(i).rss, StatLassoLL(i).card, N_obs, Sigma2);
        end
        RunTimeS = toc(ts);
        save(OutFileName, 'StatLassoLL', 'RunTimeS');
        FormatTime( RunTimeS, 'finished in ' );
        
        if any(kTrue)
            LassoPlot( f, sprintf('%s/%s', FolderNames.PlotsCV, RunTimeSname));
        end
%     else
%         load(OutFileName)
%     end
end

function [AIC, BIC, cPm] = ICfunc(ll, df, N, S)
    AIC = log(ll) + 2*df/N;
    BIC = log(ll) + log(N)*df/N;
    cPm = ll/S + 2*df;
end

function [indx_I, indx_J, values, N_obs, N_re, indxNeg, indxPos] = CutDesign(indx_I, indx_J, values, N_obs, N_re, x0)
    A = sparse(indx_I, indx_J, values, N_obs, N_re);
    indxNeg = find( x0 == 0 );
    indxPos = find( x0 );
    A(:, indxNeg) = [];
    [indx_I, indx_J, values ] = find(A);
    [N_obs, N_re] = size(A);
    clear A
end

function [ values, xAW ] = AdaptationDesign( indx_J, values, xAW)
% Adapting design and corresponding rate constants
% xAW - values to use for adaptation
% indx_J, values - design matrix
% k - rate constants
% Method:
% (A * xAw)*(x / xAw), x_adapt = x / xAw
% WarmStart - warm start for regressin problem
    tsld = tic;
    fprintf('Adapting design...\t');
    
    xAW(xAW == 0) = 1;
    values = WeightSparseMatrix( indx_J, values, xAW);     
    
    fprintf('%.5f sec\n', toc(tsld));
end

