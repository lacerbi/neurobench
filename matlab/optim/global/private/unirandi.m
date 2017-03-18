function [X, F, NFEV] = unirandi(FUN, X0, F0, PMIN, PMAX, MAXFN, RELCON)

% UNIRANDI for MATLAB
%
% Input arguments
%   X0     :    Initial estimate of the location of the minimum
%   PMIN   :    A vector of length NPARM containing scaling factors supplied by
%               the global routine
%   PMAX   :    A vector of length NPARM containing scaling factors supplied by
%               the global routine
%   MAXFN  :    Maximum number of function evaluations allowed. 
%               The actual number of calls muy exceed this number slightly.
%   RELCON :    Convergence criterion. 
%
% Output arguments
%   X      :    Final estimate of the location of the minimum
%   F      :    Final function value
%   NFEV   :    Number of function evaluations

NPARM = length(X0);

if size(X0,1)==1,
    X0 = X0';
end

X = X0 ; % starting point
% F = fun(X,PMIN,PMAX);
F = F0 ;

H = 0.001 ; % initial steplength
DELTF = 1 ;
ITEST = 0 ;
NFEV = 0;

rand('state', 100*sum(clock));
R = rand(100,NPARM);

IRNDM = 0;

while ( NFEV < MAXFN )
    IRNDM = IRNDM + 1 ;
    if IRNDM > 100,
        R = rand(100,NPARM) ;
        IRNDM = 0 ;
        continue
    end
    
    R(IRNDM,:) = R(IRNDM,:) - 0.5 ;
    A = norm( R(IRNDM,:) ) ;
    
    % NEW TRIAL POINT
    R(IRNDM,:) = R(IRNDM,:)/A ;
    Xt = X + H*R(IRNDM,:)' ;
    
    % check bounds and enforce them
    ilt = find(Xt < -1);
    Xt(ilt) = -1;
    igt = find(Xt > 1);
    Xt(igt) = 1;
    
    % call fun
    Ft = globfun(Xt,FUN,PMIN,PMAX);
    NFEV = NFEV + 1 ;
    if ( Ft < F ) 
        [X,Xt,F,Ft,H,NFEV,DELTF] = linsearch(FUN,Xt,Ft,F,R(IRNDM,:),H,NFEV,PMIN,PMAX) ;
        % decrease step length
        H = abs(H/2);
        continue
    end
    % step in the opposite direction
    H = -H ;
    Xt = X + H*R(IRNDM,:)' ;
    
    % check bounds and enforce them
    ilt = find(Xt < -1);
    Xt(ilt) = -1;
    igt = find(Xt > 1);
    Xt(igt) = 1;
    
    % call fun
    Ft = globfun(Xt,FUN,PMIN,PMAX);
    NFEV = NFEV + 1 ;
    if ( Ft < F ) 
        [X,Xt,F,Ft,H,NFEV,DELTF] = linsearch(FUN,Xt,Ft,F,R(IRNDM,:),H,NFEV,PMIN,PMAX) ;
        % decrease step length
        H = abs(H/2) ;
        continue
    end
    ITEST = ITEST + 1 ;
    if (ITEST < 2), continue, end
    % decrease step length
    H = H / 2 ;
    ITEST = 0 ;
    % relative convergence test for the objective function
    if (DELTF < RELCON), return, end
    % convergence test for the step length
    if (abs(H) < RELCON), return, end
end
return

function [X,Xt,F,Ft,H,NFEV,DELTF] = linsearch(FUN,Xt,Ft,F,R,H,NFEV,PMIN,PMAX)

while ( Ft < F )  
    X = Xt ;
    DELTF = (F-Ft)/abs(Ft) ;
    F = Ft ;
    % increase step length
    H = 2*H ;
    Xt = X + H*R' ;
    % check bounds and enforce them
    ilt = find(Xt < -1);
    Xt(ilt) = -1;
    igt = find(Xt > 1);
    Xt(igt) = 1;
    % call fun
    Ft = globfun(Xt,FUN,PMIN,PMAX);
    NFEV = NFEV + 1 ;
end
return