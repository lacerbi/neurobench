function [history,x,fval,algoptions] = algorithm_simulannealbnd(algo,algoset,probstruct)

algoptions.MaxFunEvals = probstruct.MaxFunEvals;
algoptions.TolFun = probstruct.TolFun;

switch algoset
    case {1,'base'}; algoset = 'base'; % Use defaults
    otherwise
        error(['Unknown algorithm setting ''' algoset ''' for algorithm ''' algo '''.']);
end

% MaxIter = floor(probstruct.MaxFunEvals/SwarmSize)-1;

% Manage verbosity
if isfield(probstruct,'Verbose') && probstruct.Verbose
    algoptions.Display = 'iter';
else
    algoptions.Display = 'off';
end

LB = probstruct.LowerBound;
UB = probstruct.UpperBound;
x0 = probstruct.InitPoint;

[x,fval] = ...
    simulannealbnd(@(x) benchmark_func(x,probstruct),x0,LB(:),UB(:),algoptions);

history = benchmark_func(); % Retrieve history