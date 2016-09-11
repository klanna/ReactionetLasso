function [ dE, t, E ] = GradientsSplines(MomFull, Timepoints, GradientName)
% Prepares gradients with finite difference scheme
    for i = 1:size(MomFull, 1)
        switch GradientName
            case 'splines'
                [dE(i, :), ~, t, E(i, :)] = SplineGradient(VertVect(MomFull(i, :)), VertVect(Timepoints));
            case 'splines2'
                [dE(i, :), ~, t, E(i, :)] = SplineGradient2(VertVect(MomFull(i, :)), VertVect(Timepoints));
            case 'smooth'
                [dE(i, :), ~, t, E(i, :)] = SmoothSplineGradient(VertVect(MomFull(i, :)), VertVect(Timepoints));
        end
    end
end


