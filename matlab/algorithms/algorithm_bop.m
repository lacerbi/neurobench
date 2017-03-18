function history = algorithm_bop(algo,algoset,probstruct)

algoptions.TolFun = probstruct.TolFun;             % Standard TolFun
algoptions.Ninit = 50;
algoptions.MaxFunEvals = probstruct.MaxFunEvals;
algoptions.PopSize = 200;
algoptions.OptimizationMethod = 'mcs';
algoptions.SelectionMethod = 'one';
algoptions.TrainingMethod = 'Sample';

switch algoset
    case {1,'base'}; algoset = 'base'; % Use defaults
    otherwise
        error(['Unknown algorithm setting ''' algoset ''' for algorithm ''' algo '''.']);
end

LB = probstruct.LowerBound;
UB = probstruct.UpperBound;

[x,fval,exitFlag,output,population,scores] = ...
    bop(@(x) benchmark_func(x,probstruct),probstruct.InitRange,LB,UB,algoptions);

history = benchmark_func(); % Retrieve history

% Clean output files
trashfile = [pwd filesep 'glsinput.mat']; 
if exist(trashfile, 'file'); delete(trashfile); end