function [history,x,fval,algoptions] = algorithm_randsearch(algo,algoset,probstruct)

algoptions.LikelySearchProbability = 0.8;
algoptions.MaxFunEvals = probstruct.MaxFunEvals;
algoptions.TolFun = probstruct.TolFun;             % Standard TolFun
algoptions.CacheSize = 100;                        % Max returned points

switch algoset
    case {1,'base'}; algoset = 'base'; % Use defaults
    otherwise
        error(['Unknown algorithm setting ''' algoset ''' for algorithm ''' algo '''.']);
end

if isfield(probstruct,'Verbose') && probstruct.Verbose; verbose = 1; else verbose = 0; end

D = probstruct.D;
PLB = probstruct.InitRange(1,:);
PUB = probstruct.InitRange(2,:);
LB = probstruct.LowerBound;
UB = probstruct.UpperBound;
x0 = probstruct.InitPoint;

x = x0;
fval = Inf;

if algoptions.MaxFunEvals > 0

    if verbose
        displayFormat = ' %5.0f    %12.6g\n';
        fprintf(' f-count          f(x)\n');
        % fprintf(displayFormat, 0, optimState.funccount, fval, MeshSize, '', '');    
    end
    
    % Evaluate starting point
    fnew = benchmark_func(x0,probstruct);
    x = NaN(algoptions.MaxFunEvals,numel(x0));
    fval = NaN(algoptions.MaxFunEvals,numel(fnew));
    x(1,:) = x0;
    fval(1,:) = fnew;
    fvalmin = fval;
    if verbose; fprintf(displayFormat,1,fval(1)); end

    % Loop over random search points
    for iter = 2:algoptions.MaxFunEvals
        
        % Draw new random point (mostly from plausible volume)
        if rand() < algoptions.LikelySearchProbability
            x0 = PLB + rand(1,D).*(PUB - PLB);
        else
            x0 = LB + rand(1,D).*(UB - LB);            
        end
        
        fnew = benchmark_func(x0,probstruct);
        x(iter,:) = x0;
        fval(iter,:) = fnew;        

        if fnew(1) < fvalmin(1)
            fvalmin = fnew; 
            if verbose; fprintf(displayFormat,iter,fval(iter,1)); end
        end

    end
end

% Order points by their score (from lowest to highest)
[~,ord] = sort(fval(:,1),'ascend');
x = x(ord(1:min(end,algoptions.CacheSize)),:);
fval = fval(ord(1:min(end,algoptions.CacheSize)),:);

history = benchmark_func(); % Retrieve history