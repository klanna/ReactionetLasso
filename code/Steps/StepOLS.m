function [BestResStat, RunTimeS, RunTimeSname] = StepOLS(FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, N_T, N_sp, indxPos)
    RunTimeSname = 'StepOLS';
    fprintf('----------------StepOLS----------------\n');
    OutFolder = sprintf('%s/', FolderNames.ResultsCV);
    if ~exist(OutFolder, 'dir')
       mkdir(OutFolder) 
    end
    
    OutFileName = sprintf('%s/%s.mat', OutFolder,RunTimeSname);
    ts = tic;

    if ~exist(OutFileName, 'file')
    %% Only Means  
        if FolderNames.NMom == 2
            [indx_I, indx_J, values, N_obs, N_re, ~, NonEmptyIndx] = CutDesignRows(indx_I, indx_J, values, N_obs, N_re, N_sp, N_T);         
        else
            NonEmptyIndx = find(WeightsMask( N_sp, N_T, length(b), [1 0 0], 2 ));
        end
    %% weigth matrix
        [ values, weights ] = WeightDesignForRegression( indx_I, indx_J, values, N_obs, N_re );
        Aw = sparse(indx_I, indx_J, values, N_obs, N_re);
    %% Model Augmentation      
        constrW = constr .* weights;
%%      solver
        xW = zeros(N_re, 1);
        xW(indxPos) = constrW(indxPos) + lsqnonneg(Aw(:, indxPos), b(NonEmptyIndx) - Aw(:, indxPos)*constrW(indxPos));
%%      stats  
        BestResStat.xOriginal = xW ./ weights;
        BestResStat.b_hat = Aw*xW;
        BestResStat.r = b(NonEmptyIndx) - BestResStat.b_hat;
        BestResStat.MSE2 = norm(BestResStat.r, 2);
        BestResStat.time = toc(ts);
        
        RunTimeS = toc(ts);
        save(OutFileName, 'BestResStat', 'RunTimeS');      
        FormatTime( RunTimeS, 'StepOLS finished in ' );
        if ~exist(FolderNames.PlotsCV, 'dir')
            mkdir(FolderNames.PlotsCV)
        end
%         PlotFitToLinearSystem( FolderNames.NMom, b, A*BestResStat.xOriginal, N_T, N_sp, sprintf('%s/%s', FolderNames.PlotsCV, RunTimeSname), 'off');
    else
        RunTimeS = toc(ts);
        load(OutFileName, 'BestResStat');
    end
end