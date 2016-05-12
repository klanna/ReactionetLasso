function [ E, V, C, E2, C3, E12, RunTimeS, RunTimeName ] = PrepareMomentsFull( FolderNames )
    RunTimeName = 'PrepareMomentsFull';
    fprintf('%s...\n', RunTimeName);
    
    OutFileName = sprintf('%s/FullSet.mat', FolderNames.Moments);    
    load(sprintf('%s/Data.mat', FolderNames.Data), 'data')
    
    if ~exist(OutFileName, 'file')
        ts = tic;
        for t = 1:length(data)
            [ E(:, t), V(:, t), C(:, t), E2(:, t), C3(:, t), E12(:, t) ]= PrepareMomentsFromTrajectories( data{t}, 1 );
        end
        RunTimeS = toc(ts);
        save(OutFileName, 'E', 'V', 'C', 'E2', 'C3', 'E12', 'RunTimeS');
        FormatTime( RunTimeS, 'finished in ' );
    else
        load(OutFileName) 
    end        
        %% correction
    p = FolderNames.p;
    
    E = E / p;
    V = (V - (1-p)*p*E) / (p^2);
    C = C / (p^2);
    E2 = E2  / (p^2);
    C3 = C3 / (p^3);
    
    N_sp = size(E, 1);
    [Cmap] = CovMap(N_sp);
    l = 0;
    for i = 1:N_sp
        for j = 1:N_sp
            if i ~= j
                l = l+1;
                E12(l, :, :) = (E12(l, :, :) - (1-p)*E2(Cmap(i, j), :, :))/ (p^3);
            end
        end
    end
    

end

function [Cmap] = CovMap(N_sp)
    l = 0;
    l1 = 0;
    Cmap = zeros(N_sp, N_sp);
    for i = 1:N_sp
        for j = (i + 1):N_sp
            l = l+1;
            Cmap(i, j) = l;
            Cmap(j, i) = l;
        end
    end
end
