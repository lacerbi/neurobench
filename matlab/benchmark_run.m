function [probstruct,history] = benchmark_run(probset,prob,subprob,noise,algo,idlist,options)
%BENCHMARK_RUN

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
for subd = {'algorithms','problems','utils'}
    addpath([options.PathDirectory filesep() subd{:}]);
end
problemsd = dir([options.PathDirectory filesep() 'problems' filesep() '*'])';
for subd = problemsd
    if subd.isdir && ~strcmp(subd.name,'.') && ~strcmp(subd.name,'..')
        addpath([options.PathDirectory filesep() 'problems' filesep subd.name]);
    end
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

scratch = 0;

% Loop over optimization runs
for iRun = 1:length(idlist)
    clear benchmark_func;    % Clear persistent variables
    
    % Initialize random number generator to current id
    rng(idlist(iRun),'twister');

    % Initialize current problem
    probstruct = problem_init(probset,prob,subprob,noise,idlist(iRun),options);
    
    % Move to working dir
    directoryname = [probstruct.ProbSet charsep probstruct.Prob];
    subdirectoryname = [probstruct.SubProb noisestring];
    mkdir([options.RootDirectory filesep directoryname]);
    mkdir([options.RootDirectory filesep directoryname filesep subdirectoryname]);
    cd([options.RootDirectory filesep directoryname filesep subdirectoryname]);
    
    remainingFunEvals = probstruct.MaxFunEvals;
    probstruct.nIters = 0;
    FunCallsPerIter = 0;
    x = []; fval = []; fse = []; t = [];
    
    % Loop until out of budget of function evaluations
    while remainingFunEvals > 0
        probstruct.nIters = probstruct.nIters + 1;
        
        % Update iteration counter
        benchmark_func([],probstruct,1,probstruct.nIters);
    
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
        
        algofun = str2func(['algorithm_' algo]);
        [history{iRun},xnew,fvalnew,algoptions] = algofun(algo,algoset,probstruct);   % Run optimization
        
        % Remove duplicate points from basket of candidate points
        index = duplicates(xnew,options.TolX);
        xnew(index,:) = []; fvalnew(index) = [];
        
        % Keep only first and a few other best candidate points
        if size(xnew,1) > probstruct.CandidateX
            % temp = fvalnew(2:end);
            [~,index] = sort(fvalnew(2:end),'ascend');
            xnew = [xnew(1,:);xnew(1+index(1:probstruct.CandidateX-1),:)];
            fvalnew = [fvalnew(1);fvalnew(1+index(1:probstruct.CandidateX-1))];
        end
        fsenew = zeros(size(fvalnew));  % SE of function value
        tnew = ones(size(fvalnew))*history{iRun}.FunCalls;
        
        % Get non-noisy or approximate function value for noisy functions
        if ~isempty(probstruct.Noise) || probstruct.IntrinsicNoisy
            for iPoint = 1:size(xnew,1)
                if ~probstruct.IntrinsicNoisy        % Only added noise
                    fvalnew(iPoint) = benchmark_func(xnew(iPoint,:),probstruct,1);
                else                                % Noisy function
                    temp = zeros(1,probstruct.AvgSamples);
                    temp(1) = fvalnew(iPoint);
                    for iSample = 2:probstruct.AvgSamples
                        temp(iSample) = benchmark_func(xnew(iPoint,:),probstruct,1);
                        % If SE of current samples is less than TolFun,
                        % stop (collect at least four samples)
                        tempse = stderr(temp(1:iSample));
                        if iSample >= 4 && tempse < probstruct.TolFun; break; end
                    end
                    fvalnew(iPoint) = nanmean(temp(1:iSample));
                    fsenew(iPoint) = stderr(temp(1:iSample));
                end
            end            
        end
        
        %xnew
        %[fvalnew,fsenew]
        
        % Add new points and their values
        x = [x; xnew];
        fval = [fval; fvalnew];
        fse = [fse; fsenew];
        t = [t; tnew];
                        
        remainingFunEvals = probstruct.TotalMaxFunEvals - history{iRun}.FunCalls;
        FunCallsPerIter(probstruct.nIters+1) = history{iRun}.FunCalls - sum(FunCallsPerIter(1:probstruct.nIters));
        % if remainingFunEvals > 0; probstruct.MaxFunEvals = remainingFunEvals; end
        
        % Minimum true value is known - stop iteration if reached
        if isfinite(probstruct.TrueMinFval) && ...
                (min(history{iRun}.MinScores) - probstruct.TrueMinFval) ...
                    < probstruct.TolFun && ...
                    options.StopSuccessfulRuns
                remainingFunEvals = 0;                
        end
    end
    
    % Convert back to normal coordinates
    if isfield(probstruct,'trinfo')
        for i = 1:size(x,1); x(i,:) = transvars(x(i,:),'inv',probstruct.trinfo); end
        if all(isfinite(history{iRun}.TrueMinX))
            history{iRun}.TrueMinX = transvars(history{iRun}.TrueMinX,'inv',probstruct.trinfo);
        end
    end
    
    history{iRun}.FunCallsPerIter = FunCallsPerIter(2:end);
    history{iRun}.Algorithm = algo;
    history{iRun}.AlgoSetup = algoset;
    history{iRun}.Output.x = x;
    history{iRun}.Output.fval = fval;
    history{iRun}.Output.fsd = fse;    
    history{iRun}.Output.t = t;
    
    if isfield(history{iRun},'scratch'); scratch = 1; end
end

% Save optimization results
filename = [options.OutputDataPrefix algo charsep algoset charsep num2str(idlist(1)) '.mat'];
if scratch  % Remove scratch field from saved files, keep it for output
    temp = history;
    for iRun = 1:numel(history)
        history{iRun} = rmfield(history{iRun},'scratch');
    end
    save(filename,'history');
    history = temp;
    clear temp;
else
    save(filename,'history');    
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
