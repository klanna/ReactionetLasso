function bg = PrintGraphCompare( filename, stoich, SpeciesNames, TPList, FPList, PriorList, SpFlag, varargin )
    [AdjMat, TPMat, FPMat, PriorMat, NodesProp] = CreateReactionGraphAdjMatrix( stoich, SpeciesNames, TPList, FPList, PriorList );
    if ~isempty(varargin)
        bg = CreateGraphObj( AdjMat, NodesProp, SpFlag, TPMat, FPMat, PriorMat, varargin{1} );
    else
        bg = CreateGraphObj( AdjMat, NodesProp, SpFlag, TPMat, FPMat, PriorMat );
    end
    g = biograph.bggui(bg);
    
%     fig = figure('Name', 'Biograph', 'Visible', 'off');
%     copyobj(g.biograph.hgAxes,fig);
    
    fig = get(g.biograph.hgAxes, 'Parent');

%     print(fig, '-r600', strcat(filename), '-djpeg');
    PDFprint(sprintf('%s_Biograph', filename), fig, 8, 9);
end

