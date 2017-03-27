function [history,x,fval,algoptions] = algorithm_snobfit(algo,algoset,probstruct)

algoptions.smax = 10 + 5*probstruct.D;     % Default maximum number of levels
algoptions.nf = probstruct.MaxFunEvals;    % Maximum number of fcn evaluations
algoptions.stop = Inf;                     % Never stop

switch algoset
    case {1,'base'}; algoset = 'base'; % Use defaults
    otherwise
        error(['Unknown algorithm setting ''' algoset ''' for algorithm ''' algo '''.']);
end

LB = probstruct.LowerBound;
UB = probstruct.UpperBound;

params = struct('bounds',{LB,UB},'nreq',1,'p',0.5);
dx = diff(probstruct.InitRange,[],1)*1e-4;

% Random starting points
r = rand(20, probstruct.D);
x = bsxfun(@plus, probstruct.InitRange(1,:), ...
    bsxfun(@times, r, probstruct.InitRange(2,:) - probstruct.InitRange(1,:)));

% SNOBFIT I/O file
algoptions.filename = ['snobtmp_' algoset '_' num2str(probstruct.Id) '.mat'];
trashfile = [pwd filesep algoptions.filename]; 

% Clean output files
if exist(trashfile, 'file'); delete(trashfile); end

snobfit(algoptions.filename,[],[],params,dx);

funcCount = 0;
iter = 1;

while 1
    np = size(x,1);
    x = x(:,1:probstruct.D);
    
    fval = 0*ones(np,2);
    for i = 1:np
        fval(i,1) = benchmark_func(x(i,:),probstruct);
    end
    funcCount = funcCount + np;

    wt = 1 - max(0,min(1,2.5*(funcCount/probstruct.MaxFunEvals - 0.1)));
    lbt = wt*probstruct.InitRange(1,:) + (1-wt)*LB;
    ubt = wt*probstruct.InitRange(2,:) + (1-wt)*UB;
    params = struct('bounds',{lbt,ubt},'nreq',probstruct.D+6,'p',0.5);        
    
    [x,xbest,fbest] = snobfit(algoptions.filename,x,fval,params);
    
    fprintf('%.4g    %.4f\n',funcCount,fbest);
    
    history = benchmark_func();
    if history.FunCalls >= probstruct.MaxFunEvals; break; end
    
    iter = iter + 1;
end

x = xbest;
fval = fbest;

history = benchmark_func(); % Retrieve history

% Clean output files
if exist(trashfile, 'file'); delete(trashfile); end