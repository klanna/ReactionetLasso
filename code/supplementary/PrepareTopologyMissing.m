function [stoich, RunTimeS, RunTimeName ] = PrepareTopologyMissing( FolderNames )
% ModelName - Name for the model output
    RunTimeName = 'PrepareTopology';
    fprintf('%s...\n', RunTimeName);
    
    tic
    FileName = sprintf('%s/Topology.mat', FolderNames.Data);
    FileNameCompartment = sprintf('%s/CompartmentList.mat', FolderNames.Data);
    
    stoich = [];
    if ~exist(FileName, 'file')
        load(sprintf('%s/data.mat', FolderNames.Data), 'SpeciesNames')
        N_sp = length(SpeciesNames);
        for i = 1:N_sp
            for j = 1:N_sp
                if i ~= j
                    re = zeros(N_sp, 1);
                    re(i) = -1;
                    re(j) = 1;
                    stoich(:, end+1) = re;
                end
            end
        end
        RunTimeS = toc;
        save(FileName, 'stoich', 'RunTimeS')
    else
        load(FileName)
    end
end

