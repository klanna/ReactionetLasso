function CreatePriorTopology( ModelName, ModelParams, varargin )
% creates Topology from previous computations
    if ~isempty(varargin)
        TopologyNameOLD = varargin{1};
    else
        TopologyNameOLD = 'Topology';
    end
    TopologyName = ModelParams.PriorTopology;
    ModelParams.PriorTopology= TopologyNameOLD;
    FolderNames = FolderNamesFun( ModelName, 0, ModelParams );
    FileName = sprintf('%s/%s.mat', FolderNames.Data, TopologyName);
    
    if ~exist(FileName, 'file')
        load(sprintf('%s/%s.mat', FolderNames.Data, FolderNames.PriorTopology))
        N_re = size(stoich, 2);
        switch TopologyName
            case 'PriorTopologyFG'
                RunTimeSname = 'StepFG';
                xold = zeros(N_re, 1);
                for nset = 1:5
                    FolderNames = FolderNamesFun( ModelName, nset, ModelParams );
                    OutFileName = sprintf('%s/%s.mat', FolderNames.ResultsCV, RunTimeSname);
                    load(OutFileName)
                    x = max(xold, VertVect(BestResStat.xOriginal));
                    xold = x;
                end
            case 'PriorTopologyODE'
                FileNameOut = sprintf('%s/BestODEfit_%s_%s%u_%s_%s', FolderNames.Plots, ModelName, ModelParams.Gradients, 100*ModelParams.p, ModelParams.PriorTopology, ModelParams.Prior);
                load(sprintf('%s.mat', FileNameOut), 'xx')
                x = xx;
        end
        G = GraphFromStoich( stoich(:, find(x)) );
        save(FileName, 'G')
    end
end

