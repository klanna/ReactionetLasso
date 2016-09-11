function [ fileID ] = ListOfParameters(fileID, k )
    N_re = length(k);
    fprintf(fileID, '<listOfParameters>\n');
    for i = 1:N_re
        fprintf(fileID, '\t<parameter id="k%u" name="k%u" value="%1.3e"/>\n', i, i, k(i));
    end
    fprintf(fileID, '</listOfParameters>\n');
end
