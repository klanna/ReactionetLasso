function [ dE, t, E ] = GradientsSplines2(MomFull, Timepoints)
% Prepares gradients with finite difference scheme
    for i = 1:size(MomFull, 1)
        [dE(i, :), ~, t, E(i, :)] = SplineGradient2(VertVect(MomFull(i, :)), VertVect(Timepoints));
    end
end


