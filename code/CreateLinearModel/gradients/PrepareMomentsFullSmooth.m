function [GradientsMomentsSmooth, MomentsSmooth] = PrepareMomentsFullSmooth( FolderNames)
% Prepares a folder 'Moments' with all moments for full data splitted in
% chuncks
% ModelName - name of your model (ex. ARS)
% N_ch - number of chunks of trajectories to use
% First attempts to compute in parallel for every chunk
% IMPORTANT: Size of each chunk = 1000 !!!
    OutFileName = sprintf('%s/data/%s/MomentsFullSmooth.mat', FolderNames.fpath, FolderNames.ModelName);
    
    if ~exist(OutFileName, 'file')
        fprintf('PrepareMomentsFullSmooth %s%uk...\n', FolderNames.ModelName, FolderNames.N_ch);
        ts = tic;
        for ch = 1:FolderNames.N_ch
            [EchN(:, :, ch), VchN(:, :, ch), CchN(:, :, ch)] = GradientsSmooth(FolderNames.fpath, FolderNames.ModelName, FolderNames.ch); 
        end

        [E, V, C] = AssemblyGradientsSmoothHeavy(EchN, VchN, CchN);
        load(sprintf('%s/data/%s/DataInChunks/Info.mat', FolderNames.fpath, FolderNames.ModelName))
        Moments = [E ; V; C];

        h = mean(diff(timepoints));
        % MEAN
        for i = 1:size(Moments, 1)
            [GradientsMomentsSmooth(i, :), MomentsSmooth(i, :)] = SmoothGradientProcedure(Moments(i, :), h);
        end      
        RunTimeS = toc(ts);

        save(OutFileName, '-v7.3', 'Moments', 'GradientsMomentsSmooth', 'MomentsSmooth', 'RunTimeS')
        FormatTime( RunTimeS, 'PrepareMomentsFullSmooth finished in ' );
    else
        load(OutFileName, 'GradientsMomentsSmooth', 'MomentsSmooth')
    end
end


function [E, V, C] = AssemblyGradientsSmoothHeavy(EchN, VchN, CchN) 
% Assembles data from chunks and prepares one covariance function 
    fprintf('AssemblyGradientsSmoothHeavy...\n');
    E = mean(EchN, 3);
    [N_sp, ~, N_ch] = size(EchN);
    
    for ch = 1:N_ch
        eps_ch(:, :, ch) = (squeeze(EchN(:, :, ch)) - E) .^2;
        l = 0;
        for sp = 1:N_sp
            for j = (sp+1):N_sp
                l = l+1;
                eps_ch_AB(l, :, ch) = (squeeze(EchN(sp, :, ch)) - E(sp, :)) .* (squeeze(EchN(j, :, ch)) - E(j, :));
            end
        end
    end
    M = 1000;
    N = N_ch*M;
    V = (1 - (N_ch-1)/(N-1))*mean(VchN, 3) + N/(N-1)*mean(eps_ch, 3);
    C = (1 - (N_ch-1)/(N-1))*mean(CchN, 3) + N/(N-1)*mean(eps_ch_AB, 3);
end

function [GradientsMomentsSmooth, MomentsSmooth] = SmoothGradientProcedure(E, h)
    m_range = 30;
    MomentsSmooth = smooth(E, m_range);
    dE = gradient(MomentsSmooth, h);
    GradientsMomentsSmooth = smooth(dE, m_range);
end
