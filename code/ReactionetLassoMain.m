function ReactionetLassoMain( ModelName, varargin )
% ReactionetLassoLocal runs Reactionet lasso procedure locally (without
% paralleliztion)
    Ncv = 5; % number of cross-validation folds

    for nset = 1:Ncv
        ReactionetLasso( ModelName, nset, varargin);
    end

    ReactionetLassoSS( ModelName, varargin);
end

