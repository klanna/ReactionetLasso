function [ fileID ] = ListOfSpecies( fileID, SpeciesNames, initialAmount)
N_sp = length(SpeciesNames);
fprintf(fileID, '<listOfSpecies>\n');
for i = 1:N_sp
      fprintf(fileID, '\t<species id="%s" name="%s" compartment="cell" initialAmount="%u"/>\n', SpeciesNames{i}, SpeciesNames{i}, initialAmount(i));
end
fprintf(fileID, '</listOfSpecies>\n');
end

