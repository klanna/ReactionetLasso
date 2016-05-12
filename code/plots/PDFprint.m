function [ fig ] = PDFprint( file_name,  fig, varargin)
    warning ('off','all');
%     set(fig,'Position',[0 0 1500 1500]);
    if isempty(varargin)
%         pSize1 = 35;
%         pSize2 = 35;
        pSize1 = 8;
        pSize2 = 11;
        pmode = 'Manual';
    else
        pSize1 = varargin{1};
        pSize2 = varargin{2};
        pmode = 'Manual';
    end
    
    set(fig,'PaperUnits','inches');
    set(fig,'PaperSize',[pSize1 pSize2]);
    
    set(fig,'PaperPosition',[0 0 pSize1 pSize2]);
    set(fig,'PaperPositionMode', pmode);
    
    try
        print(fig, '-r600', strcat(file_name, '.pdf'), '-dpdf');
%         saveas(fig, strcat(file_name, '.pdf'))
    catch Mexc
        fprintf('%s\n', Mexc.message);
    end
%     print(fig, file_name, '-dpdf')
end

