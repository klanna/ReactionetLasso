function [b, bStd, RunTimeS, RunTimeSname, bBoot] = PrepareResponseVal( FolderNames, E, V, C, Timepoints, varargin)   
    RunTimeSname = 'PrepareResponseVal';
    
    if ~exist(FolderNames.LinSystem, 'dir')
        mkdir(FolderNames.LinSystem)
    end

    OutFileName = sprintf('%s/Response.mat', FolderNames.LinSystem);
    
%     if ~exist(OutFileName, 'file') || ~isempty(regexp(FolderNames.Gradients, 'ramsay'))
        ts = tic;
        fprintf('%s %s...\t', RunTimeSname, FolderNames.ModelName);
        if FolderNames.NMom == 2
            Mom = [E; V; C];
        else
            Mom = E;
        end
        MomW = std(Mom, 0, 3);
        MomW(MomW == 0) = 1;
        
        switch FolderNames.Gradients
            case 'FDS'
                for Sample = 1:size(E, 3)
                    dMom_sm = GradientsFD(squeeze(Mom(:, : , Sample)), Timepoints);
                    bBoot(:, Sample) = reshape(dMom_sm, [], 1);
                end
                b = bBoot(:, 1);
                bStd = std(bBoot, 0, 2);
            case 'perfect'
                b = varargin{1};
                bStd = ones(size(b));
            otherwise
                for Sample = 1:size(E, 3)
                    if ~isempty(varargin)
                        b_hat = reshape(varargin{1}, [], length(Timepoints)-1);
                        dMom_sm = GradientsSplines(squeeze(Mom(:, : , Sample)), Timepoints, 'adaptive', b_hat, MomW);
                    else
                        dMom_sm = GradientsSplines(squeeze(Mom(:, : , Sample)), Timepoints, FolderNames.Gradients);
                    end
                    bBoot(:, Sample) = reshape(dMom_sm, [], 1);
                end
                b = bBoot(:, 1);
                bStd = std(bBoot, 0, 2);   
        end
        
        RunTimeS = toc(ts);
        FormatTime( RunTimeS, ' finished in ' );
%     else
%         load(OutFileName)
%     end
end