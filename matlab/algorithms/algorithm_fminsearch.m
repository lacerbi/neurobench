function [history,x,fval,algoptions] = algorithm_fminsearch(algo,algoset,probstruct)

nvars = probstruct.D;

algoptions = optimset();
algoptions.MaxFunEvals = probstruct.MaxFunEvals;
algoptions.TolFun = probstruct.TolFun;             % Standard TolFun

switch algoset
    case {1,'base'}; algoset = 'base'; % Use defaults
    case {2,'2','lhs'}; algoset = 'lhs'; algoptions.Ninit = nvars;        
    otherwise
        error(['Unknown algorithm setting ''' algoset ''' for algorithm ''' algo '''.']);
end

% Manage verbosity
if isfield(probstruct,'Verbose') && probstruct.Verbose
    algoptions.Display = 'iter';
else
    algoptions.Display = 'off';
end

PLB = probstruct.InitRange(1,:);
PUB = probstruct.InitRange(2,:);
LB = probstruct.LowerBound;
UB = probstruct.UpperBound;
x0 = probstruct.InitPoint;

% Initial LHS design if Ninit > 0 (otherwise just returns X0)
x0 = algorithm_lhsinit(x0,PLB,PUB,algoptions,probstruct);

[x,fval] = ...
    fminsearchbnd(@(x) benchmark_func(x,probstruct),x0,LB,UB,algoptions);

history = benchmark_func(); % Retrieve history