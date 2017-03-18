function [history,x,fval,algoptions] = algorithm_bipopcmaes(algo,algoset,probstruct)

algoptions.TolFun = probstruct.TolFun;             % Standard TolFun
algoptions.MaxFunEvals  = probstruct.MaxFunEvals; % Maximal number of fevals
algoptions.MaxIter      = Inf;                       % No iteration limit
algoptions.Lbounds      = probstruct.LowerBound(:);  % Lower bound
algoptions.Ubounds      = probstruct.UpperBound(:);  % Upper bound
algoptions.PopSize      = '(4 + floor(3*log(N)))';  % population size, lambda
algoptions.ParentNumber = 'floor(popsize/2)';       % AKA mu, popsize equals lambda;
algoptions.Noise.on     = 0;  % Uncertainty handling
algoptions.Restarts     = 9;  % Keep restarting
algoptions.IncPopSize   = 2;  % multiplier for population size before each restart
algoptions.EvalParallel    = 'off';

algoptions.ReadSignals  = 'off'; % from file signals.par for termination, yet a stumb';
algoptions.Seed         = probstruct.Id;   % evaluated if it is a string;
algoptions.SaveVariables = 'off';
algoptions.LogModulo    = 0;
algoptions.LogTime      = 0;

switch algoset
    case {1,'base'}; algoset = 'base'; % Use defaults
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

% x0 = probstruct.InitPoint(:);
x0 = ['[' num2str(probstruct.InitRange(1,:)) ']'' + rand(' num2str(probstruct.D) ',1).*([' ...
    num2str(probstruct.InitRange(2,:)) ']'' - [' num2str(probstruct.InitRange(1,:)) ']'')'];

% Suggested starting sigma (std of uniform distribution over the range)
insigma = (probstruct.InitRange(2,:) - probstruct.InitRange(1,:))'/sqrt(12);

[x,fval,counteval,stopflag,out,bestever] = ...
    bipopcmaes('benchmark_func',x0,insigma,algoptions,probstruct);

x = x';

history = benchmark_func(); % Retrieve history

% Clean output files
%trashfile = [pwd filesep 'glsinput.mat']; 
%if exist(trashfile, 'file'); delete(trashfile); end