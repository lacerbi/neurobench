function [history,x,fval,algoptions] = algorithm_bads(algo,algoset,probstruct)

algoptions = bads('all');                   % Get default settings

algoptions.MaxFunEvals = probstruct.MaxFunEvals;
algoptions.TolFun = probstruct.TolFun;          % Standard TolFun
algoptions.TrueMinX = probstruct.TrueMinX;
algoptions.OptimToolbox = [];                    % Use Optimization Toolbox
% algoptions.Plot = 'scatter';

switch algoset
    case {0,'debug'}; algoset = 'debug'; algoptions.Debug = 1; algoptions.Plot = 'scatter';
    case {1,'base'}; algoset = 'base';           % Use defaults
    case {2,'robust'}; algoset = 'robust'; algoptions.ImprovementQuantile = 0.33;
    case {3,'robust2'}; algoset = 'robust2'; algoptions.ImprovementQuantile = 0.25;
    case {4,'robust3'}; algoset = 'robust3'; algoptions.ImprovementQuantile = 0.1;
    case {5,'x2'}; algoset = 'x2'; algoptions.SearchGridNumber = 10; algoptions.PollMeshMultiplier = 2;        
    case {6,'x4'}; algoset = 'x4'; algoptions.SearchGridNumber = 5; algoptions.PollMeshMultiplier = 4;        
    case {7,'forcepoll'}; algoset = 'forcepoll'; algoptions.SearchGridNumber = 10; algoptions.PollMeshMultiplier = 2; algoptions.ForcePollMesh = 1;        
    case {100,'noisy'}; algoset = 'noisy'; algoptions.UncertaintyHandling = 1;
    otherwise
        error(['Unknown algorithm setting ''' algoset ''' for algorithm ''' algo '''.']);
end

% Increase base noise with noisy functions
if ~isempty(probstruct.Noise) || probstruct.IntrinsicNoisy
    algoptions.UncertaintyHandling = 'on';
    NoiseEstimate = probstruct.NoiseEstimate;
    if isempty(NoiseEstimate); NoiseEstimate = 1; end    
    algoptions.NoiseSize = NoiseEstimate(1);
else
    algoptions.UncertaintyHandling = 'off';
end

% Variables with periodic boundary
if isfield(probstruct, 'PeriodicVars')
    algoptions.PeriodicVars = probstruct.PeriodicVars;
end

% Variables are already rescaled by BENCHMARK
algoptions.NonlinearScaling = 0;

PLB = probstruct.InitRange(1,:);
PUB = probstruct.InitRange(2,:);
LB = probstruct.LowerBound;
UB = probstruct.UpperBound;
x0 = probstruct.InitPoint;
D = size(x0,2);

[x,fval,exitFlag,output] = ...
    bads(@(x) benchmark_func(x,probstruct),x0,LB,UB,PLB,PUB,algoptions);
history = benchmark_func(); % Retrieve history
history.scratch = output;