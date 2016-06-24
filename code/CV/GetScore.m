function [xscore, ReNumList] = GetScore( FolderNames, ModelParams )
    if ~exist(FolderNames.Results, 'dir')
        mkdir(FolderNames.Results)
    end
    FileNameOut = sprintf('%s/ReactionFrequency.mat', FolderNames.Results);
    if ~exist(FileNameOut, 'file')
        Ncv = 5;
        load(sprintf('%s/%s.mat', FolderNames.Data, FolderNames.PriorTopology));

        N_re = size(stoich, 2);

        ReactionFrequency = zeros(N_re, Ncv);

        for cv = 1:Ncv
            FolderNamesCV = FolderNamesFun( FolderNames.ModelName, cv, ModelParams );
            load(sprintf('%s/StepLASSO.mat', FolderNamesCV.ResultsCV));

            indxPosOld = [];

            TotalLam = 0;
            for i = 1:length(StatLassoLL)
                x_hat = StatLassoLL(i).xOriginal;
                indxPos = find(x_hat);
                if ~isequal(indxPos, indxPosOld)
                    TotalLam = TotalLam + 1;
                    ReactionFrequency(indxPos, cv) = ReactionFrequency(indxPos, cv) + 1;
                end
                indxPosOld = indxPos;
            end

            ReactionFrequency(:, cv) = ReactionFrequency(:, cv) / TotalLam;
        end

        [xscore, ReNumList] = GetXscore(ReactionFrequency);    
        
        save(FileNameOut, 'xscore', 'ReNumList')
    else
        load(FileNameOut)
    end
end


function [xscore, ReNumList] = GetXscore(ReactionFrequency)
    ReactionFrequencyTotal = mean(ReactionFrequency, 2);
    
    [xscore, ReNumList] = sort(ReactionFrequencyTotal, 'descend'); % sort reactions according to frequency
    indx0 = find(xscore == 0);
    xscore(indx0) = [];
    ReNumList(indx0) = [];
    N_re = length(xscore);
    
    fprintf('Totally %u non-zero reactions\n', N_re);
end