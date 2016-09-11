function out_file_name = MakeStochKitfile( FolderName, FileName, stoich, k, initialAmount )
    if ~exist(FolderName, 'dir')
       mkdir(FolderName);
    end
    
    out_file_name = sprintf('%s/SK_%s.xml', FolderName, FileName)
    
    if ~exist(out_file_name, 'file')
        fileID = fopen(out_file_name, 'w');
        %%
        fprintf(fileID, '<Model>\n');
        fprintf(fileID, '\t<NumberOfReactions>%u</NumberOfReactions>\n', size(stoich, 2));
        fprintf(fileID, '\t<NumberOfSpecies>%u</NumberOfSpecies>\n', size(stoich, 1));

        SKListOfReaction(fileID, stoich, k);
        SKListOfSpecies( fileID, initialAmount);

        fprintf(fileID, '</Model>\n'); 
        fclose(fileID);
    end
end
