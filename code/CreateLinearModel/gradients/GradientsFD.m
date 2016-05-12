function [ dE, MomFull ] = GradientsFD(MomFull, Timepoints)
% Prepares gradients with finite difference scheme
    for i = 1:size(MomFull, 1)
        dy = FDSgradient(MomFull(i, :), Timepoints);
        dE(i, :) = dy(2:end);
    end
    
end
