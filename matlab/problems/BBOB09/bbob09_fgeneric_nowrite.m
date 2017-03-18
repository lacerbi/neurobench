function [Fvalue,probstruct] = bbob09_fgeneric_nowrite(x, FUNC_ID, itrial, probstruct, PARAMS)
% FGENERIC is a wrapper function used for the benchmark test functions.
%    Besides calling a benchmark function it does the housekeeping
%    and writing of data.
%
%    FLG = FGENERIC('EXIST', FUNC_ID)
%    returns 1 (meaning yes) or 0 depending whether the given FUNC_ID
%    number is part of the testbed.
%
%    FTARGET = FGENERIC('initialize', FUNC_ID, INSTANCE_ID, DATAPATH[, PARAMS])
%    Initialization for an optimization run on function FUNC_ID.
%    This call must be done before each run. 
%    PARAMS.inputFormat decides whether the decision variable vector in the 
%      following calls is a column (default) or row vector.
%    FUNC_ID is an integer setting the fitness function to be evaluated.
%    INSTANCE_ID is the instance of the fitness function. Optimal and
%      target function value and the applied rotation(s) are different
%      for each INSTANCE_ID.
%    DATAPATH is a string for the location of generated output data.
%    PARAMS is expected to be a structure with fields algName, comments,
%      filePrefix, inputFormat.
%    FUNC_ID, the problem dimension, PARAMS.algName, PARAMS.comments (if they
%      exist) are used to differentiate between different set-ups of runs.
%      * PARAMS.algName is a string for the name of the optimiser (used in
%        the post-processing).
%        If not specified, PARAMS.algName = 'not-specified';
%      * PARAMS.comments is a string that must not contain
%        end-of-line characters that will appear as comment in the index
%        file (preceded by '% ') and should be used to precise some
%        differentiating parameters of the optimiser.
%        If not specified, PARAMS.comments = '';
%      * PARAMS.filePrefix is a string for the prefix of the index and data
%        files names.
%        If not specified, PARAMS.filePrefix = 'bbobexp';
%        If DATAPATH and PARAMS.filePrefix are altogether set to previously
%        used values, FGENERIC should deal correctly with the additional data.
%        This is not true if two processes write in the same DATAPATH using
%        the same PARAMS.filePrefix at the same time.
%      * PARAMS.inputFormat is a string for specifying whether the decision
%        variable vector is rows or columns. It can take two values
%        either 'row' or 'col' (default).
%    FTARGET is the target function value of the specified fitness
%      function.
%    FGENERIC writes an index file, and records data in a data file.
%    For the format and folder/file structure of the output files see the
%    technical documentation.
%
%    F = FGENERIC(X) returns the fitness value of X, where
%    X is either the decision variable vector or an array of
%    such vectors. F will be respectively a scalar or a vector of the
%    fitness values of the individuals in X. The search interval for
%    X is [-5,5] in each component, while FGENERIC(X) will return a
%    reasonable value for any real-valued X. When fgeneric is called
%    the first time, an index entry is written. Occasionally data are
%    written in the data files.
%
%    LASTEVAL = FGENERIC('evaluations') returns the number of function
%    evaluations since FGENERIC('initialize', ...) was called.
%
%    FBEST = FGENERIC('fbest') returns the best function value obtained.
%    FBEST = FGENERIC('best') returns the best function value obtained.
%
%    FTARGET = FGENERIC('ftarget') returns the target function value.
%
%    FBEST = FGENERIC('finalize') should be called to indicate the end
%    of a single run.  It writes data of the best-ever fitness value
%    and of the final function evaluation. It closes the data files.
%    FBEST is the best true fitness value ever obtained.
%
%    Dependencies: benchmarks.m, benchmarksnoisy.m 
%
%    Example: Optimize function f11 with MATLABS FMINUNC:
%
%       DIM = 5;
%       ftarget = fgeneric('initialize', 11, 1, 'testfminunc');
%       opt = optimset('TolFun', 1e-11);
%       X = fminunc('fgeneric', 8*rand(DIM,1) - 4, opt);
%       disp(fgeneric(X) - ftarget);
%       fgeneric('finalize');
%
%    This will create folder testfminunc. In this folder, the info file
%    bbobexp_f11.info will provide meta-information on the different
%    optimization runs obtained. Data of these runs are located in folder
%    testfminunc/data_f11 which will contain the file bbobexp_f11_DIM5.dat.
%

%    Author: Raymond Ros, Nikolaus Hansen, Steffen Finck
%        (firstName.lastName@lri.fr)
%    Version = 'Revision: $Revision: 1540 $'
%    Last Modified: $Date: 2009-07-17 12:15:01 +0200 (Fri, 17 Jul 2009) $
%

%    Questions, comments:
%

%    TODO:
%    * Adds some status output to function without any output arg.
%    * Shorten the initialization process
%    * formatting of the code
%

%    Change log:
%    * Removed PARAMS.indexFilePrefix is not needed.
%    * Changed behaviour: changed findNextDataFile to setNextDataFile to have
%    all treatment on the data files in one location.
%    * Changed behaviour: changed order of input arguments
%    * itrial is now an attributes of PARAMS else there could be a bug at line
%    385: fgeneric('initialize', CurrentPARAMS.indexFilePrefix, ...
%                  CurrentPARAMS.funcId, CurrentPARAMS.itrial, CurrentPARAMS);
%    * it now is runCounter (back) that is written in the indexFile.
%    * PARAMS.filePrefix can be set by the user
%    * an input argument is now dataPath.
%    * itrial is now written in the index file instead of the run counter.
%    * %u (obsolescent) replaced by %d (sorry you were right Steffen).

  persistent handlesF DefaultPARAMS;
  persistent PreviousPARAMS CurrentPARAMS isParamsMatching;
  persistent actFunc Fopt isRowFormat LastEval BestFEval lastWriteEval;
  persistent nbPtsEvals nbPtsF;
  persistent fTrigger idxFTrigger evalsTrigger idxEvalsTrigger;
  persistent idxDIMEvalsTrigger;
  persistent maxFunEvalsFactor;  % times DIM = maxfunevals

  DeltaFtarget = 1e-8;  % target function value is Fopt + DeltaFtarget
  
  if isempty(DefaultPARAMS)
  % Loads defaultPARAMS into memory once instead of doing it every time
  % fgeneric('init' is called).
    DefaultPARAMS = struct('algName', 'not-specified', 'comments', '', ...
                          'inputFormat', 'col', 'filePrefix', 'bbobexp');
    maxFunEvalsFactor = 1e6;
  end
  if isempty(handlesF)
    handlesF = bbob09_benchmarks('handles');
    if exist('bbob09_benchmarksnoisy', 'file')
      h2 = bbob09_benchmarksnoisy('handles');
      handlesF(100+(1:length(h2))) = h2;  % index and function ID must agree
    end
  end
  if isempty(nbPtsEvals) || isempty(nbPtsF)
    nbPtsEvals = 20;
    nbPtsF = 5;
  end

  if nargin < 1
    help('fgeneric');
    return;
  end
  %------------------------------------------------------------------------
  if ischar(x)
    % test whether function exists
    if strcmpi(x, 'exist')
      if length(handlesF) < FUNC_ID || isempty(handlesF{FUNC_ID})
        Fvalue = 0;
      else
        Fvalue = 1;
      end
      return;

    % init and exit cases
    elseif strcmpi(x, 'initialize')
      if nargin < 4
        error('%s','Not enough arguments');
      end
      if ~isempty(actFunc) && isfield(CurrentPARAMS,'dimension')
        fgeneric('finalize');
        warning('FGENERIC:initfinal','%s', ...
               ['Finalization of non-finalized previous run was ' ...
               'conducted during the initialization process in ' ...
               'fgeneric.']);
      end
      if ~isnumeric(FUNC_ID) || FUNC_ID > length(handlesF)
        error('%s %d.',['2nd argument FUNC_ID is not a valid function ' ...
                        'identifier.']);
      end
      if ~isnumeric(itrial) || isempty(itrial)
        error('%s %d.', '3rd argument INSTANCE_ID is required to be an integer.');
      end

      actFunc = handlesF{FUNC_ID};
      Fopt = feval(actFunc, 'init', [], itrial);
      % if ~(nargin > 3 && ~isempty(itrial))
      %   Fopt = feval(actFunc, 'fopt');
      % end

      Fvalue = Fopt + DeltaFtarget; % minimization

      LastEval = struct('num', 0, 'F', inf, 'Fnoisy', inf, 'bestFnoisy',...
                       inf, 'x', []); % minimization
      lastWriteEval = 0;
      BestFEval = LastEval;
      BestFEval.isWritten = 1;

      idxFTrigger = LastEval.F;
      fTrigger = 10^(idxFTrigger/nbPtsF);
      idxEvalsTrigger = 0;
      evalsTrigger = floor(10^(idxEvalsTrigger/nbPtsEvals));
      idxDIMEvalsTrigger = 0;

      % Finish setting the default parameters
      DefaultPARAMS.precision = DeltaFtarget;

      % Setting CurrentPARAMS
      if nargin < 5 || isempty(PARAMS)
        PARAMS = DefaultPARAMS;
      else
        if isstruct(PARAMS)
          tmp = setdiff(fieldnames(DefaultPARAMS),fieldnames(PARAMS));
          for i = 1:length(tmp)
            PARAMS.(tmp{i}) = DefaultPARAMS.(tmp{i});
          end
          tmp = setdiff(fieldnames(PARAMS),fieldnames(DefaultPARAMS));
          PARAMS = rmfield(PARAMS,tmp);
          % Set the missing fields of PARAMS (compared to DefaultPARAMS)
          % to the values of DefaultPARAMS and remove the additional fields
          % from PARAMS.
        else
          error('%s',['Third argument PARAMS of fgeneric is expected ' ...
                     'to be a structure.']);
        end
      end

      PARAMS.itrial = itrial;

      switch PARAMS.inputFormat
      case 'row', isRowFormat = 1;
      case 'col', isRowFormat = 0;
      otherwise
        warning('FGENERIC:colrow','%s', ...
               ['The inputFormat field of PARAMS is expected to' ...
               ' match either ''col'' or ''row''. Attempting to' ...
               'use default (''row'').']);
        isRowFormat = 0;
      end
      PARAMS.funcId = FUNC_ID;
      % indexFilePrefix = fullfile(dataPath, PARAMS.filePrefix);
      PARAMS.indexFile = [];
      PARAMS.runCounter = 1;

      %Comparison with PreviousPARAMS
      isParamsMatching = 0;
      if ~isempty(PreviousPARAMS)
        fieldsN = {'funcId','algName','comments','precision', ...
                  'indexFile'};
        isParamsMatching = 1;
        i = 1;
        while isParamsMatching && i <= length(fieldsN)
          tmp = class(PreviousPARAMS.(fieldsN{i}));
          if strcmp(tmp, class(PARAMS.(fieldsN{i})))
            switch tmp
            case 'char'
              isParamsMatching = strcmp(PreviousPARAMS.(fieldsN{i}), ...
                                       PARAMS.(fieldsN{i}));
            case 'double'
              isParamsMatching = eq(PreviousPARAMS.(fieldsN{i}), ...
                                   PARAMS.(fieldsN{i}));
            end
          end
          i = i+1;
        end
        isParamsMatching = isParamsMatching && ...
                           isfield(PreviousPARAMS,'dimension');
        if isParamsMatching
          PARAMS.runCounter = PreviousPARAMS.runCounter;
        end
      end

      CurrentPARAMS = PARAMS;

      return;

    %----------------------------------------------------------------------
    elseif strcmpi(x, 'finalize')

      if isempty(actFunc)
        warning('FGENERIC:initfinal','%s', ...
               ['Finalization process of fgeneric is called ' ...
               'before the initialization process has occurred.']);
      else
        if isfield(CurrentPARAMS,'dimension') 
          CurrentPARAMS.runCounter = CurrentPARAMS.runCounter + 1;
          PreviousPARAMS = CurrentPARAMS;
        end
      end

      if ~isempty(BestFEval)
        Fvalue = BestFEval.F;
      end

      actFunc = [];

      return;

    elseif strncmpi(x, 'evaluations', 4)
      if isempty(actFunc)
        warning('FGENERIC:initfinal','%s', ...
                'FGENERIC has not been initialized.');
      else
        Fvalue = LastEval.num;
      end
      return;

    elseif strcmpi(x, 'best') || strcmpi(x, 'fbest')
      if isempty(actFunc)
        warning('FGENERIC:initfinal','%s', ...
                'FGENERIC has not been initialized.');
      else
        Fvalue = BestFEval.F; %is defined if actFunc is defined.
      end
      return;

    elseif strcmpi(x, 'ftarget')
      if isempty(actFunc)
        warning('FGENERIC:initfinal','%s', ...
                'FGENERIC has not been initialized.');
      else
        Fvalue = Fopt + DeltaFtarget;
      end
      return;

    elseif strcmpi(x, 'maxEvals') || strcmpi(x, 'maxFunEvals')
      Fvalue = maxFunEvalsFactor * FUNC_ID; % second argument FUNC_ID is the dimension.
      return;

    else
      error('FGENERIC:argin','%s', ...
             sprintf(' ''%s'' is not recognized as valid input.', x));

    end % if strcmp(x, 'finalize')
  else
    if ~isnumeric(x)
      error('FGENERIC:argin','%s', ...
             ['Function Fgeneric expects as 1st input argument '...
             'either ''initialize'', ''finalize'' or a vector.'])
    end
  end % ischar(x)

  %------------------------------------------------------------------------
  if isempty(actFunc)
    error('%s',['fgeneric has not been initialized. Please do: ' ...
               'fgeneric(''initialize'', FUNC_ID, INSTANCE_ID, DATAPATH) ' ...
               'first, where FUNC_ID is the number of the chosen test ' ...
               'function.']);
  end

  if isRowFormat
    x = x';
  end

  [DIM,POPSI] = size(x);

  if isfield(CurrentPARAMS,'dimension')
    if DIM ~= CurrentPARAMS.dimension
      %finalize
      fgeneric('finalize');
      fgeneric('initialize', CurrentPARAMS.funcId, CurrentPARAMS.itrial, ...
               datapath, CurrentPARAMS);
      isParamsMatching = 0;
      CurrentPARAMS.runCounter = 1;
    end
  end

  if ~isfield(CurrentPARAMS,'dimension')
    CurrentPARAMS.dimension = DIM;
  end

  [FvalueOut, Ftrue] = feval(actFunc, x);
  Fvalue = FvalueOut;

  % remove infeasible candidates, they should not count
  % as function evaluations?
  % does not make sense for the slope
  if 11 < 3
    idxfeasible = all(x > -5 & x < 5, 1);
    if sum(idxfeasible) < POPSI
      POPSI = sum(idxfeasible);
      if POPSI == 0
        Fvalue = FvalueOut;
        return;
      end
      x = x(:, idxfeasible);
      Fvalue = FvalueOut(idxfeasible);
      Ftrue = Ftrue(idxfeasible);
    end
  end

  [bestFtrue,iBestFtrue] = min(Ftrue);

  buffer = '';
  hbuffer = '';

  if (LastEval.num+POPSI >= evalsTrigger || bestFtrue-Fopt < fTrigger)

    for j = 1:POPSI
      evalsj = LastEval.num + j;

      if Fvalue(j) < LastEval.bestFnoisy % minimization
        LastEval.bestFnoisy = Fvalue(j);
      end

      if Ftrue(j) < BestFEval.F % minimization
        bestF_j = j;
        BestFEval.F = Ftrue(j);
        BestFEval.bestFnoisy = LastEval.bestFnoisy;
        BestFEval.isWritten = 0;
      end

      if (evalsj >= evalsTrigger)

        lastWriteEval = evalsj;

        if exist('bestF_j','var') && j == bestF_j
          BestFEval.isWritten = 1;
        end

        buffer = [buffer sprintData(evalsj,Ftrue(j), BestFEval.F, ...
                                Fvalue(j), LastEval.bestFnoisy, x(:,j),Fopt)];
        while evalsj >= floor(10^(idxEvalsTrigger/nbPtsEvals))
          idxEvalsTrigger = idxEvalsTrigger + 1;
        end
        while evalsj >= DIM * 10^idxDIMEvalsTrigger
          idxDIMEvalsTrigger = idxDIMEvalsTrigger + 1;
        end
        evalsTrigger = min(floor(10^(idxEvalsTrigger/nbPtsEvals)), ...
                           DIM * 10^idxDIMEvalsTrigger);

      end

      if (Ftrue(j) - Fopt < fTrigger)

        hbuffer = [hbuffer sprintData(evalsj,Ftrue(j),BestFEval.F,...
                                Fvalue(j), LastEval.bestFnoisy, x(:,j),Fopt)];

        if Ftrue(j)-Fopt <= 0
          fTrigger = -inf;
        else
          if isinf(idxFTrigger)
            idxFTrigger = ceil(log10(Ftrue(j)-Fopt))*nbPtsF;
          end
          while Ftrue(j) - Fopt <= 10^(idxFTrigger/nbPtsF)
            idxFTrigger = idxFTrigger - 1;
          end
          fTrigger = min(fTrigger, 10^(idxFTrigger/nbPtsF));

        end

      end
    end % for j = 1:size(x,POPSI)

    if ~BestFEval.isWritten && exist('bestF_j', 'var')
      BestFEval.num = LastEval.num+iBestFtrue;
      BestFEval.Fnoisy = Fvalue(iBestFtrue);
      BestFEval.x = x(:, iBestFtrue);
    end

  else
    if bestFtrue < BestFEval.F
      BestFEval.num = LastEval.num+iBestFtrue;
      BestFEval.Fnoisy = Fvalue(iBestFtrue);
      BestFEval.x = x(:,iBestFtrue);
      BestFEval.F = bestFtrue;
      BestFEval.bestFnoisy=min([LastEval.bestFnoisy Fvalue(1:iBestFtrue)]);
      BestFEval.isWritten = 0;
    end
    LastEval.bestFnoisy = min(LastEval.bestFnoisy,min(Fvalue));
  end % if (LastEval.num+POPSI >= evalsTrigger || bestFtrue-Fopt <= fTrigger)

  LastEval.num = LastEval.num + POPSI;
  LastEval.F = Ftrue(POPSI);
  LastEval.Fnoisy = Fvalue(POPSI);
  LastEval.x = x(:,POPSI);

  Fvalue = FvalueOut;

end % function fgeneric


%--------------------------------------------------------------------------
%
%  Subfunctions
%
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function res = sprintData(evals,F,bestF,Fnoisy,bestFnoisy,x,Fopt)
% SPRINTDATA writes a formatted line into a data file.
%     res = sprintData(EVALS,FTRUE,BESTF,FVALUE,BESTFVALUE,X)
  res = sprintf('%d',evals);
  res = [res sprintf(' %+10.9e',F-Fopt,bestF-Fopt,Fnoisy,bestFnoisy)];
  if length(x) < 22
    res = [res sprintf(' %+5.4e',x)];
  end
  res = [res sprintf('\n')];
end % res = sprintData(evals,F,bestF,Fnoisy,bestFnoisy,x)
%--------------------------------------------------------------------------
