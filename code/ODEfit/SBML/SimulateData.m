function simData = SimulateData( sbmlfilename, Timepoints)
% StopTime = max(Timepoints)
    modelObj = sbmlimport(sbmlfilename);
    csObj = getconfigset(modelObj,'active');
    set(csObj, 'Stoptime', max(Timepoints));    
    set(csObj.SolverOptions, 'OutputTimes', Timepoints)
    simData = sbiosimulate(modelObj);  
end

 