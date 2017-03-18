function [history,x,fval,algoptions] = algorithm_mcs(algo,algoset,probstruct)

algoptions.smax = 10 + 5*probstruct.D;     % Default maximum number of levels
algoptions.nf = probstruct.MaxFunEvals;    % Maximum number of fcn evaluations
algoptions.stop = Inf;                     % Never stop

switch algoset
    case {1,'base'}; algoset = 'base'; % Use defaults
    case {2,'deep'}; algoset = 'deep'; algoptions.smax = 10*probstruct.D; % Go deeper
    otherwise
        error(['Unknown algorithm setting ''' algoset ''' for algorithm ''' algo '''.']);
end

% Manage verbosity
if isfield(probstruct,'Verbose') && probstruct.Verbose; algoptions.prt = 1; else algoptions.prt = 0; end

LB = probstruct.LowerBound;
UB = probstruct.UpperBound;
x0 = probstruct.InitPoint;

algoptions.iinit.x0 = [probstruct.InitRange(1,:)', x0(:), probstruct.InitRange(2,:)'];
algoptions.iinit.l = 2*ones(probstruct.D,1);
algoptions.iinit.L = 3*ones(probstruct.D,1);

[xbest,fbest,xmin,fmi,ncall,ncloc]=...
    mymcs('benchmark_func',probstruct,LB(:),UB(:),algoptions.prt,algoptions.smax,algoptions.nf,algoptions.stop,algoptions.iinit);

xmin

try
    x = [xbest(:)'; xmin'];
catch
    x = [xbest(:)'; xmin];      % Sometimes XMIN gets transposed?
end    
fval = [fbest; fmi(:)];

history = benchmark_func(); % Retrieve history

% Clean output files
trashfile = [pwd filesep 'glsinput.mat']; 
if exist(trashfile, 'file'); delete(trashfile); end