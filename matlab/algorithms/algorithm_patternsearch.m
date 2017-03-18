function [history,x,fval,algoptions] = algorithm_patternsearch(algo,algoset,probstruct)

algoptions.TolFun = probstruct.TolFun;             % Standard TolFun
algoptions.MaxFunEvals = probstruct.MaxFunEvals;

switch algoset
    case {1,'base'}; algoset = 'base'; % Use defaults
    case {2,'mads'}; algoset = 'mads'; algoptions.PollMethod = 'MADSPositiveBasis2N'; algoptions.PollingOrder = 'Success'; algoptions.CompletePoll = 'on'; % algoptions.SearchMethod = @MADSPositiveBasis2N;
    otherwise
        error(['Unknown algorithm setting ''' algoset ''' for algorithm ''' algo '''.']);
end

% Manage verbosity
if isfield(probstruct,'Verbose') && probstruct.Verbose
    algoptions.Display = 'iter';
else
    algoptions.Display = 'off';
end

LB = probstruct.LowerBound;
UB = probstruct.UpperBound;
x0 = probstruct.InitPoint;

algoptions = psoptimset(algoptions);

% No cache with noisy functions
if ~isempty(probstruct.Noise) || probstruct.IntrinsicNoisy
    algoptions.Cache = 'off';
else
    algoptions.Cache = 'on';    
end

[x,fval] = ...
    patternsearch(@(x) benchmark_func(x,probstruct),x0,[],[],[],[],LB,UB,[],algoptions);

history = benchmark_func(); % Retrieve history