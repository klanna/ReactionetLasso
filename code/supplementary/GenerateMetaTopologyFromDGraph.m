function [stoichAll, ReactionNamesAll] = GenerateMetaTopologyFromDGraph(SpeciesNames, varargin)
% CompartmentList - list indicating in which compartment is the specie
% BorderCompartment should have 0 value
    ts = tic;
    fprintf('GenerateMetaTopologyFromDGraph...\n');
    N_sp = length(SpeciesNames);
    
    if ~isempty(varargin)
        G = varargin{1};
    else
        G = triu(ones(N_sp, N_sp));
    end
    %%
    for i = 1:N_sp
        G(i, i) = 0;
    end
    %%
    xyzCombinations = {};
    for child = 1:N_sp
        parents = find(G(:, child));
        Nparents = length(parents);
        for i = 1:Nparents
            xyzCombinations{end+1} = [parents(i), child];
        end
        if Nparents > 1
            parentcomb = combnk(parents, 2);
            for j = 1:size(parentcomb, 1)
                xyzCombinations{end+1} = [parentcomb(j, :) child];
            end
        end
    end
    %%    
    Nxyz = length(xyzCombinations);
	N_re = Nxyz*6;
	fprintf('N_re = %u\n', N_re);

	l = 0;
    for xyz = 1:Nxyz
    	% fprintf('%u \n', xyz);
        xyzset = xyzCombinations{xyz};
		x = xyzset(1);
		y = xyzset(2);
        
        l = l+1;
        
        if length(xyzset) > 2
            z = xyzset(3);

            
            [ ReactionNamesAll{l}, stoichAll(:, l)] = GenerateReactionTopologyXY_Z( x, y, z, SpeciesNames, N_sp);
        else
            [ ReactionNamesAll{l}, stoichAll(:, l)] = GenerateReactionTopologyX_Y( x, y, SpeciesNames, N_sp);
        end
    end
    
    fprintf('%.3f sec\n', toc(ts));
end

function [ ReactName, StoichVector, PropVector] = GenerateReactionTopologyXY_Z( x, y, z, SpeciesNames, N_sp)
% x + y -> z
    StoichVector = zeros(1, N_sp);
    StoichVector(x) = -1;
    StoichVector(y) = -1;
    StoichVector(z) = 1;
    PropVector(x) = 1;
    PropVector(y) = 1;
    ReactName = GeneratereactionName( SpeciesNames, StoichVector );
end

function [ ReactName, StoichVector] = GenerateReactionTopologyX_YZ( x, y, z, SpeciesNames, N_sp)
% x + y <- z
    StoichVector = zeros(1, N_sp);
    StoichVector(x) = 1;
    StoichVector(y) = 1;
    StoichVector(z) = -1;
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