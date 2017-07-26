function [history,x,fval,algoptions] = algorithm_bayesopt(algo,algoset,probstruct)

MaxIters = 300; % Maximum number of BO iterations

algoptions.AcquisitionFunctionName = 'expected-improvement-plus';
algoptions.ExplorationRatio = 0.5;

algoptions.NumSeedPoints = 4;
algoptions.MaxObjectiveEvaluations = min(probstruct.MaxFunEvals, MaxIters);
algoptions.MaxTime = Inf;

% External constraint function
algoptions.XConstraintFcn = [];

algoptions.Verbose = 1;
algoptions.OutputFcn = [];
algoptions.PlotFcn = {};


switch algoset
    case {0,'debug'}; algoset = 'debug'; algoptions.Debug = 1; algoptions.Plot = 'scatter';
    case {1,'base'}; algoset = 'base';           % Use defaults
    otherwise
        error(['Unknown algorithm setting ''' algoset ''' for algorithm ''' algo '''.']);
end

% Increase base noise with noisy functions
if ~isempty(probstruct.Noise) || probstruct.IntrinsicNoisy
    algoptions.IsObjectiveDeterministic = false;
else
    algoptions.IsObjectiveDeterministic = true;
end

% Variables with periodic boundary
%if isfield(probstruct, 'PeriodicVars')
%    algoptions.PeriodicVars = probstruct.PeriodicVars;
%end

% Variables are already rescaled by BENCHMARK

PLB = probstruct.InitRange(1,:);
PUB = probstruct.InitRange(2,:);
LB = probstruct.LowerBound;
UB = probstruct.UpperBound;
x0 = probstruct.InitPoint;
D = size(x0,2);

% Define optimization variables
for iVar = 1:D
    Variables(iVar) = optimizableVariable( ...
        ['x' num2str(iVar)], [LB(iVar), UB(iVar)], ...
        'Type', 'real', 'Transform', 'none', 'Optimize', true);    
end

x = x0; fval = NaN; results = [];

tabnames = [];
for iVar = 1:numel(Variables); tabnames{iVar} = Variables(iVar).Name; end

% Evaluate function on X0 and initial grid within plausible bounds
for iter = 1:min(algoptions.MaxObjectiveEvaluations, algoptions.NumSeedPoints)
    if iter > 1; x0(iter,:) = PLB + rand(1,D).*(PUB - PLB); end
    temp = tic;
    fvalsinit(iter,:) = benchmark_func1(x0(iter,:),probstruct);
    t(iter,:) = toc(temp);
end

% Best initial point
if numel(fvalsinit) > 1
    [fval,idx] = min(fvalsinit);
    x = x0(idx,:);
end

x0tab = array2table(x0,'VariableNames',tabnames);

if algoptions.MaxObjectiveEvaluations > 1
    results = bayesopt(@(x) benchmark_func1(x,probstruct), Variables, ...
        'AcquisitionFunctionName', algoptions.AcquisitionFunctionName, ...
        'ExplorationRatio', algoptions.ExplorationRatio, ...
        'NumSeedPoints', algoptions.NumSeedPoints, ...
        'MaxObjectiveEvaluations', algoptions.MaxObjectiveEvaluations, ...
        'MaxTime', algoptions.MaxTime, ...
        'XConstraintFcn', algoptions.XConstraintFcn, ...
        'Verbose', algoptions.Verbose, ...
        'OutputFcn', algoptions.OutputFcn, ...
        'PlotFcn', algoptions.PlotFcn, ...
        'IsObjectiveDeterministic', algoptions.IsObjectiveDeterministic, ...
        'InitialX', x0tab, ...
        'InitialObjective', fvalsinit, ...
        'InitialConstraintViolations', [], ...
        'InitialObjectiveEvaluationTimes', t ...
    );
end

% Return best observed point and best estimated point
x(1,:) = table2array(results.XAtMinObjective);
fval(1,:) = results.MinObjective;
x(2,:) = table2array(results.XAtMinEstimatedObjective);
fval(2,:) = results.MinEstimatedObjective;

history = benchmark_func(); % Retrieve history
history.scratch = results;