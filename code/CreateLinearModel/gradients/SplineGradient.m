function [dE, pp] = SplineGradient(y, x)    
    pp = spline(x,y); %fit cubic splines
    [breaks,coefs] = unmkpp(pp);
    
    for cc = 1:3
        dcoefs(:, cc) = (4-cc)*coefs(:, cc);
    end
    dpp = mkpp(breaks,dcoefs);
    
    dy_pp = VertVect(ppval(dpp,x));
    dEfds = VertVect(FDSgradient(y, x));
    dEfds(1) = [];
    
    dE = dy_pp(2:end);
    sgn_dE = sign(dE);
    sgn_dEfds = sign(dEfds);
    dif_sgn = find(sgn_dE .* sgn_dEfds == -1);
    dE(dif_sgn) = dEfds(dif_sgn);
    small_indx = [find(abs(dEfds) < 1e-3)];
    dE(small_indx) = dEfds(small_indx);
end

