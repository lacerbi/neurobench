function [history,x,fval,algoptions] = algorithm_particleswarm(algo,algoset,probstruct)

D = probstruct.D;
SwarmSize = min(100,10*D);

switch algoset
    case {1,'base'}; algoset = 'base'; % Use defaults
    otherwise
        error(['Unknown algorithm setting ''' algoset ''' for algorithm ''' algo '''.']);
end

MaxIter = max(1,floor(probstruct.MaxFunEvals/SwarmSize)-1);

% Manage verbosity
if isfield(probstruct,'Verbose') && probstruct.Verbose
    Display = 'iter';
else
    Display = 'off';
end

InitialSwarm = bsxfun(@plus,probstruct.InitRange(1,:), ...
    bsxfun(@times,rand(SwarmSize,D),diff(probstruct.InitRange)));

algoptions = optimoptions('particleswarm', ...
    'SwarmSize',SwarmSize,'InitialSwarm',InitialSwarm, ...
    'MaxIter',MaxIter,'Display',Display,'TolFun',probstruct.TolFun);

LB = probstruct.LowerBound;
UB = probstruct.UpperBound;

[x,fval] = ...
    particleswarm(@(x) benchmark_func(x,probstruct),probstruct.D,LB,UB,algoptions);

history = benchmark_func(); % Retrieve history