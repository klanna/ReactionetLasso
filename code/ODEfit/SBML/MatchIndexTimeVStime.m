function [ indx ] = MatchIndexTimeVStime( Timepoints, timepoints)
% find indexes of 'Timepoints'(short) in 'timepoints'(long)
    for i = 1:length(Timepoints)
       [d, ind] = min(abs(timepoints - Timepoints(i)));
       indx(i) = ind; 
    end
end