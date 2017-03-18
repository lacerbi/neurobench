function probstruct = problem_ccn17(prob,subprob,noise,id,options)

% Problem names (ordered)
problist{1}  = 'visvest_joint';
problist{10} = 'aspen_wrm';
problist{20} = 'xuan';
problist{30} = 'robbe';
problist{40} = 'bas_sampling';
problist{51} = 'bas_vstm_bas';
problist{52} = 'bas_vstm_notbas1';
problist{53} = 'bas_vstm_notbas2';
problist{54} = 'bas_psycho_bas';
problist{55} = 'bas_psycho_notbas1';
problist{56} = 'bas_psycho_notbas2';
problist{60} = 'weiji_er';
problist{70} = 'jing_temporalsummation';

% Initialize problem structure
if ischar(subprob); S = extractnum(subprob); else S = subprob; end

probstruct = initprob(prob,problist,'ccn15',['S' num2str(S)],id);
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
        
    case 2
        temp = load('trevor-bimodal.mat');
        mfit = temp.mfit_bayesavg{S};
        mfit.prefix = 'CueBMS';
        probstruct.mfit = mfit;
        probstruct.Family = 'trevor';

    case 3
        temp = load('trevor-bimodal.mat');
        mfit = temp.mfit_full_bayesavg{S};
        mfit.prefix = 'CueBMS';
        probstruct.mfit = mfit;
        probstruct.Family = 'trevor';
        
    case 11
        % nAspen = probstruct.Number - 10;
        probstruct.Family = 'aspen';
        mypath = fileparts(mfilename('fullpath'));
        addpath([mypath,filesep,'CCN15',filesep,'aspen-wrm']);
        % temp = load('aspen-wrm-11-Aug-2015.mat');
        %probstruct.data = temp.data{nAspen}{S};
        % probstruct.TrueMinX = temp.truetheta{nAspen}(S,:); % Minimum must be near here
        
    case 20 % Xuan's social psychology (face gender) experiment        
        probstruct.Family = 'xuan';
        mypath = fileparts(mfilename('fullpath'));
        addpath([mypath,filesep,'CCN15',filesep,'xuan']);
        
    case 30 % Robbe's neural LN-LN model
        probstruct.Family = 'robbe';
        mypath = fileparts(mfilename('fullpath'));
        addpath([mypath,filesep,'CCN15',filesep,'robbe']);

    case 40 % Bas's VSTM sampling model
        probstruct.Family = 'bas_sampling';
        mypath = fileparts(mfilename('fullpath'));
        addpath([mypath,filesep,'CCN15',filesep,'bas-sampling']);

    case {51,52,53,54,55,56} % Bas's inverse sampling project
        probstruct.Family = 'bas_inversesampling';
        mypath = fileparts(mfilename('fullpath'));
        addpath([mypath,filesep,'CCN15',filesep,'bas-inversesampling']);
        
    case 60 % Weiji's ER
        probstruct.Family = 'weiji_er';
        mypath = fileparts(mfilename('fullpath'));
        addpath([mypath,filesep,'CCN15',filesep,'weiji-er']);        

    case 70 % Jing's temporal summation model
        probstruct.Family = 'jing_temporalsummation';
        mypath = fileparts(mfilename('fullpath'));
        addpath([mypath,filesep,'CCN15',filesep,'jing-temporalsummation']);        

end


switch probstruct.Family
    case 'visvest'
        probstruct.InitRange = [mfit.mp.bounds.RLB(:)'; mfit.mp.bounds.RUB(:)'];
        probstruct.func = ['@(x_,probstruct_) visvest_nLL(x_, probstruct_)'];
        probstruct.Precision = 1; % Standard precision

        probstruct.LowerBound = mfit.mp.bounds.LB(:)';
        probstruct.UpperBound = mfit.mp.bounds.UB(:)';
        probstruct.NoiseEstimate = 0;   % Not a noisy problem
        
    case 'aspen'
        %clear -global memDistsNew memDistsOld centers nGridsVec;
        %global memDistsNew memDistsOld centers nGridsVec;
        %memDistsNew = []; memDistsOld = []; centers = []; nGridsVec = [];
        
        probstruct = loadprob(probstruct,'aspen_wrm_wrapper',S);
        probstruct.MaxFunEvals = 100*length(probstruct.LowerBound);        

    case 'xuan' % Xuan's social psychology (face gender) experiment
        probstruct = loadprob(probstruct,'xuan_wrapper',S);        

    case 'robbe' % Robbe's neural LN-LN model
        probstruct = loadprob(probstruct,'robbe_wrapper',S);
        % probstruct.IntrinsicNoisy = 1;      % Noisy problem
        
    case 'bas_sampling'
        nBas = mod(S,100);
        probstruct = loadprob(probstruct,'bas_sampling_wrapper',nBas);
        probstruct.MaxFunEvals = 200;
        probstruct.AvgSamples = 200;
        
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
        
    case 'weiji_er'
        probstruct = loadprob(probstruct,'benchmark_wrapper_weiji_er',S);
        probstruct.MaxFunEvals = 800;
        probstruct.AvgSamples = 200;    % Samples at the end of run
        
    case 'jing_temporalsummation'
        probstruct = loadprob(probstruct,'benchmark_wrapper_jing',S);
        probstruct.MaxFunEvals = 4000;
        
end

% Update lower/upper bounds for periodic variables for non-BPS algorithms
if isfield(probstruct,'PeriodicVars') && ~isempty(probstruct.PeriodicVars) ...
        && ~strcmpi(options.Algorithm, 'bps') 
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





