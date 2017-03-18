function [history,x,fval,algoptions] = algorithm_fmincon(algo,algoset,probstruct)

nvars = probstruct.D;

algoptions.TolFun = probstruct.TolFun;             % Standard TolFun
algoptions.MaxFunEvals = probstruct.MaxFunEvals;
algoptions.Algorithm = 'interior-point';

switch algoset
    case {1,'1','base','ip'}; algoset = 'base';  % Use defaults
    case {2,'2','sqp'}; algoset = 'sqp'; algoptions.Algorithm = 'sqp';
    case {3,'3','actset'}; algoset = 'actset'; algoptions.Algorithm = 'active-set';
    case {4,'4','diffmin'}; algoset = 'diffmin'; algoptions.DiffMinChange = 5e-3;
    case {5,'5','lhs'}; algoset = 'lhs'; algoptions.Ninit = nvars;
    case {6,'6','sqplhs'}; algoset = 'sqplhs'; algoptions.Ninit = nvars; algoptions.Algorithm = 'sqp';
    case {7,'7','shortruns'}; algoset = 'shortruns'; algoptions.MaxFunEvals = nvars*50;
        
    otherwise
        error(['Unknown algorithm setting ''' algoset ''' for algorithm ''' algo '''.']);
end

% Manage verbosity
if isfield(probstruct,'Verbose') && probstruct.Verbose
    algoptions.Display = 'iter';
else
    algoptions.Display = 'off';
end

% Minimum finite difference step with noisy functions
if ~isempty(probstruct.Noise) || probstruct.IntrinsicNoisy
    algoptions.DiffMinChange = 1e-2;
end

PLB = probstruct.InitRange(1,:);
PUB = probstruct.InitRange(2,:);
LB = probstruct.LowerBound;
UB = probstruct.UpperBound;
x0 = probstruct.InitPoint;

% Initial LHS design if Ninit > 0 (otherwise just returns X0)
x0 = algorithm_lhsinit(x0,PLB,PUB,algoptions,probstruct);

[x,fval] = ...
    fmincon(@(x) benchmark_func(x,probstruct),x0,[],[],[],[],LB,UB,[],algoptions);

history = benchmark_func(); % Retrieve history