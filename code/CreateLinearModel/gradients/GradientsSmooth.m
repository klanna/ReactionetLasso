function [Ech, Vch, Cch] = GradientsSmooth(fpath, ModelName, ch)  
    fprintf('%s chunk %u ...\t', ModelName, ch);
    ts = tic;
    load(sprintf('%s/data/%s/DataInChunks/%s_Data_%u.mat', fpath, ModelName, ModelName, ch))
    N_sp = size(data, 2);
    Ech = mean(data, 3)'; 
    Vch = var(data, 0, 3)';
    l = 0;
    for sp = 1:N_sp
        for j = (sp+1):N_sp
           l = l+1;
           Cch(l, :)  = FastCovariance(squeeze(data(:, sp, :)), squeeze(data(:, j, :)));
        end
    end
    fprintf('%.2f sec\n', toc(ts));
end