function [ fileID ] = SKListOfReaction( fileID, stoich, k)
    [N_sp, N_re] = size(stoich);
    fprintf(fileID, '\n<ReactionsList>\n');
    for i = 1:N_re
        fprintf(fileID, '<Reaction>\n');
        OneReaction(fileID, i, stoich(:, i), k(i));
        fprintf(fileID, '</Reaction>\n');
    end
    fprintf(fileID, '</ReactionsList>\n');
end

function OneReaction(file_id, Id, StoichVec, k)
    fprintf(file_id, '\t<Id>R%u</Id>\n', Id);
    fprintf(file_id, '\t<Type>mass-action</Type>\n');
    fprintf(file_id, '\t<Rate>%1.1e</Rate>\n', k);
    
    fprintf(file_id, '\t<Reactants>\n');
    ReactantsList = find(StoichVec == -1);
    for i = 1:length(ReactantsList)
        fprintf(file_id, '\t\t<SpeciesReference id="S%u" stoichiometry="%d"/>\n', ReactantsList(i), abs(StoichVec(ReactantsList(i))));
    end
    fprintf(file_id, '\t</Reactants>\n');

    fprintf(file_id, '\t<Products>\n');
    ProductsList = find(StoichVec == 1);
    for i = 1:length(ProductsList)
        fprintf(file_id, '\t\t<SpeciesReference id="S%u" stoichiometry="%u"/>\n', ProductsList(i), StoichVec(ProductsList(i)));
    end
    fprintf(file_id, '\t</Products>\n');
end

