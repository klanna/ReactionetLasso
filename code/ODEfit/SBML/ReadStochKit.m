function TrajectSK = ReadStochKit( FolderName, FileName, N_tr, Timepoints)
%READSTOCHKIT Summary of this function goes here
%   Detailed explanation goes here
    for i = 1:N_tr
        filename = strcat(FolderName, 'SK_', FileName, '_output/trajectories/trajectory', num2str(i-1), '.txt');
        d = importdata(filename);
        timepoints = d(:, 1);
        d(:, 1) = [];
        indx = MatchIndexTimeVStime(Timepoints, timepoints);
        TrajectSK(:, :, i) = d(indx, :);
    end
end

