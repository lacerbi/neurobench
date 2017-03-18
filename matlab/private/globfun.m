function [F] = globfun(X,FUN,PMIN,PMAX)
    XR= PMAX.*X + PMIN ;
    F = feval(FUN,XR);
return