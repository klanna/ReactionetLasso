function AICandSSplot( card, ic, fdr, titlenames, FileName)
% A = [Nlines, Nsubplots];
% titlename = {Nsubplots}
    fprintf('AICandSSplot\n');
    PaperFonts
    
    figname = 'AICandSSplot';
    fig = figure('Name', figname, 'visible', 'off');

    [~, iic] = min(ic);
    
    N = 5;
    x1 = min(card) - 1;
    x2 = max(card) + 1;
    StepX = max(1, round((x2-x1)/N));
    
    ic1 = min(ic)-1;
    ic2 = max(ic)+1;
    subplot(2, 1, 1)
    plot(card, ic, '-', 'color', 'black', 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
    hold on
    plot([card(iic) card(iic)], [ic1 ic2], ':', 'color', 'black', 'MarkerSize', 1, 'LineWidth', 1)
    box on
    title(titlenames{1})
    ylim([ic1 ic2])
    xlim([x1 x2])
    xlabel('card')
    ylabel('IC')
    set(gca,'XTick',[x1:StepX:x2], 'FontSize', FSize)
    
    fdr1 = min(min(fdr))-1;
    fdr2 = max(max(fdr))+1;
    subplot(2, 1, 2)
    plot(card, fdr(:, 1), '-', 'color', 'red', 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
    hold on
    plot(card, fdr(:, 2), '-', 'color', 'blue', 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
    hold on
    plot([card(iic) card(iic)], [fdr1 fdr2], ':', 'color', 'black', 'MarkerSize', 1, 'LineWidth', 1)
    box on
    title(titlenames{2})
    ylim([fdr1 fdr2])
    xlim([x1 x2])
    xlabel('card')
    ylabel('FDR')
    legend({'TP', 'FP'}, 'location', 'northwest', 'FontSize', FSize)
    set(gca,'XTick',[x1:StepX:x2], 'FontSize', FSize)
    
    size1 = 12;
    size2 = size1/2;
    PDFprint(FileName,  fig, size1, size2);
end

