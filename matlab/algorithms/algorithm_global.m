function [history,x,fval,algoptions] = algorithm_global(algo,algoset,probstruct)

algoptions.MAXFUNEVALS = probstruct.MaxFunEvals;
algoptions.METHOD = 'unirandi';
algoptions.MAXFN = 5e3;

% NSIG influences the convergence criterion in a nontrivial way -- keep
% the default GLOBAL value
% algoptions.NSIG = -log10(probstruct.TolFun);

%  'N100',       10*NPARM,...             % Number of sample points to be drawn uniformly in one cycle
%  'NG0',        min(2*NPARM,20),...      % Number of best points selected from the actual sample
%  'NSIG',       6,...                    % Convergence criterion
%  'MAXFN',      1000,...                 % Maximum number of function evaluations for local search
%  'MAXNLM',     20,...                   % Maximum number of local minima  

switch algoset
    case {1,'base'}; algoset = 'base'; % Use defaults
    case {2,'bfgs'}; algoset = 'bfgs'; algoptions.METHOD = 'bfgs'; % Use bfgs method
    case {3,'fmincon'}; algoset = 'fmincon'; algoptions.METHOD = 'fmincon'; % Use fmincon (active-set) method
    case {4,'bps'}; algoset = 'bps'; algoptions.METHOD = 'bps'; % Use BPS
    otherwise
        error(['Unknown algorithm setting ''' algoset ''' for algorithm ''' algo '''.']);
end

% Manage verbosity
if isfield(probstruct,'Verbose') && probstruct.Verbose
    algoptions.DISPLAY = 'on';
else
    algoptions.DISPLAY = 'off';
end

LB = probstruct.LowerBound;
UB = probstruct.UpperBound;

[x,fval,nc,nfe] = myGLOBAL(@(x) benchmark_func(x,probstruct),LB(:),UB(:),algoptions);

x = x';

history = benchmark_func(); % Retrieve history