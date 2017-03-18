function probstruct = problem_init(probset,prob,subprob,noise,id,options)
%PROBLEM_INIT Initialize problem structure.

% Initialize current problem
problemfun = str2func(['problem_' probset]);
probstruct = problemfun(prob,subprob,noise,id,options);

% Assign default values to problem struct
defprob = benchmark_defaults('problem',probstruct,options);
for f = fieldnames(defprob)'
    if ~isfield(probstruct,f{:}) || isempty(probstruct.(f{:}))
        probstruct.(f{:}) = defprob.(f{:});
    end
end

% Assign default values to OPTIONS struct (useful if called externally)
defopts = benchmark_defaults('options');
for f = fieldnames(defopts)'
    if ~isfield(options,f{:}) || isempty(options.(f{:}))
        options.(f{:}) = defopts.(f{:});
    end
end

% Simulated noise
if isempty(probstruct.NoiseSigma)
    if isempty(probstruct.Noise)
        probstruct.NoiseSigma = 0; % No noise
    else
        switch(probstruct.Noise)
            case 'lo'; probstruct.NoiseSigma = 0.1; % Low noise
            case 'me'; probstruct.NoiseSigma = 1; % Medium noise
            case 'hi'; probstruct.NoiseSigma = 10; % High noise
        end
        if isempty(probstruct.NoiseEstimate)
            probstruct.NoiseEstimate = [probstruct.NoiseSigma, 0.2];
        else
            probstruct.NoiseEstimate(1) = sqrt(probstruct.NoiseEstimate(1)^2 + probstruct.NoiseSigma^2);
        end
    end
end

% Maximum function evaluations
probstruct.MaxFunEvals = probstruct.MaxFunEvals*options.MaxFunEvalMultiplier;
probstruct.TotalMaxFunEvals = probstruct.MaxFunEvals;
probstruct.Verbose = evalbool(options.Display);

if isempty(probstruct.SaveTicks)
    probstruct.SaveTicks = [10:10:200, 250:50:2000, 2100:100:probstruct.TotalMaxFunEvals];
    probstruct.SaveTicks(probstruct.SaveTicks > probstruct.TotalMaxFunEvals) = [];
end

% Load minimum from file
filename = ['mindata_' probstruct.ProbSet '_' probstruct.Prob '.mat'];
try    
    temp = load(filename);
    f = temp.mindata.(['f_' probstruct.SubProb]);
    if ~isfield(probstruct,'TrueMinFval') || isempty(probstruct.TrueMinFval) || ~isfinite(probstruct.TrueMinFval)
        probstruct.TrueMinFval = f.MinFval;
    end
    if ~isfield(probstruct,'TrueMinX') || isempty(probstruct.TrueMinX) || any(~isfinite(probstruct.TrueMinX))
        probstruct.TrueMinX = f.BestX;
    end    
catch
    warning('Could not load optimum location/value from file.');
end

% Center and rescale variables
if evalbool(options.ScaleVariables)
    probstruct.trinfo = transvars(probstruct.D,probstruct.LowerBound,probstruct.UpperBound,probstruct.InitRange(1,:),probstruct.InitRange(2,:));
    probstruct.LowerBound = probstruct.trinfo.lb(:)';
    probstruct.UpperBound = probstruct.trinfo.ub(:)';
    probstruct.InitRange = [probstruct.trinfo.plb(:)'; probstruct.trinfo.pub(:)'];
    if all(isfinite(probstruct.TrueMinX))
        probstruct.TrueMinX = transvars(probstruct.TrueMinX,'dir',probstruct.trinfo);
    end
end

if isfield(probstruct,'TrueMinFval') && isfinite(probstruct.TrueMinFval)
    display(['Known minimum function value: ' num2str(probstruct.TrueMinFval,'%.3f')]);
end

% Compute initial optimization point
probstruct.InitPoint = [];
probstruct.StartFromMinX = options.StartFromMinX;
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

% Compute evaluation time and function noise
tic; f1 = benchmark_func(probstruct.InitPoint,probstruct,1); toc
tic; f2 = benchmark_func(probstruct.InitPoint,probstruct,1); toc
% [f1 f2]

% Assess whether function is intrinsically noisy
if ~isfield(probstruct,'IntrinsicNoisy') || isempty(probstruct.IntrinsicNoisy)
    if f1 ~= f2; probstruct.IntrinsicNoisy = 1; else probstruct.IntrinsicNoisy = 0; end
end

%--------------------------------------------------------------------------
function tf = evalbool(s)
%EVALBOOL Evaluate argument to a bool

if ~ischar(s) % S may not and cannot be empty
        tf = s;
        
else % Evaluation of string S
    if strncmpi(s, 'yes', 3) || strncmpi(s, 'on', 2) ...
        || strncmpi(s, 'true', 4) || strncmp(s, '1 ', 2)
            tf = 1;
    elseif strncmpi(s, 'no', 2) || strncmpi(s, 'off', 3) ...
        || strncmpi(s, 'false', 5) || strncmp(s, '0 ', 2)
            tf = 0;
    else
        try tf = evalin('caller', s); catch
            error(['String value "' s '" cannot be evaluated']);
        end
        try tf ~= 0; catch
            error(['String value "' s '" cannot be evaluated reasonably']);
        end
    end

end