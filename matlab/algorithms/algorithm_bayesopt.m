function [history,x,fval,algoptions] = algorithm_bayesopt(algo,algoset,probstruct)

MaxIters = 300; % Maximum number of BO iterations

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

% Deterministic or noisy functions
if ~isempty(probstruct.Noise) || probstruct.IntrinsicNoisy
    algoptions.IsObjectiveDeterministic = false;
else
    algoptions.IsObjectiveDeterministic = true;
end

% Acquisition function depends on whether computation time is fixed
if probstruct.VariableComputationTime
    algoptions.AcquisitionFunctionName = 'expected-improvement-per-second-plus';
else
    algoptions.AcquisitionFunctionName = 'expected-improvement-plus';
end

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
if numel(fvalsinit) > 0
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

    % Return best observed point
    [xtab, ~, iter1] = bestPoint(results, 'Criterion', 'min-observed');
    x(1,:) = table2array(xtab);
    fval(1,:) = results.ObjectiveTrace(iter1,:);    
    
    % For noisy functions also return best estimated point
    if ~algoptions.IsObjectiveDeterministic
        [xtab, ~, iter2] = bestPoint(results, 'Criterion', 'min-visited-upper-confidence-interval', 'Alpha', 0.01);
        if iter2 ~= iter1
            x(2,:) = table2array(xtab);
            fval(2,:) = results.ObjectiveTrace(iter2,:);
        end
    end

end

history = benchmark_func(); % Retrieve history
history.scratch = results;