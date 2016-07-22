function [indxPos, bFull, sp_out_list, BestResStat, RunTimeS, RunTimeSname] = StepOLStakeOneSpecieOut(FolderNames, indx_I, indx_J, values, N_obs, N_re, b, constr, N_T, N_sp)
    RunTimeSname = 'StepOLStakeOneSpecieOut';
    fprintf('----------------StepOLStakeOneSpecieOut----------------\n');
    OutFolder = sprintf('%s/', FolderNames.ResultsCV);
    if ~exist(OutFolder, 'dir')
       mkdir(OutFolder) 
    end
    
    OutFileName = sprintf('%s/%s.mat', OutFolder, RunTimeSname);
    ts = tic;
    load(sprintf('%s/Data.mat', FolderNames.Data), 'SpeciesNames')
    
    load(sprintf('%s/%s.mat', FolderNames.Data, FolderNames.PriorTopology))
    load(sprintf('%s/TrueStruct.mat', FolderNames.Data))
    kTrue = AnnotateTrueReactions( k, stoichTR, stoich );
    
%     if ~exist(OutFileName, 'file')
    %% Only Means  
    pic = 'off';
        if FolderNames.NMom == 2
            [indx_I, indx_J, values, N_obs, N_re, EmptyIndx, NonEmptyIndx] = CutDesignRows(indx_I, indx_J, values, N_obs, N_re, N_sp, N_T);         
        else
            NonEmptyIndx = find(WeightsMask( N_sp, N_T, length(b), [1 0 0], 2 ));
        end
    %% weigth matrix
        [ values, weights ] = WeightDesignForRegression( indx_I, indx_J, values, N_obs, N_re );
        Aw = sparse(indx_I, indx_J, values, N_obs, N_re);
        bFull = b;
        b(EmptyIndx) = [];
    %% Model Augmentation      
        constrW = constr .* weights;  
%%      solver
        for tmp = 1:2
            for sp = 1:N_sp
                Mask = ones(N_sp, N_T);
                Mask(sp, :) = 0;
                SpMask = find(reshape(Mask, [], 1));
                xW = constrW + lsqnonneg(Aw(SpMask, :), b(SpMask) - Aw(SpMask, :)*constrW);
        %%      stats  
                BestResStat.xOriginal(:, sp) = xW ./ weights;
                BestResStat.b_hat(:, sp) = Aw*xW;
                BestResStat.b_hat_sp(:, sp) = Aw*xW;
                BestResStat.b_hat_sp(SpMask == 0, sp) = b(SpMask == 0);
                BestResStat.r(:, sp) = b - BestResStat.b_hat(:, sp);

                BestResStat.MSE2(sp) = norm(BestResStat.r(:, sp), 2);
                BestResStat.time(sp) = toc(ts);

                PlotScatterCons( kTrue, BestResStat.xOriginal(:, sp), RunTimeSname, sprintf('%s/%s_leave_%u', FolderNames.PlotsCV, RunTimeSname, sp), pic);
                
                PlotFitToLinearSystemMulti( b, BestResStat.b_hat(:, sp), N_T, N_sp, sprintf('%s/%s_leave_%u', FolderNames.PlotsCV, RunTimeSname, sp), pic, SpeciesNames);
                PlotFitToLinearSystemMulti( b, [ BestResStat.b_hat(:, sp) Aw*(kTrue .* weights)], N_T, N_sp, sprintf('%s/%s_leave_%u', FolderNames.PlotsCV, RunTimeSname, sp), pic, SpeciesNames);
    %             PlotFitToLinearSystemMulti( 1, b, BestResStat.b_hat, N_T, N_sp, sprintf('%s/%s_leave_%u', FolderNames.PlotsCV, RunTimeSname, sp), pic);
            end

            for sp_out = 1:N_sp
                for sp = 1:N_sp
                    Mask = zeros(N_sp, N_T);
                    Mask(sp, :) = 1;
                    SpMask = find(reshape(Mask, [], 1));
                    NormMatrx(sp, sp_out) = norm(BestResStat.r(SpMask, sp_out), 1);
                end
            end

            [~, imin] = min(NormMatrx');
            [freq,val]=hist(imin,unique(imin));
            [freqmax, ifr] = max(freq);
            sp_out = val(ifr);
            fprintf('Take out species %u (repeated %u times)\n', sp_out, freqmax);
            sp_out_list(tmp) = sp_out;
            Mask = zeros(N_sp, N_T);
            Mask(sp_out, :) = 1;
            SpMask = find(reshape(Mask, [], 1));
            b(SpMask) = BestResStat.b_hat(SpMask, sp_out);
        end
        
        bFull(NonEmptyIndx) = b;
%         figname = 'SpeciesOut';
%         fig = figure('Name', figname);
%         s = SubplotDimSelection(n_sp);
%         for i = 1:N_sp
%             subplot(s(1), s(2), i)
%             plot(NormMatrx())
%             hold on
%         end
%         NormMatrx
        
        PlotScatterCons( kTrue, max(BestResStat.xOriginal')', RunTimeSname, sprintf('%s/%s_leave_max', FolderNames.PlotsCV, RunTimeSname), pic);
        
        k0 = BestResStat.xOriginal;
        for i = 1:size(k0, 1)
            km(i) = mean(k0(i, find(k0(i, :))));
        end
        km(isnan(km)) = 0;

        indxPos = find(km);
        PlotScatterCons( kTrue, km, RunTimeSname, sprintf('%s/%s_leave_mean', FolderNames.PlotsCV, RunTimeSname), pic);

        PlotFitToLinearSystemMulti( b, BestResStat.b_hat, N_T, N_sp, sprintf('%s/%s_leave', FolderNames.PlotsCV, RunTimeSname), pic, SpeciesNames);
        PlotFitToLinearSystemMulti( b, [median(BestResStat.b_hat_sp, 2) Aw*(kTrue .* weights)], N_T, N_sp, sprintf('%s/%s_leave_median', FolderNames.PlotsCV, RunTimeSname), pic, SpeciesNames);
        PlotFitToLinearSystemMulti( b, [Aw*(max(BestResStat.xOriginal')' .* weights) Aw*(kTrue .* weights)], N_T, N_sp, sprintf('%s/%s_avg', FolderNames.PlotsCV, RunTimeSname), pic, SpeciesNames);
        
        RunTimeS = toc(ts);
        save(OutFileName, 'BestResStat', 'RunTimeS', 'NormMatrx', 'indxPos', 'bFull', 'sp_out_list', 'BestResStat', 'RunTimeS', 'RunTimeSname');      
        FormatTime( RunTimeS, 'StepOLStakeOneSpecieOut finished in ' );
        if ~exist(FolderNames.PlotsCV, 'dir')
            mkdir(FolderNames.PlotsCV)
        end
%     else
%         RunTimeS = toc(ts);
%         load(OutFileName);
%     end
end