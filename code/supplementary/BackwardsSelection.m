function [ x, MSEscore, card, Ctime ] = BackwardsSelection( Aw, b, weights )
    ts = tic;
    
    Ndays = 2;
    MaxTimeS = Ndays*24*60*60;
    fprintf('Compute maximum %u days\n', Ndays);
    
    N_re = size(Aw, 2);
            
    l = 1;
    x(:, l) = lsqnonneg(Aw, b) ./ weights;
    Ctime(l) = toc(ts);
    MSEscore(l) = sum((b - Aw*(x(:, l).*weights)).^2);
    card(l) = length(find(x(:, l)));
    indx_l = find(x(:, l));
        
    while ~isempty(indx_l) && (Ctime(end) < MaxTimeS)
        l = l+1;
        clear score x_l indx_j
        x_l = zeros(N_re, length(indx_l)); % l-th step
        score = zeros(length(indx_l), 1);
        
        for j = 1:length(indx_l)
            indx_j = indx_l;
            indx_j(j) = [];
            x_l(indx_j, j) = lsqnonneg(Aw(:, indx_j), b) ./ weights(indx_j);
            score(j) = sum((b - Aw*(x_l(:, j).*weights)).^2);
        end
        
        [~, jbest] = min(score);
        x(:, l) = x_l(:, jbest);
        card(l) = length(find(x(:, l)));
        MSEscore(l) = score(jbest);
        indx_l(jbest) = [];
        Ctime(l) = toc(ts);
    end
    
end

