% clc;clear all;close all
% data should be stored in file data/ModelName in 2 files:
% - Trajectories.mat: [Timepoints, Trajectories (with initialAmount), SpeciesNames]
% - [optional: CompartmentList.mat]
%% Example 1: Enzymatic System (ES), 10^5 trajectories, 9 timepoints, no noise
ModelName = 'ES100kDT4sp9tp';
ReactionetLassoMain( ModelName );

%% Example 2: Apoptotic Receptor Subunit (ARS), 10^5 trajectories, 15 timepoints, no noise
ModelName = 'ARS100kDT14sp15tp';
ReactionetLassoMain( ModelName );

%% Example 3: Apoptotic Receptor Subunit (ARS), 10^5 trajectories, 15 timepoints, p = 0.05
ModelName = 'ARS5bn100kDT14sp15tp';
p = 0.05;
ReactionetLassoMain( ModelName, p );
