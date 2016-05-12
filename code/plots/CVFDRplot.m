function CVFDRplot( OutFolder, ModelName, mse, TPflag, xscore, FDRscore, ibestlist, ibestlistNames, varargin)
    tp = FDRscore(:, 1);
    fp = FDRscore(:, 2);
    
    pic = 'off';
    SetMyPaperColors
    SetMyLines
    FSize = 10;
    
    if ~isempty(varargin)
        fl = varargin{1};
    else
        fl = '';
    end
    
    figname = 'MSE';
    fig = figure('Name', figname, 'visible', pic);
    subplot(2,1,1)
    [~, imse] = min(mse);
    plot(log10(mse), 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
    hold on
    plot(imse, log10(mse(imse)), 'xblack', 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
    subplot(2,1,2)
    plot(tp, 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
    hold on
    plot(imse, tp(imse), 'xblack', 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
    PDFprint(sprintf('%s/%s', OutFolder, figname),  fig, 4, 4);
    
    indx0 = find(xscore == 0);
    xscore(indx0) = []; %cut 0-tail
    xscorefull = xscore;
    TPflag(indx0) = [];
    ipos = find(TPflag);
    figname = sprintf('ReactionScore%s', fl);
    fig = figure('Name', figname, 'visible', pic);
    subplot(1, 2, 1)
    semilogx(xscorefull, '-o', 'color', MyColor(2, :))
    hold on
    semilogx(ipos, xscorefull(ipos),'o', 'color', MyColor(1, :), 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
    hold on
    for i = 1:length(ibestlist)
        ibest = ibestlist(i);
        if ibest < length(ibestlist)
            eps = abs(xscorefull(ibest) - xscorefull(ibest + 1))/ 3;
        else
            eps = 0;
        end
        semilogx([1 length(xscorefull)], [xscorefull(ibest) - eps xscorefull(ibest) - eps], ':', 'color', MyColor(i+2, :), 'MarkerSize', MarkerSize, 'LineWidth', lwidth/3)
        hold on
    end
    hold on
    semilogx([1 length(xscorefull)], [xscorefull(imse) - eps xscorefull(imse) - eps], ':', 'color', 'black', 'MarkerSize', MarkerSize, 'LineWidth', lwidth/3)
    title(ModelName)
    xlim([1 length(xscorefull)+1])
    ylim([-0.02 1.02])
    axis square
    box on
    ylabel('stability score')
    xlabel('reaction indx (log-scale)')
    set(gca,'XTick',sort(unique([1 max(ibestlist) length(xscore) length(xscorefull)])), 'FontSize', FSize)
    set(gca,'YTick',[0:0.2:1], 'FontSize', FSize)
    
    subplot(1, 2, 2)
    plot(fp, tp, '-s', 'color', MyColor(2, :), 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
    hold on
    for i = 1:length(ibestlist)
        ibest = ibestlist(i);
        plot(fp(ibest), tp(ibest), 'o', 'color', MyColor(i+2, :), 'MarkerSize', length(ibestlist) - i + 1 + MarkerSize, 'LineWidth', lwidth)
        hold on
    end
%     hold on
%     plot(fp(imse), tp(imse), 'o', 'color', 'black', 'MarkerSize', MarkerSize*1.5, 'LineWidth', lwidth)
    xlim([min(fp)-2 max(fp)+1])
    ylim([min(tp)-2 max(tp)+1])
%     StepX = 5;
%     set(gca,'XTick',[min(fp):StepX:max(fp)], 'FontSize', FSize)
%     set(gca,'YTick',[min(tp):StepY:max(tp)], 'FontSize', FSize)
    title('Stabiity Selection')
    xlabel('False Positive')
    ylabel('True Positive')
    set(gca,'XTick',[0:10:length(fp)], 'FontSize', FSize)
    set(gca,'YTick',[0:2:length(tp)], 'FontSize', FSize)
    axis square
    box on
    legend(ibestlistNames, 'Location','southeast','FontSize',FSize);
    
    PDFprint(sprintf('%s/%s', OutFolder, figname),  fig, 8, 4);
end

