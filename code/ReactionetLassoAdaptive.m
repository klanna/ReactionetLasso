function ReactionetLassoAdaptive( ModelName, varargin )
% ReactionetLassoLocal runs Reactionet lasso procedure locally (without
% paralleliztion)
    Ncv = 5; % number of cross-validation folds
    
    for nset = 1:Ncv
        ReactionetLasso( ModelName, nset, gradient, varargin);
    end

    ReactionetLassoSS( ModelName, gradient, varargin);
end

