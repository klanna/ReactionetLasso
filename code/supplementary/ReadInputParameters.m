function ModelParams = ReadInputParameters( varargin )
% Default settings:
%     Gradients = 'splines';
%     NMom = 2; (else [1, 2];)
%     Nboot = 100;  (else Nboot > 10)
%     MA = 'NoPrior'; (else MAName)   

    ModelParams.Gradients = 'splines';
    ModelParams.NMom = 2;
    ModelParams.Nboot = 100;
    ModelParams.Prior = '';
    ModelParams.PriorTopology = 'Topology';
    ModelParams.p = 1;
    ModelParams.connect = '';
    
    if ~isempty(varargin)
        while isequal(class(varargin{1}), 'cell') 
            varargin = varargin{1};
            if isempty(varargin)
                break
            end
        end
        for i = 1:length(varargin)
            tmp = varargin{i};
            switch class(tmp)
                case 'double'
                    if tmp < 1
                        if tmp == 0
                            tmp = 1;
                        end
                        ModelParams.p = tmp;
                    elseif tmp < 3
                        ModelParams.NMom = tmp;
                    else
                        ModelParams.Nboot = tmp;
                    end
                case 'char'
                    if isequal(tmp, 'FDS') || isequal(tmp, 'splines') || isequal(tmp, 'smooth')
                        ModelParams.Gradients = tmp;
                    else
                        if strcmp(tmp, 'connected') || strcmp(tmp, '')
                            ModelParams.connect = tmp;
                        else
                            if regexp(tmp, 'Topology')
                                ModelParams.PriorTopology = tmp;
                            else
                                ModelParams.Prior = tmp;
                            end
                        end
                    end
            end
            clear tmp
        end
    end
    
    fprintf('Gradients = %s\n', ModelParams.Gradients);
    fprintf('NMom = %u\n', ModelParams.NMom);
    
    fprintf('Prior (topology) = %s %s\n', ModelParams.PriorTopology, ModelParams.connect);
    fprintf('Prior (reactions) = %s\n', ModelParams.Prior);
    fprintf('p = %.2f\n', ModelParams.p);
end

