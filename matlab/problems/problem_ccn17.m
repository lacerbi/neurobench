function probstruct = problem_ccn17(prob,subprob,noise,id,options)

% Problem names (ordered)
problist{1}  = 'visvest_joint';
problist{10} = 'vandenberg2016';
problist{20} = 'adler2016';
problist{30} = 'goris2014';
problist{40} = 'vanopheusden2016';
problist{50} = 'targetloc';

% Initialize problem structure
if ischar(subprob); S = extractnum(subprob); else S = subprob; end

probstruct = initprob(prob,problist,'ccn17',['S' num2str(S)],id);
probstruct.Title = probstruct.Prob;

% Setup problem
switch probstruct.Number
    case 1
        % Models: 1-11 Fixed, 12-22 Bayesian
        temp = load('visvest-joint-mfits.mat');
        nSubjs = numel(temp.joint_bay);                
        nid = mod(S-1,nSubjs) + 1;
        modelnum = floor((S-1)/nSubjs) + 1;
        switch modelnum
            case 1; mfit = temp.joint_fix{nid};
            case 2; mfit = temp.joint_bay{nid};
        end
        mfit.project = 'VestBMS';
        probstruct.mfit = mfit;
        probstruct.Family = 'visvest';
                
    case 10 % van den Berg (2017) working memory model with confidence
        probstruct.Family = 'vandenberg2016';   % Year is off by one
        mypath = fileparts(mfilename('fullpath'));
        addpath([mypath,filesep,'CCN17',filesep,'vandenberg2016']);

    case 20 % Adler and Ma (2016) perceptual confidence Bayesian model
        probstruct.Family = 'adler2016';        % Year is off by one
        mypath = fileparts(mfilename('fullpath'));
        addpath([mypath,filesep,'CCN17',filesep,'adler2016']);

    case 30 % Goris et al. (2015) neural LN-LN model (tuning diversity)
        probstruct.Family = 'goris2014';        % Year is off by one
        mypath = fileparts(mfilename('fullpath'));
        addpath([mypath,filesep,'CCN17',filesep,'goris2014']);

    case 40 % van Opheusden et al. (2016) Gomoku model
        probstruct.Family = 'vanopheusden2016';
        mypath = fileparts(mfilename('fullpath'));
        addpath([mypath,filesep,'CCN17',filesep,'vanopheusden2016']);
        
    case 50 % Mihali et al. (in preparation) target localization
        probstruct.Family = 'targetloc';
        mypath = fileparts(mfilename('fullpath'));
        addpath([mypath,filesep,'CCN17',filesep,'targetloc']);
        

end


switch probstruct.Family
    case 'visvest'
        probstruct.InitRange = [mfit.mp.bounds.RLB(:)'; mfit.mp.bounds.RUB(:)'];
        probstruct.func = ['@(x_,probstruct_) visvest_nLL(x_, probstruct_)'];
        probstruct.Precision = 1; % Standard precision

        probstruct.LowerBound = mfit.mp.bounds.LB(:)';
        probstruct.UpperBound = mfit.mp.bounds.UB(:)';
        probstruct.NoiseEstimate = 0;   % Not a noisy problem
        
    case 'vandenberg2016'
        probstruct = loadprob(probstruct,'vandenberg2016_wrapper',S);
        probstruct.MaxFunEvals = 200*length(probstruct.LowerBound);
        probstruct.IntrinsicNoisy = 1;  % Noisy problem        
        probstruct.AvgSamples = 200;    % Samples at the end of run

    case 'adler2016' % Will T. Adler Bayesian confidence model
        probstruct = loadprob(probstruct,'confidence_wrapper',S);

    case 'goris2014' % Robbe Goris's neural LN-LN model
        probstruct = loadprob(probstruct,'goris2014_wrapper',S);
        
    case 'vanopheusden2016' % van Opheusden's Gomoku MCTS model
        probstruct = loadprob(probstruct,'gomoku_wrapper',S);
        probstruct.MaxFunEvals = 2000;  % Limit fun evals
        probstruct.IntrinsicNoisy = 1;  % Noisy problem
        probstruct.AvgSamples = 200;    % Samples at the end of run
        probstruct.CandidateX = 10;     % Number of candidate points
        probstruct.LocalDataFile = 'times.txt';

    case 'targetloc'    % Mihali et al. (in preparation) target localization
        probstruct = loadprob(probstruct,'targetloc_wrapper',S);
        probstruct.MaxFunEvals = 200*length(probstruct.LowerBound);
        probstruct.IntrinsicNoisy = 1;  % Noisy problem        
        probstruct.AvgSamples = 200;    % Samples at the end of run
        
    case 'bas_inversesampling'
        switch (probstruct.Number-50)
            case 1; func = 'benchmark_wrapper_vstm_bas';
            case 2; func = 'benchmark_wrapper_vstm_notbas1';
            case 3; func = 'benchmark_wrapper_vstm_notbas2';
            case 4; func = 'benchmark_wrapper_psycho_bas';
            case 5; func = 'benchmark_wrapper_psycho_notbas1';
            case 6; func = 'benchmark_wrapper_psycho_notbas2';
        end        
        nBas = mod(S,120);
        probstruct = loadprob(probstruct,func,nBas);
        probstruct.MaxFunEvals = 200;
        probstruct.AvgSamples = 200;    % Samples at the end of run
        
        
end

% Update lower/upper bounds for periodic variables for non-BPS algorithms
if isfield(probstruct,'PeriodicVars') && ~isempty(probstruct.PeriodicVars) ...
        && ~any(strcmpi(options.Algorithm, {'bps','bads'})) 
    %probstruct.LowerBound(probstruct.PeriodicVars) = probstruct.LowerBound(probstruct.PeriodicVars)*20;
    %probstruct.UpperBound(probstruct.PeriodicVars) = probstruct.UpperBound(probstruct.PeriodicVars)*20;
    probstruct.LowerBound(probstruct.PeriodicVars) = -Inf;
    probstruct.UpperBound(probstruct.PeriodicVars) = Inf;
    display('Lower/upper bounds have been extended for periodic variables.');
end

probstruct.D = length(probstruct.LowerBound);
probstruct.Noise = noise;

if ~isfield(probstruct,'TrueMinX') || isempty(probstruct.TrueMinX)
    probstruct.TrueMinX = NaN(1,probstruct.D);
end

%--------------------------------------------------------------------------
function probstruct = initprob(prob,problist,ProbSet,SubProb,id)
%INITPROB Initialize problem structure.

if isnumeric(prob); prob = problist{prob}; end
probstruct.ProbSet = ProbSet;
probstruct.Number = find(strcmp(problist,prob),1);
probstruct.Prob = prob;
probstruct.SubProb = SubProb;
probstruct.Id = id;

%--------------------------------------------------------------------------
function probstruct = loadprob(probstruct,wrapperfunc,nid)

% Call wrapper function
func = str2func(wrapperfunc);
[nvec,lb,ub,plb,pub,xmin,noise,data] = func(nid);

if iscell(lb)
    probstruct.PeriodicVars = lb{2};
    lb = lb{1};
end
        
% Assign problem-specific information
probstruct.LowerBound = lb(:)';
probstruct.UpperBound = ub(:)';
probstruct.InitRange = [plb(:)'; pub(:)'];
probstruct.TrueMinX = xmin(:)';
probstruct.data = data;

if ~isfinite(noise); noise = []; end
probstruct.NoiseEstimate = noise;
probstruct.func = ['@(x_,probstruct_) ' wrapperfunc '(' num2str(nid) ',x_,probstruct_.data)'];





