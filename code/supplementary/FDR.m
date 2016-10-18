function [f, ROCc] = FDR( ktrue, kest )
    indx_true_k = find(ktrue);
    max_true_k = length(indx_true_k);
    
    indx_pos_est = find(kest);
    indx_neg_est = find(kest == 0);
    
    N = length(ktrue);
    
    ROCc.TPList = zeros(N, 1);
    
    indxFP = setdiff(indx_pos_est, indx_true_k);
    indxTP = setdiff(indx_pos_est, indxFP);
    indxTN = setdiff(indx_neg_est, indx_true_k);
    indxFN = setdiff(indx_neg_est, indxTN);
    
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
    
    N_true = length(find(ktrue));
    ROCc.TPR = TP / N_true;
    ROCc.FPR = FP / (N - max_true_k);
    
    ROCc.recall = TP / (TP + FN); 
    ROCc.precesion = TP / (TP + FP); 
    ROCc.accuracy = (TP + TN) / N;
end

