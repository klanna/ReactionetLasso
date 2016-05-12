function [TrainSet, ValidSet] = GetCVSetIndx(Ncells, nset)
    Nsets = 5;
    N =  round(Ncells / Nsets); % size of the set
    if nset == 5
        ValidSet = [1 + (nset-1)*N:Ncells];
    else
        ValidSet = [1 + (nset-1)*N:nset*N];
    end
    TrainSet = setdiff([1:Ncells], ValidSet);
end