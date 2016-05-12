function [ dE, E ] = GradientsSplines(MomFull, Timepoints)
% Prepares gradients with finite difference scheme
    for i = 1:size(MomFull, 1)
        dE(i, :) = SplineGradient(VertVect(MomFull(i, :)), VertVect(Timepoints));
    end
end


