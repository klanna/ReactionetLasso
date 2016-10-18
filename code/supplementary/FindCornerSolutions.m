function [ idx ] = FindCornerSolutions( FDRscore )
%%
    tp = FDRscore(:, 1);
    fp = FDRscore(:, 2);
    
    idx = [];
    
    while ~isempty(tp)
        mfp = min(fp);
        ifp = find(fp == mfp);
        mtp = max(tp(ifp));
        
        idx(end+1) = find(ismember(FDRscore, [mtp mfp],'rows'));
        
        indx_cut = find(tp <= mtp);
        tp(indx_cut) = [];
        fp(indx_cut) = [];
    end
end

