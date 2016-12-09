function [stoichAll, ReactionNamesAll] = GenerateMetaTopologyFromDGraphWithInhibition(SpeciesNames, varargin)
% CompartmentList - list indicating in which compartment is the specie
% BorderCompartment should have 0 value
    ts = tic;
    fprintf('GenerateMetaTopologyFromDGraph...\n');
    N_sp = length(SpeciesNames);
    
    if ~isempty(varargin)
        G = varargin{1};
    else
        G = ones(N_sp, N_sp);
    end
    
    for i = 1:N_sp
        G(i, i) = 0;
    end
    
    stoichAll = [];
    l = 0;
    for child = 1:N_sp
        parents = find(G(:, child)); % get all the parents of a child
        for i = 1:length(parents)
            l = l+1;
%             [ ReactionNamesAll{l}, stoichAll(:, l)] = GenerateReactionTopologyX_Y( parents(i), child, SpeciesNames, N_sp);
            for j = i+1:length(parents)
                l = l+1;
                [ ReactionNamesAll{l}, stoichAll(:, l)] = GenerateReactionTopologyXY_Z( parents(i), parents(j), child, SpeciesNames, N_sp);
            end
        end
    end
    
    for parent = 1:N_sp
        children = find(G(parent, :));
        for i = 1:length(children)
            for j = i+1:length(children)
                l = l+1;
                [ ReactionNamesAll{l}, stoichAll(:, l)] = GenerateReactionTopologyX_YZ( parent, children(i), children(j), SpeciesNames, N_sp);
            end
        end
    end
 
    stoichAll = unique(stoichAll', 'rows')';
    fprintf('%.3f sec\n', toc(ts));
end

function [ ReactName, StoichVector, PropVector] = GenerateReactionTopologyXY_Z( x, y, z, SpeciesNames, N_sp)
% x + y -> z
    StoichVector = zeros(1, N_sp);
    StoichVector(x) = -1;
    StoichVector(y) = -1;
    if z
        StoichVector(z) = 1;
    end
    PropVector(x) = 1;
    PropVector(y) = 1;
    ReactName = GeneratereactionName( SpeciesNames, StoichVector );
end

function [ ReactName, StoichVector] = GenerateReactionTopologyX_YZ( x, y, z, SpeciesNames, N_sp)
% x + y <- z
    StoichVector = zeros(1, N_sp);
    StoichVector(x) = -1;
    StoichVector(y) = 1;
    StoichVector(z) = 1;
    ReactName = GeneratereactionName( SpeciesNames, StoichVector );
end

function [ ReactName, StoichVector] = GenerateReactionTopologyX_Y( x, y, SpeciesNames, N_sp)
% x + y <- z
    StoichVector = zeros(1, N_sp);
    StoichVector(x) = -1;
    StoichVector(y) = 1;
    ReactName = GeneratereactionName( SpeciesNames, StoichVector );
end


function [ ReactName ] = GeneratereactionName( SpeciesNames, stoich )
    f_in = '->';
    f_out = '';
    ReactName = '';
    for i = 1:length(stoich)
        switch stoich(i)
            case 1
                ReactName = strcat(ReactName, f_in, SpeciesNames(i));
                f_in = '+';
            case -1
                ReactName = strcat(SpeciesNames(i), f_out, ReactName);
                f_out = '+';
        end
    end
end