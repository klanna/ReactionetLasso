function [constr, PriorGraph] = ReadConstraints( FolderNames, stoich )
    N_re = size(stoich, 2);
    constr = zeros(N_re, 1);
    if ~strcmp(FolderNames.Prior, '' )
        PriorGraph = load(sprintf('%s/%s.mat', FolderNames.Data, FolderNames.Prior)); %load prior graph
        idx = [];
        S = PriorGraph.PriorStoich;
        %%
        for i = 1:size(S, 2)
            st = S(:, i)';
            ii = find(ismember(stoich', st,'rows'));
            if ~isempty(ii)
                idx(end + 1) = ii;
            else
                fprintf('Constraint not found!\n');
            end
        end
        %%
        fprintf('%u constraints\n', length(idx));
        constr(idx) = 1e-8;
        PriorGraph.indx = idx;
    else
        PriorGraph.indx = [];
    end
end

