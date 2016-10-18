function ROCPlot( MM, titlename, FileName, legendnames, varargin)
    fprintf('ROCPlot\n');
    PaperFonts
    
    iBestShapes = {'o', 's', '+'};
    
    size1 = 6;
    size2 = size1;

    figname = 'ROCplot';
    fig = figure('Name', figname, 'visible', 'off');
    
    m2x = 0;
    m2y = 0;
    
    MyColor = [
        244,109,67;
        69,117,180;
        253,174,97;
        215,48,39;


116,173,209;

]/255;
    
    for i = 1:length(MM)
        M = MM{i};
        M_fp = M(:, 2);
        M_tp = M(:, 1);
        if regexp(legendnames{i}, 'Opt')
            plot(M_fp, M_tp, 'x', 'color', MyColor(mod(i-1, size(MyColor, 1) )+ 1, :), 'MarkerSize', MarkerSize, 'LineWidth', 5)
        elseif regexp(legendnames{i}, 'FDS')
            plot(M_fp, M_tp, '--', 'color', MyColor(mod(i, size(MyColor, 1) )+ 1, :), 'MarkerSize', MarkerSize, 'LineWidth', 3)
        else
            plot(M_fp, M_tp, '-', 'color', MyColor(mod(i, size(MyColor, 1) )+ 1, :), 'MarkerSize', MarkerSize, 'LineWidth', 3)
        end
        hold on
        
        m2x = max(max(M_fp), m2x);
        m2y = max(max(M_tp), m2y);
    end

    xxlim = max(m2x)+0.01;
    yylim = max(m2y)+0.01;
    
    xylim = max(xxlim, yylim);
    
    hold on
%     plot([0 xylim], [0 xylim], '--black')
    plot([0 min(xxlim, yylim)], [0 min(xxlim, yylim)], '--black')

    box on
    axis square
    
    title(titlename)
    if ~isempty(varargin)
        FileName = sprintf('%s_legendoff', FileName);
    else
        legend(legendnames, 'location', 'southeast', 'FontSize', FSize)
    end
%     legend(['Reactionet lasso', iBestNames], 'location', 'southeast', 'FontSize', FSize);
    
    ylim([0 yylim]);
    xlim([0 xxlim]);
    
    xlabel('FPR (1 - Specificity)')
    ylabel('TPR (Sensitivity)')
   
    SetMyFonts   

    PDFprint(FileName,  fig, size1, size2);
    
end

