function [ OutFileName ] = CreateSBMLfile( file_name, stoich, k, SpeciesNames, initialAmount)
% Creates .xml file for specidfied reation network
% filename - full path and name to disered output file (without .xml)
% stoich - stoichometry of the network
% k - reaction rates
% SpeciesNames - Names of species in the network
% initialAmount - initiaal amounts of species
    OutFileName = strcat(file_name, '.xml');
    fileID = fopen(OutFileName, 'w');
    %% header
    fprintf(fileID, '<?xml version="1.0" encoding="UTF-8"?>\n');
    fprintf(fileID, '<sbml xmlns="http://www.sbml.org/sbml/level2/version4" level="2" version="4">\n');
    fprintf(fileID, '<annotation>\n');
    fprintf(fileID, '<SimBiology xmlns="http_//www.mathworks.com">\n');
    fprintf(fileID, '<Version Major="4" Minor="3" Point="0"/>\n');
    fprintf(fileID, '</SimBiology>\n');
    fprintf(fileID, '</annotation>\n');
    fprintf(fileID, '<model id="Rsub" name="Rsub">\n');
    fprintf(fileID, '<listOfCompartments>\n');
    fprintf(fileID, '\t<compartment id="cell" name="cell" size="1"/>\n');
    fprintf(fileID, '</listOfCompartments>\n');
    %%
    ListOfSpecies( fileID, SpeciesNames, initialAmount);
    ListOfParameters(fileID, k );
    ListOfReactions(fileID, stoich, SpeciesNames);
    fprintf(fileID, '</model>\n');
    fprintf(fileID, '</sbml>\n');
    
    fclose(fileID);
end
