function varargout = benchmark_wrapper(n,x,data)
%BENCHMARK_WRAPPER A black-box wrapper for the benchmark suite.
% 
%   The wrapper is called in two different ways:
%
%   [NVEC,LB,UB,PLB,PUB,XMIN,NOISE,DATA] = BENCHMARK_WRAPPER(N) takes a 
%   dataset or subproblem identifier N as input (a positive integer) 
%   and returns:
%     - a vector NVEC with the used dataset identifiers (a vector of
%       positive integers; e.g., 1:8 for subjects from 1 to 12);
%     - lower/upper bounds LB and UB for the problem variables; 
%     - plausible lower/upper bounds PLB and PUB (you can set PLB=LB and 
%       PUB=UB if plausible variable ranges are unknown);
%     - the location of the true minimum XMIN (if known, otherwise return
%       a vector of NaN's);
%     - an estimate NOISE of the noise in the returned values of the 
%       objective function (NOISE=0 if the objective function is deterministic).
%     - an auxiliary data structure DATA (possibly loaded from file);
%   LB, UB, PLB, PUB and XMIN are assumed to be row vectors of length NVARS, 
%   where NVARS is the number of variables. NOISE is a scalar. DATA can be 
%   an empty matrix if no auxiliary data are necessary.
%
%   FVAL = BENCHMARK_WRAPPER(N,X,DATA) takes as input a dataset identifier 
%   N, a variable vector X and a dataset structure DATA (as previously 
%   returned) and returns the value of the objective function evaluated at X.
%   For many problems, the objective function is the negative log likelihood
%   or the squared error.
%
%
%   Author:     Luigi Acerbi
%   Email:      luigi.acerbi@gmail.com
%   Version:    Jan/28/2016

if nargin == 1
    %% Initialization call -- define problem and set up data
    
    % Define problem parameters (example)
    nvars = 5;                  % Number of variables
    nvec = 1:12;                % List of dataset identifiers (e.g., 12 subjects)
    lb = zeros(1,nvars);        % Lower bounds (hard)
    ub = ones(1,nvars);         % Upper bounds (hard)
    plb = 0.1*ones(1,nvars);    % Plausible lower bounds
    pub = 0.9*ones(1,nvars);    % Plausible upper bounds
    xmin = NaN(1,nvars);        % True optimum (if known, NaNs otherwise)
    noise = 0;                  % Estimate of the noise (0 if deterministic)
    
    try
        
        % Load data structure from file for a given dataset (example)
        filename = 'example-datasets-all.mat';    
        temp = load(filename);
        data =  temp.data{n};                   % Loading N-th dataset

        % Alternative loading example with a separate file per dataset
        % filename = ['example-dataset-' num2str(n) '.mat'];    
        % data = load(filename);
        
    catch
        
        % This part handles failure in data loading -- do not modify
        warning(['Could not load dataset with identifier #' num2str(n) '.']);
        data = NaN;     % If DATA is NaN an error occurred
        
    end
    
    varargout = {nvec,lb,ub,plb,pub,xmin,noise,data};
    
else
    %% Iteration call -- evaluate objective function
    
    % Call the objective function, pass loaded DATA
    fval = objectivefunction(x,data);
    
    varargout = {fval};
    
end

end