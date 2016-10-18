function bg = PrintGraphWithScore( filename, stoich, SpeciesNames, TPList, FPList, PriorList, ScoreList, Blocks, FNList )
    [AdjMat, TPMat, FPMat, PriorMat, FNMat, NodesProp] = CreateReactionGraphAdjMatrixScore( stoich, SpeciesNames, TPList, FPList, PriorList, ScoreList, FNList);
    bg = CreateGraphObjScore( AdjMat, NodesProp, TPMat, FPMat, PriorMat, FNMat, Blocks );
    
    g = biograph.bggui(bg);
    
    fig = get(g.biograph.hgAxes, 'Parent');
    
    size1 = 3.75;
    PDFprint(sprintf('%s_Biograph', filename), fig, size1, size1);
end

