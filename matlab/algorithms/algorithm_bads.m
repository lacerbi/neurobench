function [history,x,fval,algoptions] = algorithm_bads(algo,algoset,probstruct)

algoptions = bads('all');                   % Get default settings

% BADS old defaults -- some of these may have changed
algoptions.SearchGridNumber = 10;
algoptions.PollMeshMultiplier = 2;
algoptions.PollAcqFcn = '@acqNegEI';
algoptions.SearchAcqFcn = '@acqNegEI';
algoptions.gpMethod = 'grid';
algoptions.NoiseFinalSamples = 0;
algoptions.TrustGPfinal = true;

% Options from current problem
algoptions.MaxFunEvals = probstruct.MaxFunEvals;
algoptions.TolFun = probstruct.TolFun;          % Standard TolFun
algoptions.TrueMinX = probstruct.TrueMinX;
algoptions.OptimToolbox = [];                    % Use Optimization Toolbox
% algoptions.Plot = 'scatter';


switch algoset
    case {0,'debug'}; algoset = 'debug'; algoptions.Debug = 1; algoptions.Plot = 'scatter';
    case {1,'base'}; algoset = 'base';           % Use defaults
    case {2,'robust'}; algoset = 'robust'; algoptions.ImprovementQuantile = 0.33;
    case {3,'robust2'}; algoset = 'robust2'; algoptions.ImprovementQuantile = 0.25;
    case {4,'robust3'}; algoset = 'robust3'; algoptions.ImprovementQuantile = 0.1;
    case {5,'x2'}; algoset = 'x2'; algoptions.SearchGridNumber = 10; algoptions.PollMeshMultiplier = 2;        
    case {6,'x4'}; algoset = 'x4'; algoptions.SearchGridNumber = 5; algoptions.PollMeshMultiplier = 4;        
    case {7,'forcepoll'}; algoset = 'forcepoll'; algoptions.SearchGridNumber = 10; algoptions.PollMeshMultiplier = 2; algoptions.ForcePollMesh = 1;        
    case {8,'svgd'}; algoset = 'svgd'; algoptions.gpSamples = 10;
    case {9,'nearest'}; algoset = 'nearest'; algoptions.gpMethod = 'nearest';        
    case {11,'matern5'}; algoset = 'matern5'; algoptions.gpdefFcn = '{@gpdefBads,''matern5'',1}';        
    case {12,'sqexp'}; algoset = 'sqexp'; algoptions.gpdefFcn = '{@gpdefBads,''se'',1}';        
    case {21,'acqpi'}; algoset = 'acqpi'; algoptions.PollAcqFcn = '@acqNegPI'; algoptions.SearchAcqFcn = '@acqNegPI';        
    case {22,'acqlcb'}; algoset = 'acqlcb'; algoptions.PollAcqFcn = '{@acqLCB,[]}'; algoptions.SearchAcqFcn = '{@acqLCB,[]}';
    case {23,'acqpi_m5'}; algoset = 'acqpi_m5'; algoptions.PollAcqFcn = '@acqNegPI'; algoptions.SearchAcqFcn = '@acqNegPI'; algoptions.gpdefFcn = '{@gpdefBads,''matern5'',1}';
    case {24,'acqlcb_m5'}; algoset = 'acqlcb_m5'; algoptions.PollAcqFcn = '{@acqLCB,[]}'; algoptions.SearchAcqFcn = '{@acqLCB,[]}'; algoptions.gpdefFcn = '{@gpdefBads,''matern5'',1}';
    case {25,'acqpi_se'}; algoset = 'acqpi_se'; algoptions.PollAcqFcn = '@acqNegPI'; algoptions.SearchAcqFcn = '@acqNegPI'; algoptions.gpdefFcn = '{@gpdefBads,''se'',1}';        
    case {26,'acqlcb_se'}; algoset = 'acqlcb_se'; algoptions.PollAcqFcn = '{@acqLCB,[]}'; algoptions.SearchAcqFcn = '{@acqLCB,[]}'; algoptions.gpdefFcn = '{@gpdefBads,''se'',1}';
    case {29,'acqhedge'}; algoset = 'acqhedge'; algoptions.AcqHedge = 'on';
    case {31,'lcbnearest'}; algoset = 'lcbnearest'; algoptions.gpMethod = 'nearest'; algoptions.PollAcqFcn = '{@acqLCB,[]}'; algoptions.SearchAcqFcn = '{@acqLCB,[]}';
    case {32,'onesearch'}; algoset = 'onesearch'; algoptions.gpMethod = 'nearest'; algoptions.PollAcqFcn = '{@acqLCB,[]}'; algoptions.SearchAcqFcn = '{@acqLCB,[]}'; algoptions.SearchNtry = 1;
    case {33,'searchwcm'}; algoset = 'searchwcm'; algoptions.gpMethod = 'nearest'; algoptions.PollAcqFcn = '{@acqLCB,[]}'; algoptions.SearchAcqFcn = '{@acqLCB,[]}'; algoptions.SearchMethod = {@searchES,1,1};
    case {34,'searchell'}; algoset = 'searchell'; algoptions.gpMethod = 'nearest'; algoptions.PollAcqFcn = '{@acqLCB,[]}'; algoptions.SearchAcqFcn = '{@acqLCB,[]}'; algoptions.SearchMethod = {@searchES,2,1};
    case {35,'noscaling'}; algoset = 'noscaling'; algoptions.gpMethod = 'nearest'; algoptions.PollAcqFcn = '{@acqLCB,[]}'; algoptions.SearchAcqFcn = '{@acqLCB,[]}'; algoptions.gpRescalePoll = 0;
    case {36,'fixednoise'}; algoset = 'fixednoise'; algoptions.gpMethod = 'nearest'; algoptions.PollAcqFcn = '{@acqLCB,[]}'; algoptions.SearchAcqFcn = '{@acqLCB,[]}'; algoptions.MeshNoiseMultiplier = 0; algoptions.NoiseSize = algoptions.TolFun;
    case {37,'searcheye'}; algoset = 'searcheye'; algoptions.gpMethod = 'nearest'; algoptions.PollAcqFcn = '{@acqLCB,[]}'; algoptions.SearchAcqFcn = '{@acqLCB,[]}'; algoptions.SearchMethod = {@searchES,3,1};
    case {41,'lcbnearestfinal'}; algoset = 'lcbnearestfinal'; algoptions.NoiseFinalSamples = 8; algoptions.gpMethod = 'nearest'; algoptions.PollAcqFcn = '{@acqLCB,[]}'; algoptions.SearchAcqFcn = '{@acqLCB,[]}';
    case {42,'lcbnearestavg'}; algoset = 'lcbnearestavg'; algoptions.TrustGPfinal = 0; algoptions.NoiseFinalSamples = 10; algoptions.gpMethod = 'nearest'; algoptions.PollAcqFcn = '{@acqLCB,[]}'; algoptions.SearchAcqFcn = '{@acqLCB,[]}';
    case {43,'lcbnearestwarp'}; algoset = 'lcbnearestwarp'; algoptions.InputWarping = 1; algoptions.gpMethod = 'nearest'; algoptions.PollAcqFcn = '{@acqLCB,[]}'; algoptions.SearchAcqFcn = '{@acqLCB,[]}';
    case {44,'lcbnearestwarpalt'}; algoset = 'lcbnearestwarpalt'; algoptions.InputWarping = 1; algoptions.InputWarpStart = 'min(ceil(250*sqrt(nvars/15)),300)'; algoptions.gpMethod = 'nearest'; algoptions.PollAcqFcn = '{@acqLCB,[]}'; algoptions.SearchAcqFcn = '{@acqLCB,[]}';
    case {100,'noisy'}; algoset = 'noisy'; algoptions.UncertaintyHandling = 1;
    otherwise
        error(['Unknown algorithm setting ''' algoset ''' for algorithm ''' algo '''.']);
end

% Increase base noise with noisy functions
if ~isempty(probstruct.Noise) || probstruct.IntrinsicNoisy
    algoptions.UncertaintyHandling = 'on';
    NoiseEstimate = probstruct.NoiseEstimate;
    if isempty(NoiseEstimate); NoiseEstimate = 1; end    
    algoptions.NoiseSize = NoiseEstimate(1);
else
    algoptions.UncertaintyHandling = 'off';
end

% Variables with periodic boundary
if isfield(probstruct, 'PeriodicVars')
    algoptions.PeriodicVars = probstruct.PeriodicVars;
end

% Variables are already rescaled by BENCHMARK
algoptions.NonlinearScaling = 0;

PLB = probstruct.InitRange(1,:);
PUB = probstruct.InitRange(2,:);
LB = probstruct.LowerBound;
UB = probstruct.UpperBound;
x0 = probstruct.InitPoint;
D = size(x0,2);

[x,fval,exitFlag,output,optimState,gpstruct] = ...
    bads(@(x) benchmark_func(x,probstruct),x0,LB,UB,PLB,PUB,algoptions);
history = benchmark_func(); % Retrieve history
history.scratch = output;