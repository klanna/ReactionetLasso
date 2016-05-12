function [BestSol1, BestSol2, CVFoldFrequency, ReactionFrequencyTotal] = CVassembly( ModelName, N_ch, TPModel, GradientType, ModelAugmentName, ModelAugmentList, NMom, StochDetFlag, Nboot )
    % reconstructs results from differnt CV sets
    M_tp = [];
    M_fp = [];
    StepNum = 2;
    
    LTotal = 0;
    for cv = 1:5
        SolverType = sprintf('_5CV_%u', cv);
        FolderNames = FNamesFun( ModelName, N_ch, TPModel, GradientType, ModelAugmentName, ModelAugmentList, NMom, StochDetFlag, Nboot, SolverType );
        ResFolder = sprintf('%s/S_%u/', FolderNames.Res3, StepNum);
        fname = sprintf('%s_S%u', FolderNames.SysName, StepNum);
        FileName = sprintf('%s/%s', ResFolder, fname);
        load(sprintf('%s.mat', FileName))
        tmp = unique([StatLassoLL.TP; StatLassoLL.FP]', 'rows');
        M_tp = [M_tp; tmp(:, 1)];
        M_fp = [M_fp; tmp(:, 2)];
        LTotal(cv) = length(StatLassoLL);
        ReactionFrequency(:, cv) = zeros(length(StatLassoLL(1).xOriginal), 1);
        for l = 1:length(StatLassoLL)
            x_hat = StatLassoLL(l).xOriginal;
            indx = find(x_hat);
            ReactionFrequency(indx, cv) = ReactionFrequency(indx, cv) + 1;
        end
    end
    ReactionFrequencyBin = ReactionFrequency;
    ReactionFrequencyBin(find(ReactionFrequencyBin)) = 1;
    CVFoldFrequency = sum(ReactionFrequencyBin') / 5;
    ReactionFrequencyTotal = sum(ReactionFrequency')/sum(LTotal);
    [~, iCVFoldFrequency] = sort(CVFoldFrequency, 'descend');
    [xscore, iReactionFrequencyTotal] = sort(ReactionFrequencyTotal, 'descend');
    
    load(sprintf('%s/Topology.mat', FolderNames.Data0))
    if strcmp(ModelAugmentName, 'NoAugmentation')
        PriorList = [];
    else
        PriorGraph = load(sprintf('%s/PriorGraph/PriorGraph_%u.mat', FolderNames.Data0, ModelAugmentList)); %load prior graph
        PriorList = PriorGraph.indx;
    end
    
    OutFolder = sprintf('%s/%s/', FolderNames.Data01);
    
    BestSol = CVFoldFrequency;
    BestSol(find(BestSol < 	1)) = 0;
    fprintf('CVFoldFrequency = %u reactions\n', length(find(BestSol)));
    [indx, TPList, FPList] = SplitReactions(BestSol, k);
%     PrintGraphWithScore( sprintf('%s/CV_fold', OutFolder), stoich(:, sort(indx)), SpeciesNames, TPList, FPList, PriorList, BestSol);
    BestSol1 = BestSol;
    
    dS = abs(diff(xscore));
    [~, idS] = max(dS);
    cutoff = xscore(idS + 1);
    ibest = max(find(xscore > cutoff));
    indxBest = iReactionFrequencyTotal(find(xscore > cutoff));
    BestSol = zeros(size(ReactionFrequencyTotal));
    BestSol(indxBest) = ReactionFrequencyTotal(indxBest);
    fprintf('ReactionFrequencyTotal = %u reactions\n', length(find(BestSol)));
    [indx, TPList, FPList] = SplitReactions(BestSol, k);
    PrintGraphWithScore( sprintf('%s/CV_fold', OutFolder), stoich(:, sort(indx)), SpeciesNames, TPList, FPList, PriorList, BestSol);
    BestSol2 = BestSol;
    
    StabilitySelectionPlot( FolderNames, ModelName, M_tp, M_fp);
    
    xscore(find(xscore == 0)) = [];
    kMax = length(find(k));
    TPflag = ones(length(xscore), 1);
    for i = 1:length(xscore)
        xset = iReactionFrequencyTotal(1:i);
        tp(i) = length(find(xset <= kMax));
        fp(i) = length(find(xset > kMax));
        if iReactionFrequencyTotal(i) > kMax
            TPflag(i) = 0;
        end
    end
    ipos = find(TPflag);
    
    figname = 'ReactionScore';
    fig = figure('Name', figname);
    SetMyPaperColors
    SetMyLines
        
    subplot(1, 2, 1)
    plot(xscore, '-o', 'color', MyColor(2, :), 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
    hold on
    plot(ipos, xscore(ipos),'o', 'color', MyColor(1, :), 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
    hold on
    eps = abs(xscore(ibest) - xscore(ibest + 1))/ 3;
    plot([0 length(xscore)], [xscore(ibest) - eps xscore(ibest) - eps], ':', 'color', 'black', 'MarkerSize', MarkerSize, 'LineWidth', lwidth/3)
    
    title(ModelName)
    xlim([0 length(xscore)+1])
    axis square
    box on
    ylabel('score')
    set(gca,'XTick',[0:5:length(xscore)], 'FontSize', FSize)
    
    subplot(1, 2, 2)
    plot(fp, tp, '-o', 'color', MyColor(2, :), 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
    hold on
    plot(fp(ibest), tp(ibest),'x', 'color', 'black', 'MarkerSize', MarkerSize*2, 'LineWidth', lwidth)
    xlim([min(fp)-1 max(fp)+1])
    ylim([min(tp)-1 max(tp)+1])
    set(gca,'XTick',[min(fp):4:max(fp)], 'FontSize', FSize)
    set(gca,'YTick',[min(tp):1:max(tp)], 'FontSize', FSize)
    title(ModelName)
    xlabel('False Positive')
    ylabel('True Positive')
    axis square
    box on
    PDFprint(sprintf('%s/%s', FolderNames.Res0, figname),  fig, 8, 4);
    
    save(sprintf('%s/%s', FolderNames.Res0, figname), 'xscore', 'tp', 'fp', 'ibest')
end

