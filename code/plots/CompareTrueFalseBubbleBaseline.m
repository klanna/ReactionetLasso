function fig = CompareTrueFalseBubbleBaseline( A, figname, titlename, LegendNames, FileName, size1, size2, MyColorTF, Flag)
% A = {Nlines, Nsubplots};
% {LegendNames}
    PaperFonts
    LineSymbSp = {'s', 'o', 'd', 's', '>'};
    
    [Nlines, Nsubplots] = size(A);
    fig = figure('Name', figname, 'visible', 'on');
    ss = SubplotDimSelection(Nsubplots);
    lwidth = 2;
    y1 = 10^5;
    y2 = 0;
    
    for i = 1:Nsubplots
        subplot(ss(1), ss(2), i)
        for j = 1:Nlines
            AB = A{j, i};
            if Flag(i)
                for ii = 1:length(AB)
                    X = AB{ii};
                    plot(X(:, 2), X(:, 1), '-', 'color', MyColorTF(Nlines*(i-1)+ j, :), 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
                    hold on
                end
            else
                
                [uniqueAB, ~, n] = unique(AB, 'rows');
                nHist = hist(n, unique(n));
                mx = max(nHist);
                c = linspace(1/(2*mx), 1-1/(2*mx), mx); % Create scatter plot
                for r = 1:mx
                   a(nHist == r) = c(r)*100; 
                end
                scatter(uniqueAB(:, 2), uniqueAB(:, 1), a, MyColorTF(Nlines*(i-1)+ j, :), 'filled');
                hold on
                m1x(j) = min(AB(:, 2));
                m1y(j) = min(min(AB(:, 1)), y1);
                m2x(j) = max(AB(:, 2));
                m2y(j) = max(max(AB(:, 1)), y2);
                clear AB uniqueAB a
            end
            grid on
            set(gca, 'FontSize', FSize)
%             plot(AB(:, 2), AB(:, 1), LineSymb{j}, 'color', MyColorTF(j, :), 'MarkerSize', MarkerSize, 'LineWidth', lwidth)

        end
        set(gca, 'FontSize', FSize)
        box on
        axis square
        title(titlename{i})
        if ~isempty(LegendNames)
            if ~isempty(LegendNames{i})
%                 legend(LegendNames{i}, 'location', 'southeast', 'FontSize', FSize);
                legend(LegendNames{i}, 'location', 'southoutside', 'FontSize', FSize);
            end
        end
        
        N = 5;
        
        y1 = min(m1y);
        y2 = max(m2y);
%         y2 = 10;
        x1 = min(m1x);
        x2 = min(30, max(m2x));
        
        StepX = max(1, round(min(x2-x1)/N));
        StepX = 5;
        StepY = 2;
%         x2 = 50;
%         StepY = 1;

        ylim([-2 y2+1])
        xlim([-2 x2+1])

        xlabel('False Positive')
        ylabel('True Positive')
        set(gca,'XTick',[min(m1x):StepX:max(m2x)+1], 'FontSize', FSize)
        set(gca,'YTick',[0:StepY:y2+1], 'FontSize', FSize)
        
    end
    PDFprint(FileName,  fig, size1, size2);
end

