function PlotFitToLinearSystemMulti( b, r, N_T, N_sp, FileName, pic, SpeciesNames, varargin)
% plot b vs r vs rk
    warning('off','all');
    fprintf('PlotFitToLinearSystemMulti...\n');
    
    s =  SubplotDimSelection( N_sp + 1 );
    SetMyPaperColors
    lwidth = 2;
    MarkerSize = 3;
    
    figname = strcat('Gradients_Means');
    fig = figure('Name', figname, 'Visible', pic);

    for i = 1:N_sp
       Mask = zeros(N_sp, N_T);
       Mask(i, :) = 1;
       SpMask = find(reshape(Mask, [], 1));
       subplot(s(1), s(2), i)
       plot(b(SpMask), 'or', 'MarkerSize', MarkerSize*2)
       hold on
       for j = 1:size(r, 2)
           plot(squeeze(r(SpMask, j)), '--x', 'color', MyColor(mod(j, size(MyColor, 1) - 1) + 1, :), 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
           hold on
       end
       title(SpeciesNames{i}, 'color', MyColor(mod(i, size(MyColor, 1) - 1) + 1, :))
       box on
       axis square
%            xlabel('time')
%            ylabel('gradient')           
    end
    subplot(s(1), s(2), N_sp + 1)
    plot(0, 0, 'or', 'MarkerSize', MarkerSize)
    hold on
    plot(0, 0, '--x', 'color', 'b', 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
    box on
    axis square
%         title('legend')
    xlabel('time')
    ylabel('gradient')

    SetMyFonts
    FSize = 10;
    h_legend = legend('b', 'A*k_{est}', 'b_corr', 'Location', 'southoutside');
    set(h_legend, 'FontSize',FSize, 'Location','BestOutside');


    if ~isempty(FileName)
        PDFprint(sprintf('%s_%s', FileName,figname),  fig, 10, 10);
    end

end

function [bT_mom, momName] = SplitInMomets(NMom, b, N_T, N_sp)
    bT = reshape(b, [], N_T);
    
    momName{1} = 'Mean';
    indx = [1:N_sp];
    bT_mom{1} = bT(indx, :);
    
    if NMom > 1
        momName{2} = 'Var';
        indx = [(N_sp + 1):(2*N_sp)];
        bT_mom{2} = bT(indx, :);

        momName{3} = 'Cov';
        indx = [(2*N_sp + 1):(2*N_sp + N_sp*(N_sp - 1)/2)];
        bT_mom{3} = bT(indx, :);
    end
    
    if NMom == 3
        momName{4} = 'Sk';
        indx = [(2*N_sp + N_sp*(N_sp - 1)/2 + 1):N_mom];
        bT_mom{4} = bT(indx, :);
    end
end