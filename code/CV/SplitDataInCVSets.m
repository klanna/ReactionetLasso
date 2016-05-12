function [ dataCV, dataCVValidation ] = SplitDataInCVSets( data, nset, varargin)
% prepares cross validation sets    
    Nsets = 5;
    if ~isempty(varargin)
        Nsets = varargin{1};
    end
    
    for i = 1:length(data)
        TrajectoriesFull = data{i};
        NF = size(TrajectoriesFull, 2);
        N =  floor(NF / Nsets);

        if nset == 5
            SetIndx = [1 + (nset-1)*N:NF];
        else
            SetIndx = [1 + (nset-1)*N:nset*N];
        end
        Trajectories = TrajectoriesFull;
        Trajectories(:, SetIndx) = [];
        TrajectoriesValidation = TrajectoriesFull(:, SetIndx);
        dataCV{i} = Trajectories;
        dataCVValidation{i} = TrajectoriesValidation;
    end
end

