function [AdjMat, TPMat, FPMat, PMat, FNMat, NodesProp] = CreateReactionGraphAdjMatrixScore( stoich, SpeciesNames, TPList, FPList, PriorList, ScoreList, FNList )
% creates adjacency matrix for representation 
% INPUT:
% stoich - stoichometry of the system (Mass Action)
% SpeciesNames - name of the nodes
% OUTPUT:
% AdjMat - directed adjacency matrix
% TPList
% FPList
% PriorList

    
    ScalingConst = 4; % defines the width of the line
    
    [~, indxRe] = sort(ScoreList, 'descend');
    
    [N_sp, N_re] = size(stoich);
    ReFlag = zeros(N_re, 1);
    ReFlag(TPList) = 1;
    ReFlag(FPList) = 2;
    ReFlag(FNList) = 3;
    ReFlag(PriorList) = 4;
    
    AdjMat = zeros(N_sp, N_sp);
    
    TPMat = AdjMat;
    FPMat = AdjMat;
    FNMat = AdjMat;
    PMat = AdjMat;
    
    NodesProp.OriNodes = 1:N_sp;
    NodesProp.TP = [];
    NodesProp.FP = [];
    NodesProp.FN = [];
    
    l = 0;
    l_tp = 0;
    l_fp = 0;
    l_fn = 0;
    
    r = 0;
    sp_new_list = zeros(N_re, 1);
    for re = 1:N_re
       if ReFlag(re)
           s = stoich(:, re); % stoich vector of the system 

    %      A + B -> C, C -> A+B
           indx_reactants = find(s == -1); % A, B
           indx_products = find(s == 1); % C

    %      find reverse reaction
           FlagReverse = 0;
           for i = (re-1):-1:1
               if isequal( stoich(:, i), -s)
                   FlagReverse = i;
                   break
               end
           end

           if FlagReverse && sp_new_list(FlagReverse)
               sp_re = sp_new_list(FlagReverse);
               SpeciesNames{sp_re} = sprintf('%u,%u', find(indxRe == i), find(indxRe == re));
           else
               sp_re = length(SpeciesNames) + 1;
               l = l + 1;
               NodesProp.ReactNodes(l) = sp_re;
               SpeciesNames{sp_re} = sprintf('%u', find(indxRe == re));
           end
           r = r+1;
           sp_new_list(re) = sp_re;


           if ScoreList(re)
               sc = ScalingConst*ScoreList(re);
           elseif ScoreList(re) == min(ScoreList)
               sc = 0.5;
           end

           AdjMat(indx_reactants, sp_re) = sc;
           AdjMat(sp_re, indx_products) = sc;

           switch ReFlag(re)
               case 1
                   TPMat(indx_reactants, sp_re) = 1;
                   TPMat(sp_re, indx_products) = 1;
                   l_tp =l_tp + 1;
                   NodesProp.TP(l_tp) = sp_re;
               case 2
                   FPMat(indx_reactants, sp_re) = 1;
                   FPMat(sp_re, indx_products) = 1;
                   l_fp =l_fp + 1;
                   NodesProp.FP(l_fp) = sp_re;
               case 3
                   FNMat(indx_reactants, sp_re) = 1;
                   FNMat(sp_re, indx_products) = 1;
                   l_fn =l_fn + 1;
                   NodesProp.FN(l_fn) = sp_re;
               case 4
                   PMat(indx_reactants, sp_re) = 1;
                   PMat(sp_re, indx_products) = 1;
           end
       end
    end
    
    NodesProp.Names = SpeciesNames;
    
    TPMat = sparse(TPMat);
    FPMat = sparse(FPMat);
    FNMat = sparse(FNMat);
    PMat = sparse(PMat);
    
end

