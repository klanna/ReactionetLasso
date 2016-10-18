function CompareTrueFalsePos( A, titlename, LegendNames, FileName)
% A = [Nlines, Nsubplots];
% titlename = {Nsubplots}
    fprintf('CompareTrueFalsePos\n');
    PaperFonts
    LineSymb = {'-', '--', ':', '-.', ':', '-.', ':', '-.',':', '-.',':', '-.',':', '-.'};
    
    [Nsubplots] = length(A);
    
    switch Nsubplots
        case 1
            size1 = 4;
            size2 = 4;
        case 2
            size1 = 8;
            size2 = 4;
        case 3
            size1 = 8;
            size2 = 3;
    end

    figname = 'CompareTrueFalsePos';
    fig = figure('Name', figname, 'visible', 'on');
    for i = 1:Nsubplots
        subplot(1, Nsubplots, i)
        MM = A{i};
        Nlines = length(MM);
        for j = 1:Nlines
            M = MM{j};
            M_fp = M(:, 2);
            M_tp = M(:, 1);
            plot(M_fp, M_tp, LineSymb{j}, 'color', MyColor(j, :), 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
            hold on
            m1x(j) = min(M_fp);
            m1y(j) = min(M_tp);
            m2x(j) = max(M_fp);
            m2y(j) = max(M_tp);
        end

        box on
        axis square
        title(titlename{i})
        if ~isempty(LegendNames{i})
            legend(LegendNames{i}, 'location', 'southeast', 'FontSize', FSize);
        end
        
        StepX = max(1, round((max(m2x) - min(m1x))/5));
        StepY = max(1, round((max(m2y) - min(m1y))/5));
%         StepY = 2;
        StepX = 5;
        
        maxx = max(m2x);
        minx = min(m1x);
        
        maxy = max(m2y);
%         maxy = 12;
        miny = min(m1y);
%         miny = 0;
        
        ylim([miny-1 maxy+1])
        xlim([minx-1 min(30, maxx+1)])

        xlabel('False Positive')
        ylabel('True Positive')
        set(gca,'XTick',[minx:StepX:maxx], 'FontSize', FSize)
        set(gca,'YTick',[miny:StepY:maxy], 'FontSize', FSize)
    end
    size1 = 8;
    size2 = size1;
    PDFprint(FileName,  fig, size1, size2);
end

