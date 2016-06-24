function [stoichAll, ReactionNamesAll] = GenerateMetaTopologyFromGraph(SpeciesNames, varargin)
% CompartmentList - list indicating in which compartment is the specie
% BorderCompartment should have 0 value
    ts = tic;
    fprintf('GenerateMetaTopology...\n');
    N_sp = length(SpeciesNames);
    
    if ~isempty(varargin)
        G = varargin{1};
    else
        G = triu(ones(N_sp, N_sp));
    end
    
    xyzCombinations = [];
    for i = 1:N_sp
        SpConnection = G(i, :);
        idxSpConnection = find(SpConnection);
        xyzCombinations = [xyzCombinations; combnk(idxSpConnection, 3)];
    end
        
    Nxyz = size(xyzCombinations, 1);
	N_re = Nxyz*6;
	fprintf('N_re = %u\n', N_re);

	l = 0;
    for xyz = 1:Nxyz
    	% fprintf('%u \n', xyz);
		x = xyzCombinations(xyz, 1);
		y = xyzCombinations(xyz, 2);
		z = xyzCombinations(xyz, 3);

		l = l+1;
		[ ReactionNamesAll{l}, stoichAll(:, l)] = GenerateReactionTopologyX_YZ( x, y, z, SpeciesNames, N_sp);
		l = l+1;
		[ ReactionNamesAll{l}, stoichAll(:, l)] = GenerateReactionTopologyXY_Z( x, y, z, SpeciesNames, N_sp);

		l = l+1;
		[ ReactionNamesAll{l}, stoichAll(:, l)] = GenerateReactionTopologyX_YZ( y, z, x, SpeciesNames, N_sp);
		l = l+1;
		[ ReactionNamesAll{l}, stoichAll(:, l)] = GenerateReactionTopologyXY_Z( y, z, x, SpeciesNames, N_sp);

		l = l+1;
		[ ReactionNamesAll{l}, stoichAll(:, l)] = GenerateReactionTopologyX_YZ( z, x, y, SpeciesNames, N_sp);
		l = l+1;
		[ ReactionNamesAll{l}, stoichAll(:, l)] = GenerateReactionTopologyXY_Z( z, x, y, SpeciesNames, N_sp);
    end
    
    for i = 1:N_sp
        for j = 1:N_sp
            if (i ~= j) && (G(i, j) || G(j, i))
                l = l+1;
                [ ReactionNamesAll{l}, stoichAll(:, l)] = GenerateReactionTopologyX_Y( i, j, SpeciesNames, N_sp);
            end
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