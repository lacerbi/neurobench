function history = algorithm_bga(algo,algoset,probstruct)

algoptions.TolFun = probstruct.TolFun;             % Standard TolFun
algoptions.Nsamples = 100;
algoptions.NsamplesEI = 500;

switch algoset
    case {1,'base'}; algoset = 'base'; % Use defaults
    case {2,'extraEI'}; algoset = 'extraEI'; algoptions.NsamplesEI = 2000;
    case {3,'extrasamples'}; algoset = 'extrasamples'; algoptions.Nsamples = 400;
    case {4,'greedyEI'}; algoset = 'greedyEI'; algoptions.NsamplesEI = 0;
    otherwise
        error(['Unknown algorithm setting ''' algoset ''' for algorithm ''' algo '''.']);
end

% Get options structure for genetic algorithms
algoptions.gaoptions = algorithm_gaoptions(algoset,probstruct);

LB = probstruct.LowerBound;
UB = probstruct.UpperBound;

[x,fval,exitFlag,~,~,~,gps] = ...
    bga(@(x) benchmark_func(x,probstruct),probstruct.D,[],[],[],[],LB,UB,[],[],algoptions.gaoptions,[algoptions.Nsamples,algoptions.NsamplesEI],0);

history = benchmark_func(); % Retrieve history