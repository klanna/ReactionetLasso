function [ indx ] = SelectOptimalSolution( IC, varargin )
% Selects a set of optimal solutions based on relateve change of
% Imformation Criteria
% INPUT:
% IC - vecotr o values of Information Criteria
% optional: Number of optimal values to output (default = 3)
% OUTPUT:
% indx - indeces of best solutions
    dIC = -diff(IC);
    % check if IC is monotoneously decreasing 
    if ~isempty(varargin)
        Nindx = varargin{1};
    else
        Nindx = 3;
    end
    
    if all(dIC > 0)
        [~, idx] = sort(dIC, 'descend'); % select biggest step
        indx = idx(1:Nindx) + 1;
    else
        [~, indx] = min(IC);
        Nindx = 2;
        [~, idx] = sort(dIC, 'descend');
        indx = [indx idx(1:Nindx) + 1];
    end
end

