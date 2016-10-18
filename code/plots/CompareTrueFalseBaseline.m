function CompareTrueFalseBaseline( A, figname, titlename, LegendNames, MyColorTF, FileName, size1, size2, varargin)
%     MyColorTF = [228,26,28;
%                 55,126,184;
%                 77,175,74;
%                 152,78,163;
%                 255,127,0;
%                 255,255,51;
%                 166,86,40;
%                 247,129,191;
%                 153,153,153]/255;
    
    PaperFonts
    FSize = 10;
    lwidth = 3;
    MarkerSize = 3;
    LineSymb = '-';
    LineSymbSp = {'s', 'o', 'd', 's', '>'};
    
    [Nlines, Nsubplots] = size(A);
    fig = figure('Name', figname);
    for i = 1:Nsubplots
        subplot(1, Nsubplots, i)
        LegendNamesList = LegendNames{i};
        for j = 1:Nlines
            M = A{j, i};
            M_fp = M(:, 2);
            M_tp = M(:, 1);

            plot(M_fp, M_tp, LineSymb, 'color', MyColorTF(j, :), 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
            hold on
            m1x(j) = min(M_fp);
            m1y(j) = min(M_tp);
            m2x(j) = max(M_fp);
            m2y(j) = max(M_tp);
        end
        if ~isempty(varargin)
            iA = varargin{1};
            for j = 1:Nlines
                M = A{j, i};
                M_fp = M(:, 2);
                M_tp = M(:, 1);
                iM = iA{j, i};
                for r = 1:length(iM)
                    plot(M_fp(iM(r)), M_tp(iM(r)), LineSymbSp{r}, 'color', 'black', 'MarkerSize', MarkerSize + 2*r, 'LineWidth', lwidth/(2*r))
                    hold on
                end
            end
            set(gca,  'FontSize', FSize)
        end
        box on
        axis square
        title(titlename{i})
        if ~isempty(LegendNames{i})
            legend(LegendNames{i}, 'location', 'southeast', 'FontSize', FSize);
        end
%         
        N = 5;
        
        y1 = min(m1y)-1;
        y2 = max(m2y)+1;
        x1 = min(m1x)-1;
%         x2 = max(m2x)+1;
        x2 = min(m2x)+1;
        
        StepX = max(1, round(min(x2-x1)/N));
%         StepX = min(StepX, 5);
        StepY = 5;

        ylim([y1 y2])
        xlim([x1 min(x2)])

        xlabel('False Positive')
        ylabel('True Positive')
        set(gca,'XTick',[min(m1x):StepX:max(m2x)+1], 'FontSize', FSize)
        set(gca,'YTick',[min(m1y):StepY:max(m2y)+1], 'FontSize', FSize)
        set(get(gca,'title'),'FontSize', FSize, 'FontWeight', 'Bold');
    end
    PDFprint(FileName,  fig, size1, size2);
end

