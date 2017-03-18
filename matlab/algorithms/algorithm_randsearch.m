function [history,x,fval,algoptions] = algorithm_randsearch(algo,algoset,probstruct)

algoptions.LikelySearchProbability = 0.8;
algoptions.MaxFunEvals = probstruct.MaxFunEvals;
algoptions.TolFun = probstruct.TolFun;             % Standard TolFun

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

if verbose
    displayFormat = ' %5.0f    %12.6g\n';
    fprintf(' f-count          f(x)\n');
    % fprintf(displayFormat, 0, optimState.funccount, fval, MeshSize, '', '');    
end

for iter = 1:algoptions.MaxFunEvals
            
    fnew = benchmark_func(x0,probstruct);
    
    if fnew < fval
        fval = fnew; 
        x = x0; 
        if verbose
            fprintf(displayFormat,iter,fval);
        end
    end

    if rand() < algoptions.LikelySearchProbability
        x0 = PLB + rand(1,D).*(PUB - PLB);
    else
        x0 = LB + rand(1,D).*(UB - LB);            
    end
        
end

history = benchmark_func(); % Retrieve history