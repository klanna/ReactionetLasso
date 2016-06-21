function [ bH, bStdEps, values ] = NoiseNormalization( bStdEps, b, indx_I, values, varargin)
%  b-cov weightening
% bStdEps - vector of Standart Deviations of Of Noise in regression problem
% b - response
% indx_I, values - design matrix
    if ~isempty(varargin)
        eps = varargin{1};
    else
        eps = 1e-8;
    end
    tsld = tic;
%     fprintf('NoiseNormalization (b-cov weightening)...\t');
        
    bStdEps(bStdEps < eps) = 1; % replace '0' with 1
%     
    bH = VertVect(b) ./ VertVect(bStdEps);
    values = WeightSparseMatrix( indx_I, values, 1 ./ bStdEps);
    
%     fprintf('%.2f sec\n', toc(tsld));
end

