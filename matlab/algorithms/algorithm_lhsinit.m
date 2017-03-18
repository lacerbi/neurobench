function [x0,fval] = algorithm_lhsinit(x0,PLB,PUB,algoptions,probstruct)
%ALGORITHM_LHSINIT Initial design with Latin hypercube sampling

nvars = size(x0,2);

if isfield(algoptions,'Ninit') && ~isempty(algoptions.Ninit)
    Ninit = algoptions.Ninit;
    Ninit = min(Ninit, algoptions.MaxFunEvals);
    algoptions.MaxFunEvals = algoptions.MaxFunEvals - Ninit;
else
    Ninit = 0;
end

fval = Inf;

% Initial experiment design
if Ninit > 0
    X = lhs(Ninit,nvars,PLB,PUB,x0);
    X = [x0; X];
    for i = 1:size(X,1)
        fnew = benchmark_func(X(i,:),probstruct);
        if fnew < fval; x0 = X(i,:); fval = fnew; end
    end
end

end