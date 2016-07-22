function [ knew, flag, ReNotConnectList] = CheckConnected( stoich, k )
    knew = k;    
    SpConnectList = max(abs(stoich(:, find(k)))');
    
    SpNotConnectList = find(SpConnectList == 0);
    ReNotConnectList = [];
    
    for i = 1:length(SpNotConnectList)
        sp = SpNotConnectList(i);
        ReNotConnectList = unique([ReNotConnectList find(stoich(sp, :) ~= 0)]);
        knew(find(stoich(sp, :) ~= 0)) = 1;
    end
    
    if isempty(ReNotConnectList)
        flag = 1;
    else
        flag = 0;
    end
    fprintf('Enriched from %u to %u reaction (total %u reactions)\n', length(find(k)), length(find(knew)), size(stoich, 2));
end

