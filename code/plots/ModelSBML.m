function [l2dist, r] = ModelSBML( folder, filename, k, stoich, SpeciesNames, initialAmount, Timepoints, E, StdE, pic)
    FolderSBML = strcat(folder, '/SBMLmodel/');
    if ~exist(FolderSBML, 'dir')
        mkdir(FolderSBML);
    end
    
    indx = find(k == 0);
    
    stoich(:, indx) = [];
    k(indx) = [];

    sbmlfilename = MakeSBMLfile( strcat(FolderSBML, filename), stoich, k, SpeciesNames, initialAmount);
    simData = SimulateData( sbmlfilename, Timepoints );
%     [l2dist, r] = OdeDist( simData, E', StdE');
    l2dist = 0;
    r = 0;
    SBMLfit( FolderSBML, filename, [simData.time], [simData.Data], Timepoints, E', StdE', SpeciesNames, pic);       

end

function [l2dist, r] = OdeDist( simData, meanTraject, stdTrajectPos)
    stdTrajectPos(stdTrajectPos <= 0 ) = 1;
    ODEDataPoints = simData.Data;
    
    r = ODEDataPoints - meanTraject;
    absdist = abs(r);
 
    reldist = reshape(absdist ./ stdTrajectPos, [], 1);
   
    
    l2distr = sqrt(sum(reldist.^2));
    l2dista = sqrt(sum(sum(absdist.^2)));
    
    
    l2dist = l2distr;
end



