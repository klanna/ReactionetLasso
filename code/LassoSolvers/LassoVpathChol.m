function z_path = LassoVpathChol(A, b, rho, weights, N_sp, varargin)
% lasso  Solve lasso problem via ADMM with nonneg constrains
%
% [z, history] = lasso(A, b, lambda, rho, alpha);
%
% Solves the following problem via ADMM:
%
%   minimize 1/2*|| Ax - b ||_2^2 + \lambda || x ||_1
%   subject to x >= 0
    [m, n] = size(A);
    rho = 1;
    TolLASSO = 1e-8;
    MAX_ITER = 100000;
    LeftBorder = zeros(n, 1);

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
    n = size(A, 2);  

%% define lambda_list
    tsld = tic;
%     fprintf('define lambda_list...\n');
    lambda_max = norm( A'*b.*weights, 'inf' );
    lambda_max_log = ceil(log(lambda_max)); %         lambda_max_log = ceil(log2(lambda_max));
    lambda_list = sort(exp(-10:lambda_max_log), 'descend');%         
%     lambda_list = sort(2.^[-10:lambda_max_log], 'descend');    
    lambda_list(find(lambda_list > lambda_max)) = [];
    N_lambda = length(lambda_list);
%     fprintf('N_lambda = %u\nlambda_max = %e (e ^ %.0f)\n', N_lambda, lambda_max, lambda_max_log);%         fprintf('lambda_max = %e (2 ^ %.0f)\n', lambda_max, lambda_max_log);
%     fprintf('Found max_lambda in %.3f sec\n', toc(tsld));
    
%% ADMM solver
    fprintf('Lasso_chol started...\n');
    x = zeros(n, 1);%     
    z = zeros(n, 1);
    u = zeros(n, 1);
    
    [L U] = factor(A, rho);
    Atb = A'*b;
    
    lambda_i = 0;
    lambda_l = 0;
    z_path_card = 0;
    
%     while (lambda_i < N_lambda) && (z_path_card < N_sp*1.5)
    while (lambda_i < N_lambda) 
%     while (lambda_i < N_lambda) && (z_path_card < n)
        lambda_i = lambda_i + 1;
        ts = tic; % monitor single lambda
        status = 'Unsolved';
        lambda = lambda_list(lambda_i) ./ weights;
        lambda(find(LeftBorder)) = 0;
%         fprintf('lambda = e ^ (%.0f)\n', log(lambda_list(lambda_i)));
        
        for k = 1:MAX_ITER
            % x-update
            
            q = Atb + rho*(z - u);    % temporary value         
            if( m >= n )    % if skinny
               x = U \ (L \ q);
            else            % if fat
               x = q/rho - (A'*(U \ ( L \ (A*q) )))/rho^2;
            end  

        
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
                 status = 'Solved';
                 break;
            end

            % adjust rho
            if history.r_norm(k) > mu * history.s_norm(k)
                rho = rho * tau;
                u = u / tau;
                [L U] = factor(A, rho);
            elseif history.s_norm(k) > mu * history.r_norm(k)
                rho = rho / tau;
                u = u * tau;
                [L U] = factor(A, rho);
            end
        end
        
        lambda_l = lambda_l + 1;
        z_path(lambda_l).lambda = lambda_list(lambda_i);
        z_path(lambda_l).status = status;
        z_path(lambda_l).time = toc(ts);
        z_path(lambda_l).z = z;
        z_path(lambda_l).iter = k;
        z_path(lambda_l).card = length(find(z));
        z_path_card = z_path(lambda_l).card;
        z_path(lambda_l).l1 = sum( z ./ weights );  
        z_path(lambda_l).rss = 0.5 * sum((b - A*z).^2);

%         fprintf('%s: %u iter (%.2f sec)\n', z_path(lambda_l).status, z_path(lambda_l).iter, z_path(lambda_l).time);
%         fprintf('l1 = %.2e, RSS = %.2e\n',  z_path(lambda_l).l1, z_path(lambda_l).rss);    
    end
    
    fprintf('Lasso_LSQR finished in \t');
    FormatTime( toc(tss) );
end

function p = objective(A, b, lambda, x, z)
    p = ( 1/2*sum((A*x - b).^2) + norm(lambda.*z,1) );
end

function z = shrinkage(x, kappa)
    z = max( 0, x - kappa ) - max( 0, -x - kappa );
end

function [L U] = factor(A, rho)
    [m, n] = size(A);
    if ( m >= n )    % if skinny
       L = chol( A'*A + rho*speye(n), 'lower' );
    else            % if fat
       L = chol( speye(m) + 1/rho*(A*A'), 'lower' );
    end

    % force matlab to recognize the upper / lower triangular structure
    L = sparse(L);
    U = sparse(L');
end
    