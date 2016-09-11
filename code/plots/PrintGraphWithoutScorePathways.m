function bg = PrintGraphWithoutScorePathways( filename, stoich, SpeciesNames, TPList, FPList, PriorList, Pathwaylist)
    [AdjMat, TPMat, FPMat, PriorMat, NodesProp] = CreateReactionGraphAdjMatrixScoreSpecial( stoich, SpeciesNames, TPList, FPList, PriorList);
    
    bg = CreateGraphObjScorePathway( AdjMat, NodesProp, TPMat, FPMat, PriorMat, Pathwaylist );
    
    g = biograph.bggui(bg);
    
    fig = get(g.biograph.hgAxes, 'Parent');
    
    size1 = 6;
    PDFprint(sprintf('%s_Biograph', filename), fig, size1, size1);
end

