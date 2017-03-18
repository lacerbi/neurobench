
function [X0, F0, NC, NFE] = myGLOBAL(FUN, LB, UB, OPTS)

%==========================================================================
% GLOBAL   - A stochastic global optimization method for MATLAB, based on
% the article: 
%
% Tibor Csendes, László Pál, J. Oscar H. Sendín, Julio R. Banga: 
% The GLOBAL Optimization Method Revisited. Optimization Letters, 2(2008),  445-454 
%            
% Version 1.0, Last Update: September 8, 2008
%
% Developed by : Oscar H. Sendin
%                Tibor Csendes  (csendes@inf.u-szeged.hu)
%                László Pál     (pallaszlo@sapientia.siculorum.ro)
%  
% Source: http://www.inf.u-szeged.hu/~csendes
%
% Please report problems and bugs to:
% Tibor Csendes  (csendes@inf.u-szeged.hu) or László Pál
% (pallaszlo@sapientia.siculorum.ro)
%   
% INPUTS :
%   FUN  :  Function handler
%   LB   :  Lower bounds on the variables
%   UB   :  Upper bounds on the variables
%   OPTS :  MATLAB structure
%
%       OPTS.N100       :   Number of sample points to be drawn uniformly
%                           in one cycle (20<=N100<=100000), default value = 10*nvars
%       OPTS.NG0        :   Number of best points selected from the actual sample
%                           (1<=NG0<=20), default value = min(2*nvars,20) 
%       OPTS.NSIG       :   Convergence criterion, (suggested value =
%                           6,7,8), default value = 6
%       OPTS.MAXFN      :   Maximum number of function evaluations for
%                           local search, default value = 1000
%       OPTS.MAXNLM     :   Maximum number of local minima (clusters),
%                           default value = 20
%       OPTS.METHOD     :   Local method used ('bfgs' or 'unirandi'),
%                           default value = 'unirandi'
%       OPTS.DISPLAY    :   Display intermediary or final results('on','final','off')
%                           default value = 'final'
%       OPTS.MAXFUNEVALS:   Maximum number of function evaluations         
%
% OUTPUTS:
%    X0  :  Matrix whose columns are the local minimizers found
%    F0  :  Corresponding function values, i.e. f(i) = f(x(:,i))
%    NC  :  Number of different local minimizers found
%    NFE :  Number of function calls
%==========================================================================


%========= Determine option values ==========%
if nargin < 3, error('Wrong number of input arguments'); end 
if nargin < 4, OPTS = []; end
if (nargin==4) && (isempty(OPTS)), OPTS = []; end
if ~isa(FUN, 'function_handle')
    error('Wrong function handler');
end

NPARM = length(LB);
if NPARM <= 0, error('Data error'); end
PMIN = LB;
PMAX = UB;
if any(PMIN==PMAX), error('Data error'); end

%========= Setting default values for parameters =========%
[N100, NG0, NSIG, MAXFN, MAXNLM, METHOD, MAXFUNEVALS, DISPLAY]=...
getopts(OPTS, ...
 'N100',       10*NPARM,...             % Number of sample points to be drawn uniformly in one cycle
 'NG0',        min(2*NPARM,20),...      % Number of best points selected from the actual sample
 'NSIG',       6,...                    % Convergence criterion
 'MAXFN',      1000,...                 % Maximum number of function evaluations for local search
 'MAXNLM',     20,...                   % Maximum number of local minima  
 'MAXFUNEVALS', Inf,...                 % Maximum number of function evaluations  
 'METHOD',     'unirandi',...           % Local method used
 'DISPLAY',    'final');                % Display intermediar results

%======== Check number of best points selected ====%
if ( NG0 < 1 ),  NG0 = 1;  end
if ( NG0 > 20 ), NG0 = 20; end

NG10 = 100; % maximum number of points selected 
NNN  = 0;

%======== Check number of sample points ========%

if ( N100 < 20 ), N100 = 20; end
if ( N100 > 100000 ), N100 = 100000; end
if ( N100 >= 1000 ), 
    NN100 = 1000 ;
    N     = floor(N100/1000) ;
    NNN   = N100 - N*1000;
    N100  = N*1000 ;
elseif ( N100 < 1000) && (N100>100)
    NN100 = 100 ;
    N     = floor(N100/100); 
    NNN   = N100 - N*100;
    N100  = N*100 ;
else
    NN100 = N100;
    N     = 1;
end


%======= Initialize the variables ========%

F   = zeros(100,1); 
F0  = zeros(100,1);
F1  = zeros(100,1);
FCL = zeros(100,1);

X   = zeros(NPARM,100);
X0  = zeros(NPARM,100);
X1  = zeros(NPARM,100);
XCL = zeros(NPARM,100);

D   = 2.*sqrt(NPARM)*0.000001;
B1  = 1/NPARM;

F   = 9.9e10*ones(NG10,1) ;
IC  = zeros(NG10,1) ;             % index of the cluster 

PMAX = ( PMAX - PMIN )/2 ;
PMIN = PMIN + PMAX ;

alfa = 0.01 ;
NFE  = 0 ;                        % Number of function evaluations
NRFE = MAXFUNEVALS - NFE;         % Number of remaining function evaluations
NG   = 0 ;                        % Current number of points selected
NS   = 0 ;                        % Number of samplings
NC   = 0 ;                        % Number of local minimizers
NCP  = 1 ;
N0   = 0 ;
N1   = 0 ;
IM   = 1 ;                        % Index for FM
FM   = 9.9e10 ;   
RELCON = 10.^(-NSIG) ;
RELCONX = 10.^(-6);               % Convergence criterion on X
IT   = 1 ;

%============ Main iteration =============%

while IT > 0,
        
    %==================================================%
    %                     SAMPLING                     %  
    %==================================================%

    N0 = N0 + N100 ;
    NM = N0-1 ;
    NG = NG + NG0 ;
    NS = NS + 1 ;
    
    if ( NS*NG0 > 100 ), 
            fprintf('*** TOO MANY SAMPLING ***\n');                                                
            [X0,F0] = printresults(X0,F0,NC,NFE,PMIN,PMAX);
        return
    end
    
    B = ( 1 - alfa^(1/NM))^B1;
    BB = 0.1*B;
    
    % rand('state',100*sum(clock));
    NN100 = min(NN100,NRFE);
    for i = 1:N    
        R = rand(NN100,NPARM);
        for j  = 1:NN100 
            Y  = [2*R(j,:)-1]';            
            FC = globfun(Y,FUN,PMIN,PMAX);      % Evaluate objective function
            if FC < FM,
                F(IM)   = FC ;
                X(:,IM) = Y ;
                IC(IM)  = 0 ;
                [FM,IM] = max(F);
            end
        end
    end
    NFE = NFE + N100;
    NRFE = MAXFUNEVALS - NFE;
    NNN = min(NNN,NRFE);
    if(NNN > 0)
        R = rand(NNN,NPARM);
        for j  = 1:NNN 
            Y  = [2*R(j,:)-1]';            
            FC = globfun(Y,FUN,PMIN,PMAX);      % Evaluate objective function
            if FC < FM,
                F(IM)   = FC ;
                X(:,IM) = Y ;
                IC(IM)  = 0 ;
                [FM,IM] = max(F);
            end
        end
    end
    NFE = NFE + NNN;
    NRFE = MAXFUNEVALS - NFE;
    
    if isequal(DISPLAY,'on')
        fprintf('Function evaluations used for sampling : %i \n',N100);
    end
    
    %==================================================%
    %                     SORTING                      %  
    %==================================================%

    [F,IS]  = sort(F);
    X       = X(:,IS);
    IC      = IC(IS);
    [FM,IM] = max(F);

    %==================================================%
    %               CLUSTERING TO X*                   %  
    %==================================================%

    if NC > 0, 
        for iii = 1:NC,
            I   = 1;
            IN1 = I; 
            FCL(I)   = F0(iii);
            XCL(:,I) = X0(:,iii);               % 1st point of cluster iii is local minimum iii 
            icm = find(IC(1:NG)==iii);          % find points clustered to local minimum iii
            if ~isempty(icm)
                IN1 = IN1 + length(icm);
                XCL(:,2:IN1) = X(:,icm);
                FCL(2:IN1)   = F(icm);
            end
            %======= Single Linkage Clustering =======%
            [FCL, XCL, IC] = SLC(FCL, XCL, F, X, IC, NG, IN1, I, iii, B, PMAX, PMIN, DISPLAY);            
        end % for iii = 1:NC
    end % if NC > 0
    
    %==================================================%
    %               CLUSTERING TO X1                   %  
    %==================================================%
    
    if N1 > 0
        for iii = 1:N1,
            I   = 1;
            IN1 = I;
            FCL(I)   = F1(iii);
            XCL(:,I) = X1(iii);     
            %======= Single Linkage Clustering =======%
            [FCL, XCL, IC] = SLC(FCL, XCL, F, X, IC, NG, IN1, I, iii, B, PMAX, PMIN, DISPLAY);
        end % for iii=1:N1
    end % if N1 > 0
                            
    %==================================================%
    %               LOCAL SEARCH                       %  
    %==================================================%
    
    IT  = 0;
    NSP = 0;                        % '1' if a new seed point is added to a cluster
    
    for i1 = 1:NG, 
        if IC(i1)~=0, continue, end  
        Y  = X(:,i1);
        FF = F(i1);
        
        %======== Call local solver =======%
        
        LFN = min(MAXFN,NRFE);  % Function evaluations for local solver
        if LFN > 0
            switch(lower(METHOD))
                case 'bfgs'
                   options = optimset('LargeScale','off', 'HessUpdate','bfgs','MaxFunEvals',LFN,'Display', 'off','LineSearchType', 'quadcubic');
                   options.TolFun = RELCON;
                   options.TolX   = RELCONX;
                   Y = PMAX.*Y + PMIN;
                   [x,fval,exitflag,output] = fminunc(FUN,Y,options);
                   Y     = (x - PMIN)./PMAX;
                   FF    = fval;
                   NFEVL = output.funcCount;
                case 'fmincon'
                   options = optimset('MaxFunEvals',LFN,'Display', 'off');
                   options.TolFun = RELCON;
                   options.TolX   = RELCONX;
                   Y = PMAX.*Y + PMIN;
                   [x,fval,exitflag,output] = fmincon(FUN,Y,[],[],[],[],LB,UB,[],options);
                   Y     = (x - PMIN)./PMAX;
                   FF    = fval;
                   NFEVL = output.funcCount;                   
                case 'unirandi'
                   [Y,FF,NFEVL] = myunirandi(FUN,Y,FF,PMIN,PMAX,LFN,RELCON,RELCONX);
                case 'bps'
                   options.TolFun = RELCON;
                   options.TolX = RELCONX;
                   options.MaxFunEvals = LFN;
                   options.Ninit = 0;
                   [x,fval,exitflag,output] = bps(FUN,Y,LB,UB,LB,UB,options);
                   Y     = (x(1,:)' - PMIN)./PMAX;
                   FF    = fval(1);
                   NFEVL = output.FuncCount;
             end
        end
        
        if NC > 0
            for iv = 1:NC
                W  = abs( X0(:,iv) - Y ) ;
                A  = max(W);
                if A < BB                      
                    N1 = N1 + 1 ;             
                    if isequal(DISPLAY,'on')
                        fprintf('New seed point added to the cluster no. %i, NFEV = %i\n',iv,NFEVL);
                        W = X(:,i1).*PMAX + PMIN ;                    
                        disp(FF);
                        disp(W);
                    end
                    if FF < F0(iv)
                        if isequal(DISPLAY,'on')
                            fprintf('*** IMPROVEMENT ON THE LOCAL MINIMUM NO. %i : %12.6g FOR %12.6g\n',iv,F0(iv),FF);
                            W = Y.*PMAX + PMIN;
                            disp(W);
                        end
                        F0(iv)   = FF;
                        X0(:,iv) = Y;
                    end
                    if N1 > 20, 
                            fprintf('*** TWO MANY SEED POINTS *** \n');                                                                                
                            [X0,F0] = printresults(X0,F0,NC,NFE,PMIN,PMAX);
                        return
                    end
                    X1(:,N1) = X(:,i1);
                    XCL(:,1) = X(:,i1);
                    F1(N1)   = F(i1);
                    FCL(1)   = F(i1);
                    IC1(N1)  = iv;
                    ICJ      = iv;
                    NSP      = 1;                   % new seed point, go to clustering to the new point
                    break;
                end
            end % for iv = 1:NC
        end % if NC > 0
        
        
        
        %==================================================%
        %                  NEW LOCAL MINIMUM               %  
        %==================================================%
        
        if NSP == 0
            NC  = NC + 1;
            NCP = NCP + 1;
            if isequal(DISPLAY,'on')
                fprintf('*** LOCAL MINIMUM NO. %i : %12.6g, NFEV = %i\n',NC,FF,NFEVL);
                W = Y.*PMAX + PMIN ;
                disp(W);
            end
            X0(:,NC) = Y;
            XCL(:,1) = Y;
            FCL(1)   = FF;
            F0(NC)   = FF;
            if NC >= MAXNLM 
                    fprintf('*** TOO MANY CLUSTERS ***\n');                                                           
                    [X0,F0] = printresults(X0,F0,NC,NFE,PMIN,PMAX);
                return;
            end
            IT  = 1;
            ICJ = NC;
        end
        
        %==================================================%
        %            CLUSTERING TO THE NEW POINT           %  
        %==================================================%
        
        NFE    = NFE + NFEVL;
        NRFE   = MAXFUNEVALS - NFE;
        IC(i1) = ICJ;
        I      = 1;
        IN1    = I; 
        %======= Single Linkage Clustering =======%
        [FCL, XCL, IC] = SLC(FCL, XCL, F, X, IC, NG, IN1, I, ICJ, B, PMAX, PMIN, DISPLAY);
        NSP    = 0;

    end % for i1 = 1:NG      

end % while IT > 0


if (isequal(DISPLAY,'final') || isequal(DISPLAY,'on'))
    [X0,F0] = printresults(X0,F0,NC,NFE,PMIN,PMAX);
else
    [F0,IS] = sort(F0(1:NC));
    X0      = X0(:,IS); 
    for i = 1:NC
        X0(:,i) = X0(:,i).*PMAX + PMIN;
    end
end

end % function GLOBAL


%==================================================%
%                  PRINT RESULTS                   %  
%==================================================%


function [X0,F0] = printresults(X0,F0,NC,NFE,PMIN,PMAX)

    fprintf(' NORMAL TERMINATION AFTER %i FUNCTION EVALUATIONS \n',NFE);

    [F0,IS] = sort(F0(1:NC));
    X0      = X0(:,IS); 
    for i = 1:NC
        X0(:,i) = X0(:,i).*PMAX + PMIN;    
    end
    nlm = length(F0);

    fprintf('\n\n LOCAL MINIMUM FOUND: %i \n\n',nlm);
    fprintf('F0 = \n');
    disp(F0);
    fprintf('\nX0 = \n');
    disp(X0);
    fprintf('GLOBAL MINIMUM VALUE: %.15f\n', F0(1));
    fprintf('GLOBAL MINIMUM: \n');
    disp(X0(:,1));
return        
end

%==================================================%
%  Returns options values in an options structure  %  
%==================================================%

function varargout = getopts(opt,varargin)
    fields = {'N100','NG0','NSIG', 'MAXFN', 'MAXNLM','METHOD','MAXFUNEVALS','DISPLAY'};
    % create cell array
    structinput = cell(2,length(fields));
    structdef   = cell(2,length(fields));
    % fields go in first row
    structinput(1,:) = fields';
    structdef(1,:)   = fields';
    % []'s go in second row
    structinput(2,:) = {[]};
    % turn it into correctly ordered comma separated list and call struct
    options = struct(structinput{:});
    j = 2;
    for i = 1:length(fields)
        structdef(2,i) = varargin(j);
        j = j + 2;
    end
    def = struct(structdef{:});
        
    if(isa(opt,'struct'))   
        for i = 1:length(fields)
           if isfield(opt, fields{i}) && ~isempty(opt.(fields{i}))
               options.(fields{i}) = opt.(fields{i});
           else
               options.(fields{i}) = def.(fields{i});
           end                                 
        end
    else
           options = def;
    end    

    if ~strcmp(options.METHOD, 'unirandi') && ~strcmp(options.METHOD, 'bfgs') && ~strcmp(options.METHOD, 'fmincon') && ~strcmp(options.METHOD, 'bps')
       error('Wrong name of local search method');
    end
    
    if ~strcmp(options.DISPLAY, 'on') && ~strcmp(options.DISPLAY, 'final') && ~strcmp(options.DISPLAY, 'off')
       error('Wrong name of display parameter');
    end
    
    varargout = struct2cell(options);    
    
return
end

%==================================================%
%            Single Linkage Clustering             %  
%==================================================%

function [FCL, XCL, IC] = SLC(FCL, XCL, F, X, IC, NG, IN1, I, iii, B, PMAX, PMIN, DISPLAY)

            while I <= IN1,
                for j=1:NG,
                    if ( IC(j)==0 && FCL(I) < F(j) )
                        W = abs( XCL(:,I) - X(:,j) );
                        A = max(W);
                        if A < B                            
                            if isequal(DISPLAY,'on')
                                fprintf('Sample point added to the cluster No. %i\n',iii);   
                                Xc = X(:,j).*PMAX + PMIN ;
                                disp('F = ');
                                disp(F(j));
                                disp(' ');
                                disp('X = ');
                                disp(Xc);
                            end
                            IN1 = IN1 + 1;
                            FCL(IN1) = F(j);
                            XCL(:,IN1) = X(:,j);
                            IC(j) = iii ;
                        end % if A < B
                    end % if ( IC(j)==0 & FCL(I) < F(j) )
                end % for j=1:NG
                I = I + 1;
            end % while I <=IN1
return
end