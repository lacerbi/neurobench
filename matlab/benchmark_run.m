function [probstruct,history] = benchmark_run(probset,prob,subprob,noise,algo,idlist,options)
%BENCHMARK_RUN Run optimization benchmark.

% Luigi Acerbi 2017

clear functions;

if nargin < 7; options = []; end

% Convert string input back to numeric arrays
prob = inputstr2num(prob);
subprob = inputstr2num(subprob);
noise = inputstr2num(noise);
idlist = inputstr2num(idlist);

if ischar(options); options = eval(options); end

% Get default options
defopts = benchmark_defaults('options');

% Assign default values to OPTIONS struct
for f = fieldnames(defopts)'
    if ~isfield(options,f{:}) || isempty(options.(f{:}))
        options.(f{:}) = defopts.(f{:});
    end
end

charsep = options.CharFileSep;

% Root of the benchmark directory tree
if isempty(options.RootDirectory)
    options.RootDirectory = fileparts(mfilename('fullpath'));
end

% Matlab file path
if isempty(options.PathDirectory)
    options.PathDirectory = fileparts(mfilename('fullpath'));
end

% Add sub-directories to path
addpath(genpath(options.PathDirectory));
if ~isempty(options.ProblemDirectory)
    addpath(genpath(options.ProblemDirectory));    
end

% Optimization algorithm settings
setidx = find(algo == charsep,1);
if isempty(setidx)
    algoset = 'base';
else
    algoset = algo(setidx+1:end);    
    algo = algo(1:setidx-1);
end
options.Algorithm = algo;
options.AlgorithmSetup = algoset;

% Noise setting (lo-me-hi, or nothing)
if isempty(noise); noisestring = []; else noisestring = [charsep noise 'noise']; end

scratch_flag = false;
timeOffset = 0; % Computation time that does not count for benchmark

% Test processor speed (for baseline)
speedtest = [];
if options.SpeedTests > 0; speedtest.start = bench(options.SpeedTests); end

% Loop over optimization runs
for iRun = 1:length(idlist)
    clear benchmark_func;    % Clear persistent variables
    
    % Initialize random number generator to current id
    rng(idlist(iRun),'twister');

    % Initialize current problem
    probstruct = problem_init(probset,prob,subprob,noise,idlist(iRun),options);
    
    % Create working dir
    directoryname = [probstruct.ProbSet charsep probstruct.Prob];
    subdirectoryname = [probstruct.SubProb noisestring];
    mkdir([options.RootDirectory filesep directoryname]);
    mkdir([options.RootDirectory filesep directoryname filesep subdirectoryname]);
    
    % Copy local data file to working dir
    if isfield(probstruct,'LocalDataFile') && ~isempty(probstruct.LocalDataFile)
        targetfile = [options.RootDirectory filesep directoryname filesep subdirectoryname filesep probstruct.LocalDataFile];
        if ~exist(targetfile,'file')
            display(['Copying data file ' probstruct.LocalDataFile ' to local folder.']);
            copyfile([ '.' filesep probstruct.LocalDataFile],targetfile);
        else
            display(['Data file ' probstruct.LocalDataFile ' already exists in local folder.']);
        end
    end
    
    % Move to working dir
    cd([options.RootDirectory filesep directoryname filesep subdirectoryname]);    
    
    remainingFunEvals = probstruct.MaxFunEvals;
    probstruct.nIters = 0;
    FunCallsPerIter = 0;
    FirstPoint = [];    % First starting point of the run
    x = []; fval = []; fse = []; t = []; zscore = []; err = [];
    
    % Loop until out of budget of function evaluations
    while remainingFunEvals > 0
        probstruct.nIters = probstruct.nIters + 1;
        
        % Update iteration counter
        benchmark_func([],probstruct,1,probstruct.nIters,timeOffset);
    
        % Initial optimization point (used only by some algorithms)
        probstruct.InitPoint = [];
        if probstruct.StartFromMinX
            if any(isnan(probstruct.TrueMinX))
                warning('Cannot start from TrueMinX, vector contains NaNs. Setting a random starting point.');
            else
                probstruct.InitPoint = probstruct.TrueMinX;
            end
        end
        if isempty(probstruct.InitPoint)
            probstruct.InitPoint = rand(1,probstruct.D).*diff(probstruct.InitRange) + probstruct.InitRange(1,:);
        end
        if isempty(FirstPoint); FirstPoint = probstruct.InitPoint; end
        
        algofun = str2func(['algorithm_' algo]);
        [history{iRun},xnew,fvalnew,algoptions] = algofun(algo,algoset,probstruct);   % Run optimization
        
        % Measure z-score of returned estimate for artificial noisy functions
        if isfield(history{iRun},'scratch') && ...
                isfield(history{iRun}.scratch,'fval') && isfield(history{iRun}.scratch,'fsd') && ...
                ~isempty(probstruct.Noise) && ~probstruct.IntrinsicNoisy
            fval_true = benchmark_func(xnew,probstruct,1);
            errnew = (fval_true - fvalnew);
            err = [err; errnew];
            zscorenew = errnew / history{iRun}.scratch.fsd;
            zscore = [zscore; zscorenew];
        end
        
        % Remove duplicate points from basket of candidate points
        index = duplicates(xnew,options.TolX);
        xnew(index,:) = []; fvalnew(index) = [];        
        fsenew = zeros(size(fvalnew));  % SE of function value (will be computed later)
        tnew = ones(size(fvalnew))*history{iRun}.FunCalls;
        
        %xnew
        %[fvalnew,fsenew]
        
        % Add new points and their returned values
        x = [x; xnew];
        fval = [fval; fvalnew];
        fse = [fse; fsenew];
        t = [t; tnew];
                        
        remainingFunEvals = probstruct.TotalMaxFunEvals - history{iRun}.FunCalls;
        FunCallsPerIter(probstruct.nIters+1) = history{iRun}.FunCalls - sum(FunCallsPerIter(1:probstruct.nIters));
        
        % For intrinsically noisy functions, stop running at feval cutoff
        if remainingFunEvals > 0 && probstruct.IntrinsicNoisy
            probstruct.MaxFunEvals = remainingFunEvals;
        end
        
        % Minimum true value is known - stop iteration if reached
        if isfinite(probstruct.TrueMinFval) && ...
                (min(history{iRun}.MinScores) - probstruct.TrueMinFval) ...
                    < probstruct.TolFun && ...
                    options.StopSuccessfulRuns && ...
                    ~probstruct.IntrinsicNoisy
                remainingFunEvals = 0;                
        end
    end
    
    % Post-process returned points (remove extra points, evaluate noisy functions)
    [x,fval,fse,t,extraTime] = postprocesspoints(x,fval,fse,t,probstruct);
    timeOffset = timeOffset + extraTime;
    
    % Convert back to normal coordinates
    if isfield(probstruct,'trinfo')
        for i = 1:size(x,1); x(i,:) = transvars(x(i,:),'inv',probstruct.trinfo); end
        if all(isfinite(history{iRun}.TrueMinX))
            history{iRun}.TrueMinX = transvars(history{iRun}.TrueMinX,'inv',probstruct.trinfo);
        end
    end
    
    history{iRun}.X0 = FirstPoint;
    history{iRun}.FunCallsPerIter = FunCallsPerIter(2:end);
    history{iRun}.Algorithm = algo;
    history{iRun}.AlgoSetup = algoset;
    history{iRun}.Output.x = x;
    history{iRun}.Output.fval = fval;
    history{iRun}.Output.fsd = fse;    
    history{iRun}.Output.t = t;
    if ~isempty(err); history{iRun}.Output.err = err; end
    if ~isempty(zscore); history{iRun}.Output.zscore = zscore; end
    
    if isfield(history{iRun},'scratch'); scratch_flag = true; end
end

% Test processor speed (for baseline)
if options.SpeedTests > 0; speedtest.end = bench(options.SpeedTests); end

% Save optimization results
filename = [options.OutputDataPrefix algo charsep algoset charsep num2str(idlist(1)) '.mat'];
if scratch_flag  % Remove scratch field from saved files, keep it for output
    temp = history;
    for iRun = 1:numel(history)
        history{iRun} = rmfield(history{iRun},'scratch');
    end
    save(filename,'history','speedtest');
    history = temp;
    clear temp;
else
    save(filename,'history','speedtest');    
end

% Save algorithm options
filename = [options.OutputDataPrefix algo charsep algoset charsep 'opts.mat'];
if ~exist(filename,'file'); save(filename,'algoptions'); end

cd(options.RootDirectory); % Go back to root

%--------------------------------------------------------------------------
function s = inputstr2num(s)
%INPUTSTR2NUM Converts an input string into a numerical array (if needed).

if ischar(s)
    % Allowed chars in numerical array
    allowedchars = '0123456789.-[]() ,;:';
    isallowed = any(bsxfun(@eq, s, allowedchars'),1);
    if strcmp(s,'[]')
        s = [];
    elseif all(isallowed)
        t = str2num(s);
        if ~isempty(t) && isnumeric(t) && isvector(t); s = t; end
    end
end

%--------------------------------------------------------------------------
function [y, n] = stderr(varargin)
%STDERR Standard error of the mean, ignore NaN.

x = varargin{1};                        % Input data
if nargin < 3; dim = 1; else dim = varargin{3}; end
if size(x,1) == 1 && ismatrix(x); flip = 1; x = x'; else flip = 0; end
y = sqrt(nanvar(varargin{:}));
n = size(x, dim) - sum(isnan(x), dim);  % Effective data size
y = y./sqrt(n);
if flip; y = y'; end

%--------------------------------------------------------------------------
function index = duplicates(x,tol)
%DUPLICATES Return index of duplicate vectors
if size(x,1) > 1
    flag = zeros(size(x,1),1);    
    x2(1,:,:) = x';
    dist = sqrt(squeeze(sum(bsxfun(@minus,x,x2).^2,2)));
    for i = 1:size(x,1)
        for j = 1:i-1
            if dist(i,j) < tol; flag(i) = 1; end
        end
    end
    index = find(flag);
else
    index = [];
end
%--------------------------------------------------------------------------
function [x,fval,fse,t,timeOffset] = postprocesspoints(x,fval,fse,t,probstruct)
%POSTPROCESS Postprocess benchmark output.

% This time does not count for actual performance benchmark
tOffset = tic;

% Keep only first and a few other best candidate points
if size(x,1) > probstruct.CandidateX
    % temp = fvalnew(2:end);
    [~,index] = sort(fval(2:end),'ascend');
    x = [x(1,:); x(1+index(1:probstruct.CandidateX-1),:)];
    fval = [fval(1); fval(1+index(1:probstruct.CandidateX-1))];
    fse = [fse(1); fse(1+index(1:probstruct.CandidateX-1))];
    t = [t(1); t(1+index(1:probstruct.CandidateX-1))];    
end

% Get non-noisy or approximate function value for noisy functions
if ~isempty(probstruct.Noise) || probstruct.IntrinsicNoisy
    for iPoint = 1:size(x,1)
        x_end = x(iPoint,:);
        if ~probstruct.IntrinsicNoisy        % Only added noise
            fval(iPoint) = benchmark_func(x_end,probstruct,1);
        else                                % Noisy function
            temp = zeros(1,probstruct.AvgSamples);
            for iSample = 1:probstruct.AvgSamples
                temp(iSample) = benchmark_func(x_end,probstruct,1);
                % If SE of current samples is less than TolFun,
                % stop (collect at least ten samples)
                tempse = stderr(temp(1:iSample));
                if iSample >= 10 && tempse < probstruct.TolFun; break; end
            end
            fval(iPoint) = nanmean(temp(1:iSample));
            fse(iPoint) = stderr(temp(1:iSample));
        end
    end
end

timeOffset = toc(tOffset);
