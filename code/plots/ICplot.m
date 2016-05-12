function ICplot( card, M, titlename, FileName)
    fprintf('ICplot\n');
    PaperFonts
    
    Nsubplots = size(M, 2);
    
    size1 = 6;
    size2 = size1;

    figname = 'ICplot';
    fig = figure('Name', figname, 'visible', 'off');

    for i = 1:Nsubplots
        subplot(Nsubplots, 1, i)
        plot(card, M(:, i), 'color', MyColor(1, :), 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
        title(titlename{i})
        box on
%         axis square
        xlabel('cardinality')
        ylabel('IC')
        SetMyFonts
    end 
    PDFprint(sprintf('%s_%s', FileName, figname),  fig, size1, size2);
end

