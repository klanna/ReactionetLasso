function [stoich, RunTimeS, RunTimeName ] = PrepareTopologyFull( FolderNames )
% ModelName - Name for the model output
    RunTimeName = 'PrepareTopology';
    fprintf('%s...\n', RunTimeName);
    
    tic
    FileName = sprintf('%s/Topology.mat', FolderNames.Data);
    FileNameCompartment = sprintf('%s/CompartmentList.mat', FolderNames.Data);
    
    if ~exist(FileName, 'file')
        load(sprintf('%s/data.mat', FolderNames.Data), 'SpeciesNames')
        if exist(FileNameCompartment, 'file')
            load(FileNameCompartment)
            stoich = GenerateMetaTopologyFull(SpeciesNames, CompartmentList);
        else
            stoich = GenerateMetaTopologyFull(SpeciesNames);
        end
        RunTimeS = toc;
        save(FileName, 'stoich', 'RunTimeS')
    else
        load(FileName)
    end
end

