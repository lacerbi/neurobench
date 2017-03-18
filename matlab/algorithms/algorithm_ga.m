function [history,x,fval,algoptions] = algorithm_ga(algo,algoset,probstruct)

switch algoset
    case {1,'base'}; algoset = 'base'; % Use defaults
    case {2,'loxover'}; algoset = 'loxover';
    case {3,'mexover'}; algoset = 'mexover';
    case {4,'hixover'}; algoset = 'hixover';
    case {5,'gausscon'}; algoset = 'gausscon';
    case {6,'megausscon'}; algoset = 'megausscon';
    otherwise
        error(['Unknown algorithm setting ''' algoset ''' for algorithm ''' algo '''.']);
end

% Get options structure for genetic algorithms
algoptions.gaoptions = algorithm_gaoptions(algoset,probstruct);

LB = probstruct.LowerBound;
UB = probstruct.UpperBound;

[~,~,exitFlag,output,population,scores] = ...
    ga(@(x) benchmark_func(x,probstruct),probstruct.D,[],[],[],[],LB,UB,[],[],algoptions.gaoptions);

% Return full population, ordered by score
[fval,index] = sort(scores,'ascend');
x = population(index,:);

history = benchmark_func(); % Retrieve history