function history = algorithm_hkopt(algo,algoset,probstruct)

algoptions.MaxFunEvals = probstruct.MaxFunEvals;
algoptions.TolFun = probstruct.TolFun;             % Standard TolFun

switch algoset
    case {1,'base'}; algoset = 'base'; % Use defaults
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

x = HK_opt(x0,@(x) benchmark_func(x,probstruct),-algoptions.MaxFunEvals);

history = benchmark_func(); % Retrieve history