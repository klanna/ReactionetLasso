function [f, ROCc] = FDR( k, kest )
    indx_k = find(k);
    max_true_k = length(indx_k);
    
    indx_pos = find(kest);
    indx_neg = find(kest == 0);
    
    N = length(k);
    
    ROCc.TPList = zeros(N, 1);
    
    indxFP = setdiff(indx_pos, indx_k);
    indxTP = setdiff(indx_pos, indxFP);
    indxTN = setdiff(indx_neg, indx_k);
    indxFN = setdiff(indx_neg, indxTN);
    
    TP = length(indxTP); %1
    FP = length(indxFP); %-1
    FN = length(indxFN); %-2
    TN = length(indxTN); %0

    ROCc.TPList(indxTP) = 1;
    ROCc.TPList(indxFP) = 2;
    ROCc.TPList(indxFN) = 3;
    ROCc.TPList(indxTN) = 4;
    
    ROCc.Name{1} = 'TP';
    ROCc.Name{2} = 'FP';
    ROCc.Name{3} = 'FN';
    ROCc.Name{4} = 'TN';
    
    f(1) = TP;
    f(2) = FP;
    
    N_true = length(find(k));
    ROCc.TPR = TP / N_true;
    ROCc.FPR = FP / (N - max_true_k);
    
    ROCc.recall = TP / (TP + FN); 
    ROCc.precesion = TP / (TP + FP); 
    ROCc.accuracy = (TP + TN) / N;
end

