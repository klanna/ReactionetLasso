function bg = PrintGraphWithoutScore( filename, stoich, SpeciesNames, TPList, FPList, PriorList, SpeciesToDeleteList )
    [AdjMat, TPMat, FPMat, PriorMat, NodesProp] = CreateReactionGraphAdjMatrixScoreSpecial( stoich, SpeciesNames, TPList, FPList, PriorList);
    
    bg = CreateGraphObjScoreSpecial( AdjMat, NodesProp, TPMat, FPMat, PriorMat, SpeciesToDeleteList );
    
    g = biograph.bggui(bg);
    
    fig = get(g.biograph.hgAxes, 'Parent');
    
    size1 = 7;
    PDFprint(sprintf('%s_Biograph', filename), fig, size1, size1);
end

