function dE = FDSgradient(E, Timepoints)
    dEtmp = VertVect(diff(E)) ./ VertVect(diff(Timepoints));
    dEtmp(2:end+1) = dEtmp;
    N = length(dEtmp);
    for i = 1:(N-1)
        dE(i) = (dEtmp(i) + dEtmp(i+1))/2;
    end
    dE(N) = dEtmp(N);
end