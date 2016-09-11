function CreateNoiseSettingBinomial( ModelNameOld, p)
% creates folder with noisy data
% p - probability of success p in [0, 1]
    tic
    fpath = regexprep(pwd, 'ReactionetLasso/.*', 'ReactionetLasso/'); % path to the code-folder
    addpath(genpath(sprintf('%s/code/', fpath)));
    
    ModelNameNew = sprintf('%s%ubn', ModelNameOld, p*100);
    
    DataFolderOld = sprintf('%s/data/%s/', fpath, ModelNameOld);
    DataFolderNew = sprintf('%s/data/%s/', fpath, ModelNameNew);
    
    if ~exist(DataFolderNew, 'dir')
        mkdir(DataFolderNew)
    end
    
    copyfile(sprintf('%s/Topology.mat', DataFolderOld), sprintf('%s/Topology.mat', DataFolderNew))

    copyfile(sprintf('%s/TrueStruct.mat', DataFolderOld), sprintf('%s/TrueStruct.mat', DataFolderNew))
     
    load(sprintf('%s/Data.mat',  DataFolderOld))
    
    data{1} = p*data{1};
    for i = 2:length(data)
        data{i} = AddNoiseBinomial( data{i}, p );
    end
    
    save(sprintf('%s/Data.mat', DataFolderNew), 'Timepoints', 'data', 'SpeciesNames')
    toc
end

function TrajectoriesNoise = AddNoiseBinomial( Trajectories, p )
% adds normal noise to Trajectories
% p - Probability of success (%, ex, 1%, 100%) (default: 1 %)
    rng(2015);

    [N_sp, N_sample] = size(Trajectories);
    
    p_val = p*ones(1, N_sample);
    
    for sp=1:N_sp
        X = Trajectories(sp, :);
        n = mean(X);

        if (n*p > 10) && (n*(1-p) > 10)
            TrajectoriesNoise(sp, :) = max(0, normrnd(X.*p_val, sqrt(X.*p_val.*(1-p_val))));
        else
            TrajectoriesNoise(sp, :) = binornd(X, p_val);
        end
%             fprintf('X_%u(%u) %.2f sec\n', sp, t, toc(ts));
    end

end

