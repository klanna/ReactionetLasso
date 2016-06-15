function [indxPos, TPList, FPList, PriorList ] = FDRgraph( xOpt, kTrue, PriorListIndx)
    indxPos = find(xOpt);
    indx_k = find(kTrue);
    
    if ~isempty(PriorListIndx)
        for p = 1:lenght(PriorListIndx)
            PriorList(p) = find(indxPos == PriorListIndx(p));
        end
    else
        PriorList = [];
    end

    FPList = [];
    FPList0 = setdiff(indxPos, indx_k);
    for j = 1:length(FPList0)
        FPList(j) = find(indxPos == FPList0(j));
    end

    TPList = [];
    TPList0 = setdiff(indxPos, FPList0);
    for j = 1:length(TPList0)
        TPList(j) = find(indxPos == TPList0(j));
    end

end

