function PlotCompTime( OutFolder, TitleName, RunTimeSInt, RunTimeSname, MyColorTF, size1)
    figname = 'ComputationTime';
    DataFile = sprintf('%s%s_%s.mat', OutFolder, TitleName, figname);
    
%     MyColorTF = [228,26,28;
%                 55,126,184;
%                 77,175,74;
%                 152,78,163;
%                 255,127,0;
%                 255,255,51;
%                 166,86,40;
%                 247,129,191;
%                 153,153,153]/255;
    
%     if ~exist(DataFile, 'file')
%         save(DataFile, 'RunTimeS', 'RunTimeSname')
%     else
%         load(DataFile)
%     end
   
    ylab = 'log_{60}(time)';
    yval = log([1])/log(60);
    yvalname = {'1 sec'};
%     for i = [1 5 15 30]
    for i = [1 5  ]
        yval(end+1) = log(i*60)/log(60);
        yvalname{end+1} = sprintf('%u min', i);
    end
    
%     for i = [1 3 5 10 20]
    for i = [1 5  20]
        yval(end+1) = log(i*3600)/log(60);
        yvalname{end+1} = sprintf('%u h', i);
    end
    
    
    N = length(RunTimeSInt);
%     if min(RunTimeSInt) > 60
%         RunTimeSInt = RunTimeSInt / 60;
%         ylab = 'log_{10}(time), min';
%         if max(RunTimeSInt) > 60
%             RunTimeSInt = RunTimeSInt / 60;
%             ylab = 'log_{10}(time), h';
%         end
%     end
    RunTimeSInt = log(RunTimeSInt) / log(60);
    fig = figure('Name', figname, 'visible', 'on');
    lwidth = 3;
    MarkerSize = 3;
    FSize = 10;
%     plot(RunTimeSInt, 'o', 'color', MyColor(2, :), 'MarkerSize', MarkerSize*10, 'LineWidth', lwidth)
%     b = bar(RunTimeSInt');
%     P = bar(RunTimeSInt', 'facecolor', MyColorTF(1:N, :));
%     P=findobj(gca,'type','patch');
%     P=findobj(gca);
%     set(P,'facecolor', MyColorTF);
    for i = 1:length(RunTimeSInt)
        bar(i, RunTimeSInt(i), 'facecolor', MyColorTF(i, :));
        hold on
%         set(P(i),'facecolor', MyColorTF(i, :));
% % %        b(i).FaceColor =  MyColorTF(i, :); 
% %        plot([i i], [0 RunTimeSInt(i)], '-', 'color', MyColorTF(i, :), 'MarkerSize', MarkerSize*2, 'LineWidth', 20, 'MarkerFaceColor', MyColorTF(i, :))
% % %        plot(1, RunTimeSInt(i), 'o', 'color', MyColorTF(i, :), 'MarkerSize', MarkerSize*2, 'LineWidth', lwidth, 'MarkerFaceColor', MyColorTF(i, :))
% %        hold on
% % %        set(b(i),'facecolor',MyColorTF(i, :)) 
    end
    set(gca,'YTick', yval, 'YTickLabel', yvalname,'FontSize', FSize)
    set(gca,'XTick',1:N, 'XTickLabel', RunTimeSname,'FontSize', FSize, 'XTickLabelRotation', 45)
%     legend(RunTimeSname, 'location', 'eastoutside', 'FontSize', FSize);
%     xlim([-1 N+1])
%     ylim([-0.05 max(RunTimeSInt)*1.01])
    box on
%     axis square
%     ylabel(ylab,'FontSize', FSize)
    title(ylab,'FontSize', FSize)
%     title(TitleName)
    SetMyFonts
    
    PDFprint(sprintf('%s%s_%s', OutFolder, TitleName, figname),  fig, size1, size1*0.75);
end

