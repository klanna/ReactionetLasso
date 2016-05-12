function PlotComputationTime( OutFolder, ModelName, RunTimeS, RunTimeSname)
    figname = 'ComputationTime';
    DataFile = sprintf('%s/%s_%s.mat', OutFolder, ModelName, figname);
    
    if ~exist(DataFile, 'file')
        save(DataFile, 'RunTimeS', 'RunTimeSname')
    else
        load(DataFile)
    end
    RunTimeSInt(1) = RunTimeS(1);
    N = length(RunTimeS);
    for i = 2:N
        RunTimeSInt(i) = RunTimeSInt(i-1) + RunTimeS(i);
    end
    ylab = 'time (sec)';
    if RunTimeSInt(N) > 60
        RunTimeSInt = RunTimeSInt / 60;
        ylab = 'time (min)';
        if RunTimeSInt(N) > 60
            RunTimeSInt = RunTimeSInt / 60;
            ylab = 'time (h)';
        end
    end
    
    fig = figure('Name', figname, 'visible', 'off');
    SetMyMarkers
    SetMyPaperColors
    plot(RunTimeSInt, '-s', 'color', MyColor(2, :), 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
    try
        set(gca,'XTick',1:N, 'XTickLabel', RunTimeSname,'FontSize', FSize, 'XTickLabelRotation', 45)
    catch Mexc
        PrintExceptionMessage(Mexc);
        set(gca,'XTick',1:N, 'XTickLabel', RunTimeSname,'FontSize', FSize)
    end
    xlim([1 N])
    ylim([0 RunTimeSInt(N)*1.01])
    box on
%     axis square
    ylabel(ylab)
    title(ModelName)
    SetMyFonts
    PDFprint(sprintf('%s/%s_%s', OutFolder, ModelName, figname),  fig, 8, 4);
end

