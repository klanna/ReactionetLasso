function SBMLfit( foldername, filename, ODEtimepoints, ODEData, meanTimepoints, meanData, stdData, SpeciesNames, pic)
    if ~exist(foldername, 'dir')
        mkdir(foldername);
    end
    FSize = 14;
%     addpath(genpath(pwd));
    figname = 'ODEfit';
    
    fig = figure('Name', figname, 'Visible', pic);
    N_sp = size(ODEData, 2);
    s = SubplotDimSelection( N_sp + 1);
    
    SetMyColors  
    SetMarkers
       
    for i = 1:N_sp
        subplot(s(1), s(2), i)
        plot(ODEtimepoints, ODEData(:, i), '-x', 'color', my_color1, 'MarkerSize', MarkerSize/2, 'LineWidth',lwidth)
        hold on
        plot(meanTimepoints, meanData(:, i), 'ob', 'MarkerSize', MarkerSize, 'MarkerFaceColor', my_color2)
        hold on
        plot(meanTimepoints, meanData(:, i) + 3*stdData(:, i), '-b', 'MarkerSize', MarkerSize/3, 'MarkerFaceColor', my_color2/3)
        hold on
        plot(meanTimepoints, meanData(:, i) - 3*stdData(:, i), '-b', 'MarkerSize', MarkerSize/3, 'MarkerFaceColor', my_color2/3)
        % title(SpeciesNames{i})
%         xlabel('time')
%         ylabel('Mean')
        % SetFonts
    end
    subplot(s(1), s(2), i+1)
    plot(0, 0, '-x', 'color', my_color1, 'MarkerSize', MarkerSize/2, 'LineWidth',lwidth)
    hold on
    plot(0, 0, 'ob', 'MarkerSize', MarkerSize, 'MarkerFaceColor', my_color2)
    hold on
    plot(0, 0, '-b', 'MarkerSize', MarkerSize/3, 'MarkerFaceColor', my_color2/3)
    hold on
    plot(0, 0, '-b', 'MarkerSize', MarkerSize/3, 'MarkerFaceColor', my_color2/3)
        
    h_legend = legend('ODE-prediction with estimated rate constants', 'Observed Mean Trajectory', 'Location', 'bestoutside');
%     set(h_legend,'FontSize', 18, 'FontWeight', 'Bold');
    set(h_legend,'FontSize', FSize);
    
    
    if ~isempty(filename)
        PDFprint(strcat(foldername, figname, '_', filename),  fig);
    end
end

