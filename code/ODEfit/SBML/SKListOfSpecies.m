function [ fileID ] = SKListOfSpecies( fileID, initialAmount)
    fprintf(fileID, '\n\t<SpeciesList>\n');
    for i = 1:length(initialAmount)
        fprintf(fileID, '\t\t<Species>\n');
        fprintf(fileID, '\t\t\t<Id>S%u</Id>\n', i);
        fprintf(fileID, '\t\t\t<InitialPopulation>%u</InitialPopulation>\n', initialAmount(i));
        fprintf(fileID, '\t\t</Species>\n');
    end
    fprintf(fileID, '\t</SpeciesList>\n');
end

