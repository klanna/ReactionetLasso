function bg = PrintGraphWithScore( filename, stoich, SpeciesNames, TPList, FPList, PriorList, ScoreList, Blocks )
    [AdjMat, TPMat, FPMat, PriorMat, NodesProp] = CreateReactionGraphAdjMatrixScore( stoich, SpeciesNames, TPList, FPList, PriorList, ScoreList);
    bg = CreateGraphObjScore( AdjMat, NodesProp, TPMat, FPMat, PriorMat, Blocks );
    
    g = biograph.bggui(bg);
    
    fig = get(g.biograph.hgAxes, 'Parent');
    
    size1 = 7;
    PDFprint(sprintf('%s_Biograph', filename), fig, size1, size1);
end

