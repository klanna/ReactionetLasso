function PlotScoreAndIC( foldername, figname, TitleName, IC, score, varargin)
    pic = 'on';
    if ~isempty(varargin)
        iIC = varargin{1};
    else
        [minIC, iIC] = min(IC);
    end
    FSize = 14;
    SetMyLines
    SetMyColors
    MarkerSize = MarkerSize*2;
    
    fig = figure('Name', figname, 'visible', pic);
    
    for i = 1:size(IC, 2);
        ICnorm(:, i) = IC(:, i) - min(IC(:, i));
        if max(ICnorm(:, i))
            ICnorm(:, i) = ICnorm(:, i) / abs(max(ICnorm(:, i)));
        end
    end
    
    t = 1:length(ICnorm);
    Nticks = 5;
    
    MyColorYY = MyColor;
%     MyColorYY(2, :) = [160 160 160] /255;
%     MyColorYY(3, :) = [96 96 96] / 255;
    my2 = max(max(abs(ICnorm)));
    my1 = ceil(max(score));
    
    [hAx,hLine1, hLine2] = plotyy(t, score, t, ICnorm);
    
    for i = 1:length(hLine1)
        set(hLine1(i), 'color', MyColorYY(i, :), 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
    end
    
    for i = 1:length(hLine2)
        set(hLine2(i), 'color', MyColorYY(i+length(hLine1), :), 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
        hold on
    end
    hold on
    for i = 1:length(hLine2)
        hold on
        plot([iIC(i) iIC(i)], [0 my2], ':', 'color', MyColorYY(i+length(hLine1), :), 'LineWidth', 2)
    end
    hold on 
    
%     plot([iIC iIC], [0 my1], ':', 'color', 'black', 'LineWidth', 1)
   
    ylabel(hAx(1), 'recation score')
    ylabel(hAx(2), 'IC') 
    
    xlim(hAx(1), [1 length(ICnorm)])
    xlim(hAx(2), [1 length(ICnorm)])
    ylim(hAx(1), [0 my1])
    ylim(hAx(2), [0 my2])
    
    set(hAx(1),'YTick',[0:my1/Nticks:my1], 'FontSize', FSize, 'YColor', MyColorYY(1, :))
    set(hAx(2),'YTick',[0:my2/Nticks:my2], 'FontSize', FSize, 'YColor', MyColorYY(4, :))
    legend('score', 'optimal mse', 'optimal BIC', 'optimal AIC', 'mse', 'BIC', 'AIC', 'location', 'southoutside','Orientation','horizontal')
    
    box on
    xlabel('number of reactions')
    set(get(gca,'xlabel'),'FontSize', FSize);
    set(get(gca,'ylabel'),'FontSize', FSize);
    set(get(gca,'title'),'FontSize', FSize, 'FontWeight', 'Bold');
%     axis square
    
    title(TitleName)
    PDFprint(sprintf('%s/%s', foldername, figname),  fig, 11, 8);
end

