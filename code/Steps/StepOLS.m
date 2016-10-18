function [BestResStat, RunTimeS, RunTimeSname] = StepOLS(FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, N_T, N_sp, kTrue, indxPos, varargin)
    RunTimeSname = 'StepOLS';
    fprintf('----------------StepOLS----------------\n');
    OutFolder = sprintf('%s/', FolderNames.ResultsCV);
    if ~exist(OutFolder, 'dir')
       mkdir(OutFolder) 
    end
    
    OutFileName = sprintf('%s/%s.mat', OutFolder,RunTimeSname);
    ts = tic;

    if ~exist(OutFileName, 'file') || ~isempty(regexp(FolderNames.Gradients, 'ramsay'))
    %% Only Means  
        A = sparse(indx_I, indx_J, values, N_obs, N_re);
        
        if FolderNames.NMom == 2
            if isempty(varargin)
                [indx_I, indx_J, values, N_obs, N_re, EmptyIndx, NonEmptyIndx] = CutDesignRows(indx_I, indx_J, values, N_obs, N_re, N_sp, N_T);
            else
                NonEmptyIndx = varargin{1};
                A = sparse(indx_I, indx_J, values, N_obs, N_re);
                Aw = A(NonEmptyIndx, :);
                [indx_I, indx_J, values] = find(Aw);
                [N_obs, N_re] = size(Aw);
                clear  Aw
            end
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
        
        lambda = 1e-9;
        Xi = xW ; % initial guess: Least-squares
        biginds_old = VertVect(zeros(length(Xi), 1));
        biginds =  VertVect(find(Xi));
        iter = 0;
        fprintf('%u iter: card = %u\n', iter, length(find(Xi)));
        biginds_old = 1:N_re;
        smallinds = [];
        smallindsold = [1];
        newsmallset = [1];
        
        while ~isempty(newsmallset)
            iter = iter + 1;
            
            smallindsold = smallinds;
            newsmallset =  VertVect(find(((Xi ./ weights) < lambda) & (Xi > 0)));

            smallinds = [smallinds;newsmallset];

            Xi(smallinds) = 0; % and threshold
            fprintf('%u iter: card = %u\n', iter, length(find(Xi)));
%             
            biginds =  setdiff(biginds_old, smallinds);
            biginds_old = biginds;
            % Regress dynamics onto remaining terms to find sparse Xi
            Xi(biginds) = lsqnonneg(Aw(:, biginds), b(NonEmptyIndx));
        end
        
        xW = Xi;
%%      stats  
        BestResStat.xOriginal = xW ./ weights;
        BestResStat.b_hat = A*BestResStat.xOriginal;
        BestResStat.r = b - BestResStat.b_hat;
        BestResStat.MSE2 = norm(BestResStat.r(NonEmptyIndx), 2);
        BestResStat.time = toc(ts);
        
        RunTimeS = toc(ts);
        save(OutFileName, 'BestResStat', 'RunTimeS');      
        FormatTime( RunTimeS, 'StepOLS finished in ' );
        if ~exist(FolderNames.PlotsCV, 'dir')
            mkdir(FolderNames.PlotsCV)
        end
        
        if any(kTrue)
            fprintf('kTrue = %.2e\n', norm(kTrue, 2));
            fprintf('x = %.2e\n', norm(BestResStat.xOriginal, 2));
            PlotScatterCons( kTrue, BestResStat.xOriginal, RunTimeSname, sprintf('%s/%s', FolderNames.PlotsCV, RunTimeSname), 'on');
        end
        PlotFitToLinearSystem( FolderNames.NMom, b, BestResStat.b_hat, N_T, N_sp, sprintf('%s/%s', FolderNames.PlotsCV, RunTimeSname), 'off');
    else
        RunTimeS = toc(ts);
        load(OutFileName, 'BestResStat');
    end
end