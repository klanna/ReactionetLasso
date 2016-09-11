function ConvertSBMLtoMAT( sbmlfilename )
% sbmlfilename - full path to sbml model
%     modelObj = sbmlimport(sbmlfilename);
    TrSBML = TranslateSBML(sbmlfilename);
%%
    SpeciesNames = {TrSBML.species.id};
    initialAmount = [TrSBML.species.initialAmount];
    if isnan(initialAmount(1))
        initialAmount = [TrSBML.species.initialConcentration];
    end
    
    %%
    NReOriginal = length({TrSBML.reaction.id});
    for re = 1:NReOriginal
        Reaction = TrSBML.reaction(re);
    end
    
    RRname(:, 1) = {TrSBML.parameter.name};
    kAll(:, 1) = [TrSBML.parameter.value];
    kAll(find(isnan(kAll))) = [];

    ReactionReversFlag = [TrSBML.reaction.reversible];
    ReactionReactantName = {TrSBML.reaction.reactant};
    ReactionProductName = {TrSBML.reaction.product};
    ReactionKLaw = {TrSBML.reaction.kineticLaw};
    
    N_sp = length(SpeciesNames);
    N_re = length(kAll);
    N_re1 = length(ReactionReversFlag);
    stoich = zeros(N_sp, N_re-1);
    prop = zeros(N_sp, N_re-1);
    
    clear ParseRateConst
    for i = 1:N_re1
        MF = ReactionKLaw{i}.math;
        MF = regexprep(MF, ')', '');
        MF = regexprep(MF, 'cell', '');
        MF = regexprep(MF, 'mitochondrion', '');
        MF = regexprep(MF, '(', '');
        MathFormulaList{i, 1} = MF;
        MF = strrep(MF, '*', '');
        MF = strrep(MF, '-', '');
        for j = 1:length(SpeciesNames)
            MF = regexprep(MF, sprintf(' %s ', SpeciesNames{j}), '');
        end
        C = strsplit(MF);
        C(strcmp('', C)) = [];
        C(strcmp('/', C)) = [];
        ParseRateConst{i, 1} = C;
    end
    
    %%
    l = 0;
    for i = 1:N_re1
        l = l+1;
        clear ReactantName ProductName indxReactant indxProduct RRnameList

        ReactantName = {ReactionReactantName{i}.species};
        ProductName = {ReactionProductName{i}.species};
        for i1 = 1:length(ReactantName)
           indxReactant(i1) = find(ismember(SpeciesNames, ReactantName{i1}));
        end
        for i1 = 1:length(ProductName)
           indxProduct(i1) = find(ismember(SpeciesNames, ProductName{i1}));
        end
        stoich(indxReactant, l) = -1;
        prop(indxReactant, l) = 1;
        stoich(indxProduct, l) = 1;

        RRnameList = ParseRateConst{i, 1};
        ReactioRateName{l} = RRnameList{1};
        id = find(ismember(RRname,ReactioRateName{l}));
        k(l) = kAll(id);

        if ReactionReversFlag(i)
            l = l + 1;
            stoich(:, l) = -stoich(:, l-1);
            prop(indxProduct, l) = 1;
            MathFormula = ReactionKLaw{i}.math;
            id = 1;
            while id   
                if strfind(MathFormula, RRname{id});
                    RRid(l) = id;
                    id = 0;
                else
                    id = id +1;
                end
            end
            if length(RRnameList) == 2
                ReactioRateName{l} = RRnameList{2};
            else
                ReactioRateName{l} = RRnameList{3};
                id = find(ismember(RRname, RRnameList{2}));
                k(l-1) = k(l-1) / kAll(id);
            end
            id = find(ismember(RRname,ReactioRateName{l}));
            k(l) = kAll(id);
        end
    end

    save('TopologyOriginal.mat', 'k', 'prop', 'stoich', 'initialAmount', 'SpeciesNames')
end

