function history = algorithm_hybridsearch(algo,algoset,probstruct)

algoptions = optimset();
algoptions.TolFun = probstruct.TolFun;             % Standard TolFun

switch algoset
    case {1,'1','base','ip'}; algoset = 'base'; algoptions.Algorithm = 'interior-point'; % Use defaults
    case {2,'2','sqp'}; algoset = 'sqp'; algoptions.Algorithm = 'sqp';
    case {3,'3','actset'}; algoset = 'actset'; algoptions.Algorithm = 'active-set';
    case {4,'4','fminsearch'}; algoset = 'fminsearch';
    case {5,'5','patternsearch'}; algoset = 'patternsearch';
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

% Run a round of quick optimizations first
%precisionVector = [0 0.25 0.5 0.75 1];
precisionVector = [0 1];
algoptions.MaxFunEvals = ceil(probstruct.MaxFunEvals*0.05);
for i = 1:length(precisionVector)
    probstruct.Precision = precisionVector(i);
    switch lower(algoset)
        case 'fminsearch'
            x0 = fminsearchbnd(@(x) benchmark_func(x,probstruct),x0,LB,UB,algoptions);
        case 'patternsearch'
            if isfield(algoptions,'Algorithm'); algoptions = rmfield(algoptions,'Algorithm'); end
            x0 = patternsearch(@(x) benchmark_func(x,probstruct),x0,[],[],[],[],LB,UB,[],algoptions);            
        otherwise
            x0 = fmincon(@(x) benchmark_func(x,probstruct),x0,[],[],[],[],LB,UB,[],algoptions);
    end
end

% Start patternsearch from alleged minimum
probstruct.Precision = 1;
algoptions = rmfield(algoptions,'Algorithm');
algoptions.MaxFunEvals = probstruct.MaxFunEvals - length(precisionVector)*algoptions.MaxFunEvals;

x = ...
    patternsearch(@(x) benchmark_func(x,probstruct),x0,[],[],[],[],LB,UB,[],algoptions);

history = benchmark_func(); % Retrieve history