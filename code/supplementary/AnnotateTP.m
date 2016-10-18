function [ idxTP ] = AnnotateTP( timepoints, Timepoints )
%% find closest timepoint 
    N_T = length(Timepoints);
    for i = 1:N_T
        t(i) = Timepoints(i);
        idxTP(i) = max(find((timepoints <= t(i))));
    end
end

