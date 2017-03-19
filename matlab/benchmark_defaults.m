function defaults = benchmark_defaults(type,probstruct,options)
%BENCHMARK_DEFAULTS Return default options structure.

if nargin < 2; probstruct = []; end
if nargin < 3; options = []; end

switch lower(type)
    case 'options'
        defaults.OutputDataPrefix = '';  % Prefix to all output files
        defaults.CharFileSep = '@';      % Char separating parts in path and file names

        defaults.PathDirectory = [];     % Path of matlab files
        defaults.RootDirectory = [];     % Root of benchmark results directory tree
        defaults.ProblemDirectory = 'C:/Users/Luigi/Dropbox/Postdoc/BenchMark/problems-data';  % Path of benchmark problem files
        defaults.Display = 'on';         % Level of display
        defaults.ScaleVariables = 'on';  % Center and rescale variables
        defaults.TolFun = 1e-6;          % Required tolerance on function
        defaults.TolX = 1e-6;            % Tolerance on X distance
        defaults.StartFromMinX = 0;      % Start from guessed min X?
        defaults.MaxFunEvalMultiplier = 1;      % Increase # func evals
        defaults.StopSuccessfulRuns = 1; % Stop runs when successful
        defaults.SpeedTests = 10;        % Iterations of speed tests
    
        defaults.LineStyle = {'-','-','-','-','-.','-.','-.','-.','-.','-.','-.','-','-.','-','-','-','-','-'};
        % defaults.LineStyle = {'-','-.','-','-','-','-','-','-','-','-'};
        defaults.LineColor = [  ...
            141 211 199; ...            % fminsearch
            251 128 114; ...            % fmincon
            128 177 211; ...            % patternsearch
            253 180 98; ...             % mcs
            160 120 100; ...            % global
            70 70 233; ...              % random search
            252 205 229; ...            % simulated annealing
            165 211 195; ...            % genetic algorithm
            159 212 105; ...            % particle swarm
            188 128 189; ...            % cma-es
            212 148 169; ...            % bipop-cma-es            
            88 198 89; ...              % cma-es
            112 248 129; ...            % bipop-cma-es            
            60 220 200; ...            % global
            170 70 133; ...              % random search
            41 111 199; ...            % fminsearch
            151 228 214; ...            % fmincon
            0 0 0 ...                   % bps
            ]/255;
        
    case 'problem'
        
        defaults.ConstraintPenalty = 100;
        defaults.NonAdmissibleFuncValue = 5000;
        defaults.MaxFunEvals = 500*probstruct.D;
        defaults.TolFun = options.TolFun;   % Precision data
        defaults.SaveTicks = [];            % Time to save data
        defaults.Thresholds = 10.^(1:-0.2:-3); % Recorded thresholds (only if true minimum is known)
        defaults.Noise = [];
        defaults.NoiseSigma = [];           % Added artificial noise
        defaults.NoiseEstimate = [];        % Estimated size of noise   
        defaults.AvgSamples = 10;           % Max # samples for estimating min fval of noisy functions
        defaults.CandidateX = 2 + ceil(sqrt(probstruct.D)); % Maximum candidate best point per optimization iteration 
        defaults.TrueMinFval = NaN;

end