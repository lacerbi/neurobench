function [history,x,fval,algoptions] = algorithm_cmaes(algo,algoset,probstruct)

algoptions.TolFun = probstruct.TolFun;             % Standard TolFun
algoptions.MaxFunEvals  = probstruct.MaxFunEvals; % Maximal number of fevals
algoptions.MaxIter      = Inf;                       % No iteration limit
algoptions.Lbounds      = probstruct.LowerBound(:);  % Lower bound
algoptions.Ubounds      = probstruct.UpperBound(:);  % Upper bound
algoptions.PopSize      = '(4 + floor(3*log(N)))';  % population size, lambda
algoptions.ParentNumber = 'floor(popsize/2)';       % AKA mu, popsize equals lambda;
algoptions.Noise.on     = 0;  % Uncertainty handling
algoptions.Restarts     = 0;  % Restarts are handled "manually"
algoptions.IncPopSize   = 2;  % multiplier for population size before each restart

algoptions.ReadSignals  = 'off'; % from file signals.par for termination, yet a stumb';
algoptions.Seed         = probstruct.Id;   % evaluated if it is a string;
algoptions.SaveVariables = 'off';
algoptions.LogModulo    = 0;
algoptions.LogTime      = 0;

switch algoset
    case {1,'base'}; algoset = 'base'; % Use defaults
    case {2,'active'}; algoset = 'active'; algoptions.CMA.Active = 1;
    case {11,'base-lhs'}; algoset = 'base-lhs'; algoptions.Ninit = nvars;
    case {12,'active-lhs'}; algoset = 'active-lhs'; algoptions.CMA.Active = 1; algoptions.Ninit = nvars;       
    case {100,'noisy'}; algoset = 'noisy'; algoptions.Noise.on = 1;
    otherwise
        error(['Unknown algorithm setting ''' algoset ''' for algorithm ''' algo '''.']);
end

% Manage verbosity
if isfield(probstruct,'Verbose') && probstruct.Verbose
    algoptions.DispFinal  = 'on';
    algoptions.DispModulo = ceil(algoptions.MaxFunEvals/100);
else
    algoptions.DispFinal  = 'off';
    algoptions.DispModulo = Inf;
end

x0 = probstruct.InitPoint(:);
% Suggested starting sigma (std of uniform distribution over the range)
insigma = (probstruct.InitRange(2,:) - probstruct.InitRange(1,:))'/sqrt(12);

% Change population size based on iteration number (restarts)
N = length(x0);
algoptions.PopSize = eval(algoptions.PopSize)*(algoptions.IncPopSize^(probstruct.nIters-1));

% Initial LHS design if Ninit > 0 (otherwise just returns X0)
x0 = algorithm_lhsinit(x0,PLB,PUB,algoptions,probstruct);

[~,~,counteval,stopflag,out] = ...
    cmaes('benchmark_func',x0,insigma,algoptions,probstruct);

x = [out.solutions.bestever.x';out.solutions.recentbest.x';out.solutions.mean.x'];
fval = [out.solutions.bestever.f;out.solutions.recentbest.f;out.solutions.mean.f];

history = benchmark_func(); % Retrieve history

% Clean output files
trashfile = [pwd filesep 'glsinput.mat']; 
if exist(trashfile, 'file'); delete(trashfile); end