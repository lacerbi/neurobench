function mindata = benchmark_minsearch(probset,prob,subprob,noise,TolFun)
%BENCHMARK_MINSEARCH Search global minimum across all optimizations.
%
%   BENCHMARK_PLOT(PROBSET,PROB,SUBPROB,NOISE) 
%   factorially plots optimization benchmark results for the following 
%   factors: problem set PROBSET, problem(s) PROB, subproblem(s) SUBPROB, 
%   noise level NOISE. 
%   PROBSET, PROB, SUBPROB, NOISE can be strings or cell 
%   arrays of strings.
%
%   See also BENCHMARK_RUN.

mindata = [];
if nargin < 3; subprob = []; end
if nargin < 4; noise = []; end
if nargin < 5 || isempty(TolFun); TolFun = 1e-4; end

if ~iscell(probset); probset = {probset}; end
if ~iscell(prob); prob = {prob}; end
if ~iscell(subprob); subprob = {subprob}; end
if ~iscell(noise); noise = {noise}; end

if numel(probset) > 1 || numel(prob) > 1
    error('BENCHMARK_MINSEARCH supports only one problem set and problem at a time.');
end

% Sub-problems not specified, list all in subdirectory
if isempty(subprob{1})
    def = benchmark_defaults('options');
    charsep = def.CharFileSep;
    subdir = [probset{1} charsep prob{1}];
    list = dir(subdir);
    subprob = [];
    for i = 1:numel(list)
        ll = list(i);        
        if ll.isdir && ~strcmpi(ll.name(1),'.'); subprob{end+1} = ll.name; end
    end
end

benchlist{1} = probset{1};
benchlist{2} = prob{1};
benchlist{4} = noise{1};
benchlist{5} = [];

filename = ['mindata_' probset{1} '_' prob{1} '.mat'];

% Check previous stored file
try
    olddata = load(filename);
    display('Loaded previous data.');
catch
    olddata = [];
    display('Could not load previous data.');
end

for iSubprob = 1:numel(subprob)
    benchlist{3} = subprob{iSubprob};

    % Collect history structs from data files
    display([benchlist{1} '@' benchlist{2} '@' benchlist{3}]);
    history = collectHistoryFiles(benchlist);
    if isempty(history); continue; end

    % Loop over histories
    MinScores = Inf(numel(history),1);
    BestX = NaN(numel(history),size(history{1}.BestX,2));
    for i = 1:numel(history)
        MinScores(i) = history{i}.MinScore;
        BestX(i,:) = history{i}.BestX;
    end
    [MinScore,idx] = min(MinScores);
    BestX = BestX(idx,:);

    % Save summary statistics
    if isempty(benchlist{4}); noise = [];
    else noise = ['_' benchlist{4} 'noise']; end                
    field1 = ['f_' upper(benchlist{3}) noise];
    
    try
        oldScore = olddata.mindata.(field1).MinFval;
        if MinScore < oldScore - TolFun
            display(['Found lower function value for ' upper(benchlist{3}) '! ' ...
                num2str(MinScore,'%.4f') ' < ' num2str(oldScore,'%.4f')]);
        end
        if MinScore > oldScore
            if MinScore > oldScore + TolFun
                display(['Stored function value for ' upper(benchlist{3}) ' was lower. ' ...
                    num2str(MinScore,'%.4f') ' > ' num2str(oldScore,'%.4f')]);
            end
            MinScore = oldScore;
            BestX = olddata.mindata.(field1).BestX;
        end
        
    catch
        warning(['Could not compare function values for ' upper(benchlist{3}) '.']);
    end
    
    mindata.(field1).MinFval = MinScore;
    mindata.(field1).BestX = BestX;
        
end

save(filename,'mindata');