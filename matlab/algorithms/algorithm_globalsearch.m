function history = algorithm_globalsearch(algo,algoset,probstruct)

%algoptions.MaxFunEvals = probstruct.MaxFunEvals;

switch algoset
    case {1,'base'}; algoset = 'base'; % Use defaults
    otherwise
        error(['Unknown algorithm setting ''' algoset ''' for algorithm ''' algo '''.']);
end

problem = createOptimProblem('fmincon',...
    'x0',probstruct.InitPoint, ...
    'lb',probstruct.LowerBound, 'ub',probstruct.UpperBound, ...
    'objective', @(x) benchmark_func(x,probstruct));

%PLB = probstruct.InitRange(1,:);
%PUB = probstruct.InitRange(2,:);

% Compute time
dbounds = probstruct.InitRange(2,:) - probstruct.InitRange(1,:);
n = 0; elapsedTime = 0;
start = tic;
while elapsedTime < 5
    xr = rand(1, probstruct.D).*dbounds + probstruct.InitRange(1,:);
    benchmark_func(xr,probstruct);
    elapsedTime = toc(start);
    n = n + 1;
end
costPerFun = elapsedTime / n;
display(['Cost per function call: ' num2str(costPerFun,'%.6g')]);

clear benchmark_func;

gs = GlobalSearch('Display','iter','MaxTime',100*costPerFun*probstruct.MaxFunEvals,'TolFun',probstruct.TolFun);

[x,fval,exitflag,output,solutions] = run(gs,problem);

history = benchmark_func(); % Retrieve history

% Clean output files
trashfile = [pwd filesep 'glsinput.mat']; 
if exist(trashfile, 'file'); delete(trashfile); end