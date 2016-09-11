function l2dist = CreateModelSBML( folder, filename, k, stoich, prop, SpeciesNames, initialAmount, Timepoints, Traject, pic)
    FolderSBML = strcat(folder, '/SBMLmodel/');
    if ~exist(FolderSBML, 'dir')
        mkdir(FolderSBML);
    end
    %%
    
    [~, ~, nc] = size(Traject);
    meanTraject = mean(Traject, 3);
    stdTraject = std(Traject, 0, 3) / sqrt(nc);
    stdTrajectPos = stdTraject ; % std of mean estimate
    stdTrajectPos(find(stdTrajectPos == 0)) = 1;
    
    indx = find(k == 0);
    
    stoich(:, indx) = [];
    k(indx) = [];
    prop(:, indx) = [];

    try
        sbmlfilename = MakeSBMLfile( strcat(FolderSBML, filename), stoich, prop, k, SpeciesNames, initialAmount);
        simData = SimulateData( sbmlfilename, Timepoints );
        l2dist = OdeDist( simData, Timepoints, meanTraject, stdTrajectPos);
        SBMLfit( FolderSBML, filename, [simData.time], [simData.Data], Timepoints, meanTraject, stdTraject, SpeciesNames, pic);       
    catch Mexc
        fprintf('%s\n', Mexc.message);
        for i = 1:length(Mexc.stack)
            fprintf('%s\t%u\n', Mexc.stack(i).name, Mexc.stack(i).line);
        end
        l2dist = 10^12;
    end

end

function [l2dist, r] = OdeDist( simData, Timepoints, meanTraject, stdTrajectPos)
    ODEDataPoints = simData.Data;
%     ODEtimepoints = simData.time;
%     timeindx = MatchIndexTimeVStime( Timepoints, ODEtimepoints);
%     ODEDataPoints = ODEData(timeindx, :);
%     ODEDataPoints = ODEData;
    
    r = ODEDataPoints - meanTraject;
    absdist = abs(r);
    reldist = absdist ./ stdTrajectPos;
    
    l2distr = sqrt(sum(sum(reldist.^2)));
    l2dista = sqrt(sum(sum(absdist.^2)));
    
    fprintf('l2dist abs = %1.1e\n', l2dista);
    fprintf('l2dist rel = %1.1e\n', l2distr);
    
    l2dist = l2distr;
end



