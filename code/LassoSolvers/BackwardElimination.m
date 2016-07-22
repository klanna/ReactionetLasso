function [ xBest, BestRSS, residualsBest] = BackwardElimination( A, b )
    [N_obs, N_re] = size(A);
    
    CurrentSet = 1:N_re;
%     fprintf('Nre= %u\n', N_re);
    
    BestRSS = [];
    xBest = [];
    residualsBest = [];
    while ~isempty(CurrentSet)
        % elimintate one reaction from CurrentSet
        clear rssCheck
        xCheck = zeros(N_re, length(CurrentSet));
        residualsCheck = zeros(N_obs, length(CurrentSet));
        for i = 1:length(CurrentSet)
            CheckSet = CurrentSet;
            CheckSet(i) = [];
            
            xCheck(CheckSet, i) = lsqnonneg(A(:, CheckSet), b);
            residualsCheck(:, i) = b - A*xCheck(:, i);
            rssCheck(i) = sum(abs(residualsCheck(:, i)));
        end
        [BestRSS(end+1), imin] = min(rssCheck);
        xBest(:, end+1) = xCheck(:, imin);
        residualsBest(:, end+1) = residualsCheck(:, imin);
        CurrentSet(imin) = [];
    end
end

