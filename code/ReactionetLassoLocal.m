function ReactionetLassoLocal( ModelName, varargin )
% ReactionetLassoLocal runs Reactionet lasso procedure locally (without
% paralleliztion)
    for nset = 1:5
        ReactionetLasso( ModelName, nset, varargin);
    end
    ReactionetLassoSS( ModelName, varargin);
%     RunTopologicalFiltering( ModelName, varargin );
end

