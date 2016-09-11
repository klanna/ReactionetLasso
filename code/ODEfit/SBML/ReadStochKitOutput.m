function [data, timepoints] = ReadStochKitOutput( FolderName )
%  FolderName = name of folder with files with trajectories
%  OUTPUT: data, timepoints

    AllFiles = dir( FolderName );
    FileNamesList = sort({ AllFiles(~[AllFiles.isdir]).name });
    N_Files = length(FileNamesList);
    
    if ~ N_Files
        fprintf('Empty folder!!!\n');
    else
        for i = 1:N_Files
            d = importdata(strcat(FolderName, FileNamesList{i}));
            timepoints = d(:, 1);
            data(:, :, i) = d(:, 2:end);
        end
    end
end

