function [ knew, flag, ReNotConnectList] = CheckConnected( stoich, k, varargin )
    if ~isempty(varargin)
        trim = varargin{1};
    else
        trim = 0;
    end
    knew = k;    
%     SpConnectList = max(abs(stoich(:, find(k)))');
%     
%     SpNotConnectList = find(SpConnectList == 0);
%     ReNotConnectList = [];
    
%     for i = 1:length(SpNotConnectList)
%         sp = SpNotConnectList(i);
%         ReNotConnectList = unique([ReNotConnectList find(stoich(sp, :) ~= 0)]);
%         knew(find(stoich(sp, :) ~= 0)) = 1;
%     end
%     
%     if isempty(ReNotConnectList)
%         flag = 1;
%     else
%         flag = 0;
%     end
    
    % check modules
    G = ConstructConnectG(stoich(:, find(k)));
    [S, C] = graphconncomp(sparse(G), 'Weak', 'true');
    ReNotConnectList = [];
    
    if S == 1
        % all connected
        flag = 1;
        fprintf('Everything connected\n');
    else
        % find all disconnected components
        flag = 0;
        ReNotConnectList = [];
        
        for i = 1:S
            for j = i+1:S
                Ci = find(C == i);
                Cj = find(C == j);
                for iCi = 1:length(Ci)
                    for iCj = 1:length(Cj)
                        ReNotConnectList = [ReNotConnectList; VertVect(find(min(abs(stoich([Ci(iCi), Cj(iCj)], :)))))];
                    end
                end
            end
        end
        
        ReNotConnectList = unique(ReNotConnectList);
        if isempty(ReNotConnectList)
            flag = 1;
            fprintf('Everything connected\n');
        else
%             if trim
%                 % find minimal set of reactions connecting modules
%                 NreC = length(ReNotConnectList);
%                 NumberOfModulesConnected = zeros(NreC, 1);
%                 for i = 1:NreC
%                     spidx = find(stoich(:, ReNotConnectList(i)));
%                     NumberOfModulesConnected(i) = length(unique(C(spidx)));
%                 end
%                 [iReNotConnectList, NumberOfModulesConnected] = sord(NumberOfModulesConnected, 'descend');
%                 ModulesConnect = zeros(S, 1);
%                 
%                 ReNotConnectListTrim = [];
%                 i = 1;
%                 while ~all(ModulesConnect == 1) && (i <= NreC)
%                     re = ReNotConnectList(iReNotConnectList(i));
%                     spidx = find(stoich(:, re));
%                     ModulesConnect(unique(C(spidx))) = 1;
%                     ReNotConnectListTrim(end+1) = re;
%                     i = i+1;
%                 end
%                 
%                 ReNotConnectList = ReNotConnectListTrim;
%                 fprintf('Trimmed from %u to %u\n', NreC, length(ReNotConnectList));
%             end
            knew(ReNotConnectList) = 1;
            fprintf('Enriched from %u to %u reaction (total %u reactions)\n', length(find(k)), length(find(knew)), size(stoich, 2));
        end
    end
    
end

function G = ConstructConnectG(stoich)
    [Nsp, Nre] = size(stoich);
    G = zeros(Nsp, Nsp);
    for i = 1:Nre
        spcon = find(stoich(:, i));
        G(spcon, spcon) = 1;
    end
end
