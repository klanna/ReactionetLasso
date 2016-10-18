function [z, history] = LassoADMMlsqr2(A, b, weights, lam, varargin)
% lasso  Solve lasso problem via ADMM with nonneg constrains
% TolLASSO, MAX_ITER, WarmStart
% [z, history] = LassoADMMlsqr(A, b, weights, lambda)
    n = size(A, 2);
    rho = 1;
    TolLASSO = 1e-4;
    MAX_ITER = 1000;
    LeftBorder = zeros(n, 1);
%% 
    for i = 1:length(varargin)
        if length(varargin{i}) > 1
            LeftBorder = varargin{i};
        elseif varargin{i} < 1
            TolLASSO = varargin{i};
        else
            MAX_ITER = varargin{i};
        end
    end
    tss = tic;
%% Global constants and defaults
    alpha = 1.8;
    mu = 10;
    tau = 2;      
% Parameters for lsqr step
    LsqIter = 1000;
    LsqTol = 1e-4;

%% ADMM solver
%     fprintf('LassoADMMlsqr started with lambda = %1.1e ...\n', lam);
    x = zeros(n, 1);
    z = x;
    u = x - z;
        
    history.status = 'Unsolved';
    
%     lambda = lam ./ weights;
    lambda = lam ./ ones(size(weights));
    lambda(find(LeftBorder)) = 0;

    for k = 1:MAX_ITER
        % x-update
        if k > 500
            LsqIter = 1000;
            LsqTol = 1e-4;
        end
        [x, flag, relres, iters] = lsqr([A; sqrt(rho)*speye(n)], [b; sqrt(rho)*(z-u)], LsqTol, LsqIter, [], [], x);
%         x(x < 1e-12) = 0;
        
        % z-update with relaxation
        zold = z;
        x_hat = alpha*x + (1 - alpha)*zold;
        z = max(LeftBorder, shrinkage(x_hat + u, lambda/rho)); 
            
        % u-update
        u = u + (x_hat - z);

        % diagnostics, reporting, termination checks
        history.r_norm(k)  = norm(x - z);
        history.s_norm(k)  = norm(-rho*(z - zold));

        history.eps_pri(k) = sqrt(n)*TolLASSO + TolLASSO*max(norm(x), norm(-z));
        history.eps_dual(k)= sqrt(n)*TolLASSO + TolLASSO*norm(rho*u);

        if (history.r_norm(k) < history.eps_pri(k) && history.s_norm(k) < history.eps_dual(k))
             history.status = 'Solved';
             break;
        end

        % adjust rho
        if history.r_norm(k) > mu * history.s_norm(k)
            rho = rho * tau;
            u = u / tau;
        elseif history.s_norm(k) > mu * history.r_norm(k)
            rho = rho / tau;
            u = u * tau;
        end
    end
    
    z(z < 1e-12) = 0;
    history.z = z;
    history.iter = k;
    history.time = toc(tss);
    
    history.lambda = lam;
    
%     fprintf('%s: %u iter (%.2f sec)\n', history.status, history.iter, history.time);
%     fprintf('l1 = %.4f, RSS = %.2e\n',  history.l1, history.rss);    
%     fprintf('card = %u\n\n', history.card);
    
%     fprintf('finished in \t');
%     FormatTime( toc(tss) );
end

function p = objective(A, b, lambda, x, z)
    p = ( 1/2*sum((A*x - b).^2) + norm(lambda.*z,1) );
end

function z = shrinkage(x, kappa)
    z = max( 0, x - kappa ) - max( 0, -x - kappa );
end
    