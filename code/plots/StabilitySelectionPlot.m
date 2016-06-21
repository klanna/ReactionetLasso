function StabilitySelectionPlot( M, titlename, iBestNames, FileName, iBest)
    fprintf('StabilitySelectionPlot\n');
    PaperFonts
    
    iBestShapes = {'o', 's', '+', 'o', 's', '+', 'o', 's', '+'};
    
    size1 = 6;
    size2 = size1;

    figname = 'StabilitySelectionPlot';
    fig = figure('Name', figname, 'visible', 'off');

    M_fp = M(:, 2);
    M_tp = M(:, 1);
    plot(M_fp, M_tp, '-', 'color', MyColor(1, :), 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
    hold on
    NBest = length(iBest);
    for i = 1:NBest
        plot(M_fp(iBest(i)), M_tp(iBest(i)), 'x', 'color',  MyColor(i+1, :), 'MarkerSize', MarkerSize*3, 'LineWidth', lwidth*3)
        hold on
    end
    
    m1x = min(M_fp);
    m1y = min(M_tp);
    m2x = max(M_fp);
    m2y = max(M_tp);

    box on
    axis square
    
    title(titlename)
%     legend(['Reactionet lasso', iBestNames], 'location', 'southeast', 'FontSize', FSize);
    legend(['Reactionet lasso', iBestNames], 'location', 'southeast', 'FontSize', FSize);

    StepX = max(1, round((m2x - m1x)/5));
    StepY = max(1, round((m2y - m1y)/5));

    ylim([min(m1y)-1 max(m2y)+1])
    xlim([min(m1x)-1 min(30, max(m2x)+1)])

    xlabel('False Positive')
    ylabel('True Positive')
    set(gca,'XTick',[m1x:StepX:m2x], 'FontSize', FSize)
    set(gca,'YTick',[m1y:StepY:m2y], 'FontSize', FSize)
        
    PDFprint(FileName,  fig, size1, size2);
end

