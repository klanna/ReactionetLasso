function ODEfitPlotSpecial( figname, filename, ODEtimepoints, ODEData, Simtime2, Simdata2, meanTimepoints, meanData, stdData, SpeciesNames, legendpar)    
%     addpath(genpath(pwd));
    fprintf('ODEfitPlot %s...\n', figname);
    pic = 'off';
    
    fig = figure('Name', figname, 'Visible', pic);
    
    [N_sp, N_T] = size(ODEData);
    if strcmp(legendpar, 'on')
        s = SubplotDimSelection( N_sp + 1);
    else
        s = SubplotDimSelection( N_sp);
    end
    
    SetMyPaperColors
    lwidth = 2;
    MarkerSize = 5;
        
    
    for i = 1:N_sp
        subplot(s(1), s(2), i)
        plot(ODEtimepoints, ODEData(i, :), '-', 'color', MyColor(2, :), 'MarkerSize', MarkerSize/2, 'LineWidth',lwidth)
        hold on
        plot(Simtime2, Simdata2(i, :), '-', 'color', MyColor(3, :), 'MarkerSize', MarkerSize/2, 'LineWidth',lwidth)
        hold on
        plot(meanTimepoints, meanData(i, :), 'o', 'color',  MyColor(1, :), 'MarkerSize', MarkerSize)
        hold on
        for t = 1:N_T
            plot([meanTimepoints(t) meanTimepoints(t)], [meanData(i, t) - 3*stdData(i, t) meanData(i, t) + 3*stdData(i, t) ], '-', 'color',  MyColor(1, :), 'MarkerSize', MarkerSize/3, 'LineWidth',lwidth)
            hold on
        end
        title(SpeciesNames{i})
        axis square
    end
    if strcmp(legendpar, 'on')
        subplot(s(1), s(2), i+1)
        plot(0, 0, '-', 'color',  MyColor(2, :),  'MarkerSize', MarkerSize/2, 'LineWidth',lwidth)
        hold on
        plot(0, 0, 'o', 'color',  MyColor(1, :), 'MarkerSize', MarkerSize)
        hold on
        plot(0, 0, '-', 'color',  MyColor(1, :), 'MarkerSize', MarkerSize/3)
        xlabel('time')
        ylabel('Mean')
        axis square
    end
    
    FSize = 10;
    SetMyFonts
    
    
    if strcmp(legendpar, 'on')
        h_legend = legend('ODE-prediction (ab initio)', 'ODE-prediction (prior)', 'Observed Mean Trajectory', 'Location', 'bestoutside');
        set(h_legend,'FontSize', FSize);
    end
    
    if ~isempty(filename)
        PDFprint(sprintf('%s_%s', filename, legendpar),  fig, 7.5, 7.5);
    end
end

