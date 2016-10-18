function LassoPlot( M, FileName)
    figname = 'LassoPlot';
    fprintf('%s\n', figname);
    
    PaperFonts
    
    size1 = 5;

    figname = 'ROCplot';
    fig = figure('Name', figname, 'visible', 'on');
    
    m2x = 0;
    m2y = 0;
    
    MyColor = [
        244,109,67;
        69,117,180;
        253,174,97;
        215,48,39;


        116,173,209;

        ]/255;
    
    MarkerSize = 3;
    LineWidth = 2;
    plot(M(:, 2), M(:, 1), '-x', 'color', MyColor(1, :), 'MarkerSize', MarkerSize, 'LineWidth', 3)
    
    set(gca, 'FontSize', FSize)
    
    xlabel('False Positive')
    ylabel('True Positive')
   
    SetMyFonts   

    PDFprint(FileName,  fig, size1, size1);
    
end

