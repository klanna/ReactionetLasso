function [constr, PriorGraph] = ReadConstraints( FolderNames, N_re )
    constr = zeros(N_re, 1);
    if ~strcmp(FolderNames.Prior, '' )
        PriorGraph = load(sprintf('%s/%s.mat', FolderNames.Data, FolderNames.Prior)); %load prior graph
        constr(PriorGraph.indx) = 1e-8;
    else
        PriorGraph.indx = [];
    end
end

