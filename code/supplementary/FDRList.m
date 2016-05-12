function [ indxFDR, indxFDRname ] = FDRList( kest, ktrue )
    indx_TRUE = find(ktrue);
    indx_notTRUE = find(ktrue == 0);
    
    indx_EST = find(kest);
    indx_notEST = find(kest == 0);
    %%
    indxFDRname = {'TP', 'FP', 'FN', 'TN'};
    indxFDR{1} = intersect(indx_EST, indx_TRUE); % true positives
    indxFDR{2} = intersect(indx_EST, indx_notTRUE); % false positives
    indxFDR{3} = intersect(indx_notEST, indx_TRUE); % false negative
    indxFDR{4} = intersect(indx_notEST, indx_notTRUE); % true negative
end

