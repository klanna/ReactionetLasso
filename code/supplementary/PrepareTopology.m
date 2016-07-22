function [stoich, RunTimeS, RunTimeName ] = PrepareTopology( FolderNames )
% ModelName - Name for the model output
    RunTimeName = 'PrepareTopology';
    fprintf('%s...\n', RunTimeName);
    
    tic
    FileName = sprintf('%s/%s.mat', FolderNames.Data, FolderNames.PriorTopology);
    FileNameCompartment = sprintf('%s/CompartmentList.mat', FolderNames.Data);
    
    if ~exist(FileName, 'file') || ~strcmp(FolderNames.PriorTopology, 'Topology')
        load(sprintf('%s/Data.mat', FolderNames.Data), 'SpeciesNames')
        if exist(FileNameCompartment, 'file')
            load(FileNameCompartment)
            stoich = GenerateMetaTopology(SpeciesNames, CompartmentList);
            save(FileName, 'stoich', 'RunTimeS')
        elseif strcmp(FolderNames.PriorTopology, 'Topology')
            stoich = GenerateMetaTopologyFromGraph(SpeciesNames);
            RunTimeS = 0;
            save(FileName, 'stoich', 'RunTimeS')
            
        else
            load(FileName)
            stoich = GenerateMetaTopologyFromDGraph(SpeciesNames, G);
            save(FileName, '-append', 'stoich')
        end
        RunTimeS = toc;
        
    else
        load(FileName)
    end
end

