function [ fileID ] = ListOfReactions( fileID, stoich, SpeciesNames)
    [~, N_re] = size(stoich);
    fprintf(fileID, '<listOfReactions>\n');
    for i = 1:N_re
        OneReaction(fileID, i, stoich(:, i), SpeciesNames);
    end
    fprintf(fileID, '</listOfReactions>\n');
end

function status = OneReaction(file_id, Id, StoichVec, SpeciesNames)
    fprintf(file_id, '<reaction id="R%u" reversible="false" fast="false">\n', Id);
    
    fprintf(file_id, '<listOfReactants>\n');
    for i = 1:length(StoichVec)
        if StoichVec(i) == -1
            fprintf(file_id, '\t<speciesReference species="%s"/>\n', SpeciesNames{i});
        end
    end
    fprintf(file_id, '</listOfReactants>\n');

    fprintf(file_id, '<listOfProducts>\n');
    for i = 1:length(StoichVec)
        if StoichVec(i) == 1
            fprintf(file_id, '\t<speciesReference species="%s"/>\n', SpeciesNames{i});
        end
    end
    fprintf(file_id, '</listOfProducts>\n');

    fprintf(file_id, '<kineticLaw>\n');
    fprintf(file_id, '<math xmlns="http://www.w3.org/1998/Math/MathML">\n');
    fprintf(file_id, '<apply>\n');
    fprintf(file_id, '<times/>\n');
    
    fprintf(file_id, '<ci> k%u </ci>\n', Id);
    for i = 1:length(StoichVec)
        if StoichVec(i) == -1
            fprintf(file_id, '<ci> %s </ci>\n', SpeciesNames{i});
        end
    end

    fprintf(file_id, '</apply>\n');
    fprintf(file_id, '</math>\n');
    fprintf(file_id, '</kineticLaw>\n');
    fprintf(file_id, '</reaction>\n');
    
    status = sprintf('Done: %u', Id);
end

