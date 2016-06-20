function [AdjMat, TPMat, FPMat, PMat, NodesProp] = CreateReactionGraphAdjMatrixScore( stoich, SpeciesNames, TPList, FPList, PriorList, ScoreList )
% creates adjacency matrix for representation 
% INPUT:
% stoich - stoichometry of the system (Mass Action)
% SpeciesNames - name of the nodes
% OUTPUT:
% AdjMat - directed adjacency matrix
% TPList
% FPList
% PriorList
    [N_sp, N_re] = size(stoich);
    AdjMat = zeros(N_sp, N_sp);
    TPMat = AdjMat;
    FPMat = AdjMat;
    PMat = AdjMat;
    
    NodesProp.OriNodes = 1:N_sp;
    NodesProp.TP = [];
    NodesProp.FP = [];
    
    l = 0;
    l_tp = 0;
    l_fp = 0;
    
    for re = 1:N_re
       s = stoich(:, re); % stoich vector of the system 
       if ~isempty(TPList)
           TPflag = ~isempty(find(TPList == re)); % true if TruePos reaction
       else
           TPflag = 0;
       end
       
       if ~isempty(FPList)
           FPflag = ~isempty(find(FPList == re));
       else
           FPflag = 0;
       end
       
       if ~isempty(PriorList)
           Pflag = ~isempty(find(PriorList == re));
       else
           Pflag = 0;
       end
       
%        A + B -> C, C -> A+B
       indx_sp_out = find(s == -1); % A, B
       indx_sp_in = find(s == 1); % C
       
%        find reverse reaction
       FlagReverse = 0;
       for i = (re-1):-1:1
           if isequal( stoich(:, i), -s)
               FlagReverse = i;
               break
           end
       end
       
       if FlagReverse
           sp_re = sp_new_list(FlagReverse);
           SpeciesNames{sp_re} = sprintf('%u,%u', i, re);
       else
           sp_re = length(SpeciesNames) + 1;
           l = l + 1;
           NodesProp.ReactNodes(l) = sp_re;
           SpeciesNames{sp_re} = sprintf('%u', re);
       end
       sp_new_list(re) = sp_re;
       
       if ScoreList(re)
           sc = 5*ScoreList(re);
       else
           sc = 1;
       end
       
       AdjMat(indx_sp_out, sp_re) = sc;
       AdjMat(sp_re, indx_sp_in) = sc;
       
       if TPflag
           TPMat(indx_sp_out, sp_re) = 1;
           TPMat(sp_re, indx_sp_in) = 1;
           l_tp =l_tp + 1;
           NodesProp.TP(l_tp) = sp_re;
       end
       
       if FPflag
           FPMat(indx_sp_out, sp_re) = 1;
           FPMat(sp_re, indx_sp_in) = 1;
           l_fp =l_fp + 1;
           NodesProp.FP(l_fp) = sp_re;
       end
       
       if Pflag
           PMat(indx_sp_out, sp_re) = 1;
           PMat(sp_re, indx_sp_in) = 1;
%            l_p =l_p + 1;
%            NodesProp.FP(l_p) = sp_new;
       end
       
    end
    
    NodesProp.Names = SpeciesNames;
    
    TPMat = sparse(TPMat);
    FPMat = sparse(FPMat);
    PMat = sparse(PMat);
    
end

