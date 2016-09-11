function [BestResStat, RunTimeS, RunTimeSname]= StepFG( FolderNames, indx_I, indx_J, values, N_obs, N_re, b, bStdEps, constr, indxPos, stoich)
    RunTimeSname = 'StepFG';
    fprintf('----------------%s----------------\n', RunTimeSname);
    OutFolder = sprintf('%s/', FolderNames.ResultsCV);
    OutFileName = sprintf('%s/%s.mat', OutFolder,RunTimeSname);
    
    ts = tic;
    if ~exist(OutFileName, 'file')
        
    %% normalize design and response
        [ values, weights ] = WeightDesignForRegression( indx_I, indx_J, values, N_obs, N_re ); %  weight design
        Aw = sparse(indx_I, indx_J, values, N_obs, N_re);        
        constrW = constr .* weights;
    %% solution
        x = zeros(N_re, 1);
%         x(indxPos) = lsq_step(Aw(:, indxPos), b, weights(indxPos), constrW(indxPos));
        x(indxPos) = lsq_step(Aw(:, indxPos), b, weights(indxPos), constrW(indxPos)); % old version   
        save(OutFileName, 'x');
    %%
        BestResStat.b_hat  = (Aw*(x .* weights)).*bStdEps; 
        
        if strcmp(FolderNames.connect, 'connected') 
            BestResStat.xOriginal = CheckConnected( stoich, x );
        else
            BestResStat.xOriginal = x;
        end
            
        BestResStat.card = length(find(BestResStat.xOriginal));    
        RunTimeS = toc(ts);
        save(OutFileName, '-append', 'BestResStat', 'RunTimeS');    
        FormatTime( RunTimeS, 'finished in ' );
    else
        RunTimeS = toc(ts);
        load(OutFileName)
    end
end

function [AIC, BIC, myC, cPm] = ICfunc(ll, df, N, S)
    AIC = N*log(ll/N) + 2*df;
    myC = ll / N + 2*df;
    BIC = N*log(ll/N) + log(N)*df;
    cPm = ll/S + 2*df - N;
end

function b_new = RelErrCorr(b, b_hat, w)
    b_new = b;
    bHt = abs(b);
    bHt((bHt .* w) < 1e-6) = 1e+10;
    err_rel = abs(b - b_hat) ./ bHt;
    indx_big = find(err_rel > 0.25);
    b_new(indx_big) = b_hat(indx_big);
end

function x = lsq_step(A, bH, weights, constrW)
    x = LassoADMMlsqr(A, bH, weights, 0, constrW) ./ weights ;
%     [x, flag, relres, iters] = lsqr(A, bH, 1e-4, 10000);
    x  = constrW ./ weights + VertVect(LSQstep( A, bH - A*constrW, x .* weights )) ./ weights;
    x(x < 1e-12) = 0;
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
