function [xscore, ReNumList] = GetScoreSS( FolderNames, ModelParams )
    if ~exist(FolderNames.Results, 'dir')
        mkdir(FolderNames.Results)
    end
    FileNameOut = sprintf('%s/ReactionFrequency.mat', FolderNames.Results);
%     if ~exist(FileNameOut, 'file')
        Ncv = 5;
        load(sprintf('%s/%s.mat', FolderNames.Data, FolderNames.PriorTopology));

        N_re = size(stoich, 2);

        ReactionFrequency = zeros(N_re, Ncv);

        for cv = 1:Ncv
            FolderNamesCV = FolderNamesFun( FolderNames.ModelName, cv, ModelParams );
            load(sprintf('%s/StepStabilitySelection.mat', FolderNamesCV.ResultsCV));
            ReactionFrequency(:, cv) = mean(FreqX, 2);
        end
        
        ReactionFrequencyTotal = mean(ReactionFrequency, 2)*Ncv;
        if strcmp(FolderNames.connect, 'connected') 
            ReactionFrequencyTotal = CheckConnected( stoich, ReactionFrequencyTotal );
        end
        
        [xscore, ReNumList] = GetXscore(ReactionFrequencyTotal/Ncv);

        fprintf('Start Stability Selection with %u reactions\n', length(find(xscore)));
        save(FileNameOut, 'xscore', 'ReNumList')

%     else
%         load(FileNameOut)
%     end
end


function [xscore, ReNumList] = GetXscore(ReactionFrequencyTotal)
    [xscore, ReNumList] = sort(ReactionFrequencyTotal, 'descend'); % sort reactions according to frequency
    indx0 = find(xscore == 0);
    xscore(indx0) = [];
    ReNumList(indx0) = [];
    N_re = length(xscore);
    
    fprintf('Totally %u non-zero reactions\n', N_re);
end