function [SimTimepoints, SimMeans, l2dist, r] = SimulateModelSBML( SBMLfilename, Timepoints, E, StdE)
    try
        simData = SimulateData( sprintf('%s.xml', SBMLfilename), Timepoints );
        
        SimTimepoints = [simData.time];
        SimMeans = [simData.Data]';
    catch Mexc
        fprintf('%s\n', Mexc.message);
        for i = 1:length(Mexc.stack)
            fprintf('%s\t%u\n', Mexc.stack(i).name, Mexc.stack(i).line);
        end
        SimTimepoints = Timepoints;
        SimMeans = zeros(size(E));
    end
    
    [l2dist, r] = OdeDist( SimMeans, E, StdE);
end

function [l2dist, r] = OdeDist( ODEDataPoints, meanTraject, stdTrajectPos)
    stdTrajectPos(stdTrajectPos <= 0 ) = 1;
%     ODEtimepoints = simData.time;
%     timeindx = MatchIndexTimeVStime( Timepoints, ODEtimepoints);
%     ODEDataPoints = ODEData(timeindx, :);
%     ODEDataPoints = ODEData;
    
    r = ODEDataPoints - meanTraject;
    absdist = abs(r);
 
    reldist = reshape(absdist ./ stdTrajectPos, [], 1);
   
    
    l2distr = sqrt(sum(reldist.^2));
    l2dista = sqrt(sum(sum(absdist.^2)));
    
    % fprintf('l2dist abs = %1.1e\n', l2dista);
    % fprintf('l2dist rel = %1.1e\n', l2distr);
    
    l2dist = l2dista;
end



