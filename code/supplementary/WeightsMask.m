function WMask = WeightsMask( N_sp, N_T, N_b, w, NMom )
    N_mom = round(N_b/N_T);
    
    WMask = ones(N_b, 1);
    if NMom > 1
        for t = 1:N_T
            indx = [((t-1)*N_mom + 1): ((t-1)*N_mom + N_sp)];
            WMask(indx) = w(1);
            WMask(((t-1)*N_mom + N_sp+1):((t-1)*N_mom + 2*N_sp)) = w(2);
            WMask(((t-1)*N_mom + 2*N_sp+1):(t*N_mom)) = w(3);
        end
    end
end

