function varargout = benchmark_func(x,probstruct,debug,iter,toffset)
%BENCHMARK_FUNC Wrapper for optimization benchmark objective function.

persistent history;     % Log history of function calls

if nargin < 1   % No arguments return history log
    historyOut = history;
    if ~isempty(historyOut)     % Remove temporary fields
        historyOut = rmfield(historyOut,'FuncHandle');
        historyOut = rmfield(historyOut,'FuncTimeTemp');
    end

    varargout = {historyOut};
    return;
end

if isstruct(x)  % Swapped variable order
    temp = probstruct;
    probstruct = x;
    x = temp;
end

if nargin < 3 || isempty(debug); debug = 0; end
if nargin < 4; iter = []; end
if nargin < 5 || isempty(toffset); toffset = 0; end

if exist('istable','file') == 2 && istable(x)
    xnew = zeros(size(x));
    for iVar = 1:numel(x)
        xnew(iVar) = x.(['x' num2str(iVar)]);
    end
    x = xnew;
end

% Update current run number
if debug && ~isempty(iter)
    if iter > 1
        history.CurrentIter = iter;
        history.StartIterFunCalls = history.FunCalls;
        history.TimeOffset = history.TimeOffset + toffset;
        if size(history.ThresholdsHitPerIter,1) < iter
            history.ThresholdsHitPerIter = [history.ThresholdsHitPerIter; ...
                Inf(1, numel(history.Thresholds))];        
        end
    end
    return;
end

x = x(:)';  % Row vector in

if isempty(history)     % First function call, initialize log
    
    % Problem information
    history.ProbSet = probstruct.ProbSet;
    history.Prob = probstruct.Prob;
    history.SubProb = probstruct.SubProb;
    history.Id = probstruct.Id;
    history.D = probstruct.D;
    history.Noise = probstruct.Noise;
    if isfield(probstruct,'NoiseSigma') && ~isempty(probstruct.NoiseSigma)
        history.NoiseSigma = probstruct.NoiseSigma;
    else
        history.NoiseSigma = 0;        
    end
    if isfield(probstruct,'NoiseIncrement') && ~isempty(probstruct.NoiseIncrement)
        history.NoiseIncrement = probstruct.NoiseIncrement;
    else
        history.NoiseIncrement = 0;        
    end
    history.Func = probstruct.func;
    history.FuncHandle = str2func(probstruct.func);     % Removed later
    history.TrueMinX = probstruct.TrueMinX;
    if isfield(probstruct,'TrueMinFval')
        history.TrueMinFval = probstruct.TrueMinFval;
    else
        history.TrueMinFval = [];
    end
    if isfield(probstruct,'TotalMaxFunEvals')
        history.TotalMaxFunEvals = probstruct.TotalMaxFunEvals;
    else
        history.TotalMaxFunEvals = [];        
    end
    
    % Optimization record
    if ~isfield(probstruct,'SaveTicks'); probstruct.SaveTicks = []; end
    nmax = numel(probstruct.SaveTicks);
    history.ElapsedTime = NaN(1,nmax);
    history.FuncTime = NaN(1,nmax);
    history.FuncTimeTemp = 0;   % Temporary variable to store function time
    history.MinScores = NaN(1,nmax);
    history.BestX = NaN(1,history.D);
    if isfield(probstruct,'Thresholds')
        history.Thresholds = probstruct.Thresholds;
        history.ThresholdsHit = Inf(1, numel(history.Thresholds));
        history.ThresholdsHitPerIter = Inf(1, numel(history.Thresholds));
    end
    history.MinScore = Inf;
    history.FunCalls = 0;
    history.StartIterFunCalls = 0;
    history.SaveTicks = probstruct.SaveTicks;
    if isfield(probstruct,'trinfo'); history.trinfo = probstruct.trinfo; end
    history.Clock = tic;
    history.TimeOffset = 0; % Time to be subtracted from clock    
    history.CurrentIter = 1;
end

% Check that x is within the hard bounds
isWithinBounds = (x >= probstruct.LowerBound) & (x <= probstruct.UpperBound);
if ~all(isWithinBounds); x = min(max(x,probstruct.LowerBound),probstruct.UpperBound); end

% Call function
if isfield(history,'FuncHandle')
    func = history.FuncHandle;
else
    func = str2func(history.Func);
end

if isfield(probstruct,'trinfo'); x = transvars(x,'inv',probstruct.trinfo); end

% Computational precision (minimum 0; 1 default precision)
if ~isfield(probstruct,'Precision') || isempty(probstruct.Precision)
    probstruct.Precision = 1;
end

% Changing precision
% probstruct.Precision = min(4/3*history.FunCalls/probstruct.TotalMaxFunEvals, 1);

% Check if need to pass probstruct
try
    if strfind(probstruct.func,'probstruct_')
        tfun = tic; fval = func(x,probstruct); t = toc(tfun);
    else
        tfun = tic; fval = func(x); t = toc(tfun);
    end
catch except
    warning(['Error in benchmark function ''' history.Func '''.' ...
        ' Message: ''' except.message '''']);
    x
    fval = NaN;
    t = 0;
    except.stack.file
    except.stack.line
end

% Add penalty for each constraint violation
if ~all(isWithinBounds); fval = fval + probstruct.ConstraintPenalty*sum(~isWithinBounds); end

% Value for NaN result
if (isnan(fval) || isinf(fval)) && ~isempty(probstruct.NonAdmissibleFuncValue) && ~isnan(probstruct.NonAdmissibleFuncValue)
    fval = probstruct.NonAdmissibleFuncValue;
end

if ~debug
    % Update records (not in debug mode)
    history.FunCalls = history.FunCalls + 1;
    history.FuncTimeTemp = history.FuncTimeTemp + t;
    if fval < history.MinScore
        history.MinScore = fval;
        history.BestX = x;
    end
    
    % Update history log every SavePeriod function calls
    idx = find(history.FunCalls == history.SaveTicks,1);
    if ~isempty(idx)
        history.FuncTime(idx) = history.FuncTimeTemp;
        history.FuncTimeTemp = 0;
        history.ElapsedTime(idx) = toc(history.Clock) - history.TimeOffset;
        history.MinScores(idx) = history.MinScore;
    end
        
    % Check thresholds (only if the true minimum is known)
    if ~isempty(history.TrueMinFval) && isfinite(history.TrueMinFval)
        delta = fval - history.TrueMinFval;
        idx = (delta < history.Thresholds) & ~isfinite(history.ThresholdsHit);
        history.ThresholdsHit(idx) = history.FunCalls;        
        iter = history.CurrentIter;
        idx = (delta < history.Thresholds) & ~isfinite(history.ThresholdsHitPerIter(iter,:));
        history.ThresholdsHitPerIter(iter,idx) = history.FunCalls - history.StartIterFunCalls;
    end

    % Add artificial noise (not in debug mode)
    if ~isempty(history.TrueMinFval)
        sigma = history.NoiseSigma + history.NoiseIncrement*max(fval - history.TrueMinFval,0);
    else
        sigma = history.NoiseSigma + history.NoiseIncrement*abs(fval);
    end    
    fval = fval + randn()*sigma;     
end

% x

varargout = {fval};    

end