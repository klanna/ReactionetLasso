function [dataTR, dataVal, Timepoints, RunTimeS, RunTimeName] = ReadTrajectories( FolderNames )
%READTRAJECTORIES Summary of this function goes here
%   Detailed explanation goes here
    tic
    load(sprintf('%s/Data.mat', FolderNames.Data))
    RunTimeName = 'ReadTrajectories';
    fprintf('%s...\n', RunTimeName);
    
    if FolderNames.CV
        for t = 1:length(Timepoints)
             %         load(sprintf('%s/Trajectories%u.mat', FolderNames.Data, t))
    %         data{t} = Trajectories;
            Trajectories = data{t};
            if min(size(Trajectories)) > 1
                [TrainSet, ValidSet] = GetCVSetIndx(size(Trajectories, 2), FolderNames.CV);
                dataTR{t} = Trajectories(:, TrainSet); 
                dataVal{t} = Trajectories(:, ValidSet); 
            else
                dataTR{t}  = Trajectories;
                dataVal{t}  = Trajectories;
            end
        end
    else
        dataTR = data;
        dataVal = {};
    end
    RunTimeS = toc;
end

