function bg = CreateGraphObjScorePathway( AdjMat, NodesProp, TPMat, FPMat, PMat, PathwayList )
% create biograph object
    AdjMat1 = AdjMat;
    AdjMat1(find(AdjMat1)) = 1;
    bg = biograph(AdjMat1, NodesProp.Names, 'ShowArrows','on');
    
    %% set prperties
    NodeColor = [153 204 255]/255;
    ReactColorTP = [1 0 0]; % red
    ReactColorFP = [0 0 1]; % blue
    ReactColorFN = [255 204 229]/255; % pink
    ReactColorP = [51 0 0]/255;
    
    NodeColorMat = [153 204 255;
        179,226,205;
241,182,218;
203,213,232;
244,202,228;
230,245,201;
255,242,174;
241,226,204]/255;
    %%
    
    set(bg.edges,'LineColor',ReactColorFN);
    set(bg,'LayoutScale',0.5);
    set(bg,'NodeAutoSize','on');

    for i = [NodesProp.OriNodes]
        bg.nodes(i).Shape = 'rectangle';
        bg.nodes(i).Size = [60 30];
        bg.nodes(i).color = NodeColorMat(PathwayList(i), :);
        bg.nodes(i).FontSize = 10;
    end
    
    for i = [NodesProp.ReactNodes]
        bg.nodes(i).Shape = 'diamond';
        bg.nodes(i).Size = [1 1];
        bg.nodes(i).color = ReactColorFN;
    end
    
    if ~isempty([NodesProp.FP])
        for i = [NodesProp.FP]
            bg.nodes(i).color = ReactColorFP;
        end
    end
    
    if ~isempty([NodesProp.TP])
        for i = [NodesProp.TP]
            bg.nodes(i).color = ReactColorTP;
        end
    end

    [indx_I, indx_J, ~ ] = find(TPMat);
    for i = 1:length(indx_I)
        EdgesOut = getedgesbynodeid(bg,bg.nodes(indx_I(i)).id,bg.nodes(indx_J(i)).id);
        set(EdgesOut,'LineColor',ReactColorTP, 'LineWidth', AdjMat(indx_I(i), indx_J(i)));
    end
    
    [indx_I, indx_J, ~ ] = find(PMat);
    for i = 1:length(indx_I)
        EdgesOut = getedgesbynodeid(bg,bg.nodes(indx_I(i)).id,bg.nodes(indx_J(i)).id);
        set(EdgesOut,'LineColor',ReactColorP, 'LineWidth', 1);
    end
    
    [indx_I, indx_J, ~ ] = find(FPMat);
    for i = 1:length(indx_I)
        EdgesOut = getedgesbynodeid(bg,bg.nodes(indx_I(i)).id,bg.nodes(indx_J(i)).id);
        set(EdgesOut,'LineColor',ReactColorFP, 'LineWidth', AdjMat(indx_I(i), indx_J(i)));
    end
    
end

