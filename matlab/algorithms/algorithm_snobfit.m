function [history,x,fval,algoptions] = algorithm_snobfit(algo,algoset,probstruct)

smax = 10 + 5*probstruct.D;     % Default maximum number of levels
nf = probstruct.MaxFunEvals;     % Maximum number of fcn evaluations
stop = Inf;                     % Never stop


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

snobfit('testfile',[],[],params,dx);

funcCount = 0;
iter = 1;

% error('need to fix a few things in SNOBFIT');

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
    
    [x,xbest,fbest] = snobfit('testfile',x,fval,params);
    
    fprintf('%.4g    %.4f\n',funcCount,fbest);
    
    iter = iter + 1;
end

history = benchmark_func(); % Retrieve history

% Clean output files
%trashfile = [pwd filesep 'glsinput.mat']; 
%if exist(trashfile, 'file'); delete(trashfile); end