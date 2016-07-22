function PlotFitToLinearSystemWithNames( NMom, b, r, N_T, N_sp, FileName, pic, mNames, varargin)
% plot b vs r vs rk
    warning('off','all');
    fprintf('PlotFitToLinearSystem...\n');

    if length(b) > length(r)
        EmptyIndx = find(WeightsMask( N_sp, N_T, length(b) , [1 0 0], NMom ) == 0);
        b(EmptyIndx) = [];
        NMom = 1;
    elseif length(b) < length(r)
        EmptyIndx = find(WeightsMask( N_sp, N_T, length(r) , [1 0 0], NMom ) == 0);
        r(EmptyIndx) = [];
        rK(EmptyIndx) = [];
        NMom = 1;
    end
    
    [b_mom, momName] = SplitInMomets(NMom, b, N_T, N_sp);
    [r_mom] = SplitInMomets(NMom, r, N_T, N_sp);

    if ~isempty(varargin)
       bc = varargin{1};
       bc_mom = SplitInMomets(NMom, bc, N_T, N_sp);
       for m = 1:length(momName)
           indx_new{m} = abs(b_mom{m}-bc_mom{m});
       end
    else
       for m = 1:length(momName)
           indx_new{m} = [];
       end
    end
    
    
    SetMyPaperColors
    lwidth = 2;
    MarkerSize = 3;
    
    tmp = 0;
    for m =1:length(momName)
        figname = strcat('Gradients_',  momName{m});
        mNamesList = mNames{m};
        fig = figure('Name', figname, 'Visible', pic);
        
        bT = b_mom{m};
        rT = r_mom{m};
        
        s =  SubplotDimSelection( size(rT, 1) + 1 );
        
        for i = 1:size(rT, 1)
           tmp = tmp + 1;
           subplot(s(1), s(2), i)
           plot(rT(i, :), '--x', 'color', 'b', 'MarkerSize', MarkerSize, 'LineWidth', lwidth)
           hold on
           plot(bT(i, :), 'or', 'MarkerSize', MarkerSize*2)
           hold on
           title(mNamesList{i})
%            if ~isempty(indx)
%                plot(Timepoints(find(indx(i, :))), rT(i, find(indx(i, :))), 'xblack', 'MarkerSize', MarkerSize/5, 'LineWidth', lwidth )
%            end
%            grid on
           box on
           axis square
%            xlabel('time')
%            ylabel('gradient')           
        end
        subplot(s(1), s(2), size(rT, 1) + 1)
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
            PDFprint(sprintf('%s_%s', FileName,figname),  fig, 15, 15);
        end
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