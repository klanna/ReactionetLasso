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
    ModelParams.p = 1;
    
    if ~isempty(varargin)
        varargin = varargin{1};
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
                        ModelParams.Prior = tmp;
                    end
            end
            clear tmp
        end
    end
    
    fprintf('Gradients = %s\n', ModelParams.Gradients);
    fprintf('NMom = %u\n', ModelParams.NMom);
    fprintf('Prior = %s\n', ModelParams.Prior);
    fprintf('p = %.2f\n', ModelParams.p);
end

