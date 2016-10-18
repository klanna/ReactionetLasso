function PlotScatterCons( ktrue, kest, kest_name, FileName, pic, varargin)
    fprintf('PlotScatterCons \n');
%     warning ('off','all');
%     addpath(genpath(pwd));
    SetMyColors
    ktrue = VertVect(ktrue);
    kest = VertVect(kest);
    %% specify line characteristics
    TPsize = 100;
    FPsize = 30;
    FNsize = 100;
    TNsize = 1;
    lwidth = 4;
    FSize = 12;
    %% Define Sets
    indx_TRUE = find(ktrue);
    indx_notTRUE = find(ktrue == 0);
    indx_EST = find(kest);
    %%
    [ indxFDR, indxFDRname ] = FDRList( kest, ktrue );
    for i = 1:length(indxFDRname)
        eval(sprintf('indx_%s = indxFDR{i};', indxFDRname{i}));
    end
    %%
    log10Zero = round(log10(min([min(kest(indx_EST)), min(ktrue(indx_TRUE))]))) - 3; % find minimal element not equal 0
    logTRUE = log10(ReplaceZero(ktrue, 10^log10Zero)); % replace 0 with log10 of the smallest element
    logEST = log10(ReplaceZero(kest, 10^log10Zero)); 
    
    xindx = [log10Zero:2:round(max([logTRUE; logEST]))];
    
    xName{1} = '-inf';
    for i = 2:length(xindx)
        xName{i} = sprintf('%.f', xindx(i));
    end
    %%
    LeftBorder = log10Zero - 1;
    RightBorder = max(xindx) + 1 ;
    %%
    figname = strcat('FitRateConst');
    fig = figure('Name', figname, 'Visible', pic);
    
    l = 0;
    if ~isempty(indx_TP)
        scatter(logTRUE(indx_TP), logEST(indx_TP), TPsize, 'r', 'LineWidth', lwidth)
        axis square
        hold on
        l = l+1;
        line{l} = strcat('TruePos  = ', num2str(length(indx_TP)));
    end
    
    if ~isempty(indx_FP)
        scatter(PointsCloud(indx_FP, log10Zero, 0.5), logEST(indx_FP), FPsize, 'ob', 'LineWidth',lwidth)
        hold on
        l = l+1;
        line{l} = strcat('FalsePos = ', num2str(length(indx_FP)));
    end
    
    SetMyColors
    if ~isempty(indx_TN)
        scatter(PointsCloud(indx_TN, log10Zero, 0.3), PointsCloud(indx_TN, log10Zero, 0.3), TNsize, 'g', 'x', 'LineWidth',lwidth)
        hold on
        l = l+1;
        line{l} = strcat('TrueNeg  = ', num2str(length(indx_TN)));
    end
    
    if ~isempty(indx_FN)
        scatter(logTRUE(indx_FN), logEST(indx_FN), FNsize, 'magenta', 'd', 'LineWidth',lwidth)
        hold on
        l = l+1;
        line{l} = strcat('FalseNeg = ', num2str(length(indx_FN)));
        
        x = logTRUE(indx_FN);
        y = logEST(indx_FN);
        c = num2str(indx_FN);
        dy = randi(100, size(y))*0.01;
%         text(x, y+dy, c, 'FontSize', FSize);
    end
    
    if ~isempty(varargin)
       prior_indx  = varargin{1};
       scatter(logTRUE(prior_indx), logEST(prior_indx), FNsize, 'oblack', 'LineWidth', lwidth)
       hold on
       l = l+1;
       line{l} = strcat('PriorGraph = ', num2str(length(prior_indx)));
    end
    
    plot([LeftBorder:RightBorder], [LeftBorder:RightBorder], 'black')
    grid off
    box on
    
    %     title(kest_name, 'Interpreter','none')
    title(kest_name)
    xlabel('log_{10} (k_{true})')
    ylabel('log_{10} (k_{est})')
    axis([LeftBorder,RightBorder,LeftBorder,RightBorder])
    
    legend(line,'FontSize',FSize, 'location', 'SouthOutside');
    try
        legendmarkeradjust(5, 2)
    catch
    end
    set(gca,'XTick', unique(sort(round(xindx))), 'XTickLabel', xName, 'FontSize', FSize)
    set(gca,'YTick', unique(sort(round(xindx))), 'YTickLabel', xName, 'FontSize', FSize)
    set(get(gca,'xlabel'),'FontSize', FSize);
    set(get(gca,'ylabel'),'FontSize', FSize);
    set(get(gca,'title'),'FontSize', FSize, 'FontWeight', 'Bold');
    
    if ~isempty(FileName)
        PDFprint(strcat(FileName, '_', figname),  fig, 3.5, 3.5);
    end
end

function legendmarkeradjust(markersize, linewidth)
    s=get(legend); 
    s1=s.Children; 
    s2=[];

    s2=findobj(s1,{'type','patch','-or','type','line'});

    for m=1:length(s2) 
        set(s2(m),'markersize', markersize, 'linewidth', linewidth); 
    end
end

function k = ReplaceZero(x, m)
    indx = find(x == 0);
    k = x;
    k(indx) = m;
    k = VertVect(k);
end

function Kcloud = PointsCloud(x, m, wind)
    Kcloud = unifrnd(m-wind,m+wind, length(x), 1);
end

function names = MakeNames(x)
    if length(x)
        for i = 1:length(x)
           names{i} = num2str(x(i)); 
        end
    else
        names = {};
    end
end