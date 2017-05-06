function defaults = benchmark_defaults(type,probstruct,options,varargin)
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
        defaults.ForceFiniteBounds = 0;  % By default do not force finite bounds
    
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
        defaults.NonAdmissibleFuncValue = 1e4;
        defaults.MaxFunEvals = 500*probstruct.D;
        defaults.TolFun = options.TolFun;   % Precision data
        defaults.SaveTicks = [];            % Time to save data
        defaults.Thresholds = 10.^(1:-0.2:-3); % Recorded thresholds (only if true minimum is known)
        defaults.Noise = [];
        defaults.NoiseSigma = [];           % Added base artificial noise
        defaults.NoiseIncrement = [];       % Added heteroskedastic artificial noise
        defaults.NoiseEstimate = [];        % Estimated size of noise   
        defaults.AvgSamples = 200;          % Max # samples for estimating min fval of noisy functions
        defaults.CandidateX = 3;            % Maximum candidate best point per optimization iteration 
        defaults.TrueMinFval = NaN;
        defaults.LocalDataFile = [];        % Local data file to be moved to each local folder

    case {'plot'}
        defaults.BestOutOf = 1;
        defaults.NumZero = 1e-3;
        defaults.Method = 'FS';
        % defaults.Method = 'IR';
        defaults.SolveThreshold = 10.^(1:-0.1:-2);
%        defaults.VerticalThreshold = 500;
        defaults.Noisy = 0;
        defaults.UnknownMin = 0;
        defaults.DisplayFval = 1;
        defaults.FunEvalsPerD = 500;
        
    case {'plot_noisy'}
        defaults.BestOutOf = 1;
        defaults.NumZero = 1e-2;
        defaults.Method = 'FS';
        defaults.SolveThreshold = 10.^(1:-0.1:-1);
%        defaults.VerticalThreshold = 500;
        defaults.Noisy = 1;
        defaults.UnknownMin = 0;
        defaults.DisplayFval = 1;        
        defaults.FunEvalsPerD = 200;
        
    case 'style'
        name = varargin{1};
        sep = find(name == '_',1);
        name(1:sep) = [];
        sep = find(name == '_',1);
        algo = name(1:sep-1);
        algoset = name(sep+1:end);
        
        line_deterministic = '-';
        line_stochastic = '--';
        
        defaults.color = [0 0 0]/255;
        defaults.linewidth = 2;
        defaults.linestyle = line_deterministic;
        defaults.marker = '';
        
        switch algo            
            case 'bads'
                switch algoset
                    case {'base','x2','nearest'}; defaults.color = [0 100 140]/255; defaults.marker = '*'; defaults.linewidth = 2; defaults.linestyle = '-.';
                    case 'matern5'; defaults.color = [0 100 140]/255; defaults.marker = 'v'; defaults.linewidth = 2; defaults.linestyle = ':';
                    case 'sqexp'; defaults.color = [0 100 140]/255; defaults.marker = 'o'; defaults.linewidth = 2; defaults.linestyle = '-';
                    case 'acqlcb'; defaults.color = [0 0 0]/255; defaults.marker = ''; defaults.linewidth = 4; defaults.linestyle = '-.';
                    case 'lcbnearest'; defaults.color = [0 0 0]/255; defaults.marker = ''; defaults.linewidth = 4; defaults.linestyle = '-.';
                    case 'acqlcb_m5'; defaults.color = [0 0 0]/255; defaults.marker = '^'; defaults.linewidth = 2; defaults.linestyle = ':';
                    case 'acqpi'; defaults.color = [120 100 0]/255; defaults.marker = 's'; defaults.linewidth = 2; defaults.linestyle = '-.';
                    case 'acqpi_m5'; defaults.color = [120 100 0]/255; defaults.marker = '>'; defaults.linewidth = 2; defaults.linestyle = ':';
                    case {'acqlcb_overhead','lcbnearest_overhead'}; defaults.color = 150*[1 1 1]/255; defaults.marker = ''; defaults.linewidth = 4; defaults.linestyle = '-.';
                    case 'acqpi_se'; defaults.color = [120 100 0]/255; defaults.marker = '*'; defaults.linewidth = 2; defaults.linestyle = '-';
                    case 'acqlcb_se'; defaults.color = [0 0 0]/255; defaults.marker = 'd'; defaults.linewidth = 2; defaults.linestyle = '-';
                    case 'onesearch'; defaults.color = [180 0 80]/255; defaults.marker = 's'; defaults.linewidth = 2; defaults.linestyle = '-';
                    case 'searchwcm'; defaults.color = [180 0 80]/255; defaults.marker = 'o'; defaults.linewidth = 2; defaults.linestyle = '-.';
                    case 'searchell'; defaults.color = [180 0 80]/255; defaults.marker = '+'; defaults.linewidth = 2; defaults.linestyle = '-.';
                    case 'noscaling'; defaults.color = [180 0 80]/255; defaults.marker = '^'; defaults.linewidth = 2; defaults.linestyle = '-';
                end

            case 'fminsearch'
                defaults.color = [240 198 114]/255;
                defaults.linewidth = 2;
                defaults.linestyle = line_deterministic;
                defaults.marker = 'v';
                
            case 'fmincon'
                switch algoset
                    case {'base','ip'}; defaults.color = [251 128 114]/255; defaults.marker = 'o';
                    case 'sqp'; defaults.color = [114 128 251]/255; defaults.marker = 's';
                    case 'actset'; defaults.color = [128 251 114]/255; defaults.marker = 'd';
                end
                defaults.linewidth = 2;
                defaults.linestyle = line_deterministic;

            case 'patternsearch'
                defaults.color = [128 177 211]/255;
                defaults.linewidth = 2;
                defaults.linestyle = line_deterministic;
                defaults.marker = '+';
                
            case 'mcs'
                defaults.color = [253 180 98]/255;
                defaults.linewidth = 2;
                defaults.linestyle = line_deterministic;
                defaults.marker = 's';
                
            case 'snobfit'
                defaults.color = [183 120 38]/255;
                defaults.linewidth = 2;
                defaults.linestyle = line_deterministic;
                defaults.marker = '>';                

            case 'global'
                defaults.color = [60 220 200]/255;
                defaults.linewidth = 2;
                defaults.linestyle = '--';
                defaults.marker = 'x';

            case 'cmaes'
                switch algoset
                    case 'base'; defaults.color = [188 128 189]/255; defaults.marker = 'o';
                    case 'noisy'; defaults.color = [255 128 189]/255; defaults.marker = '*';
                    case 'active'; defaults.color = [188 223 166]/255; defaults.marker = 'h';
                    case 'actnoisy'; defaults.color = [188 223 166]/255; defaults.marker = 'h';
                end
                defaults.linewidth = 2;
                defaults.linestyle = ':';
                
            case 'particleswarm'
                defaults.color = [165 211 195]/255;
                defaults.linewidth = 2;
                defaults.linestyle = ':';
                defaults.marker = '^';
                
            case 'ga'
                defaults.color = [159 212 105]/255;
                defaults.linewidth = 2;
                defaults.linestyle = ':';
                defaults.marker = '*';

            case 'simulannealbnd'
                defaults.color = [252 205 229]/255;
                defaults.linewidth = 2;
                defaults.linestyle = ':';
                defaults.marker = 'd';                
                
            case 'randsearch'
                defaults.color = [150 150 150]/255;
                defaults.linewidth = 2;
                defaults.linestyle = ':';
                defaults.marker = '.';                
                
                
        end
        
end