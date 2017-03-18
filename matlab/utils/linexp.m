function y = linexp(x)
%LINEXP    Linearized exponential.
%   LINEXP(X) is the exponential of the elements of X, e to the X.
%   For complex Z=X+i*Y, EXP(Z) = EXP(X)*(COS(Y)+i*SIN(Y)).
%
%   See also EXP, LINLOG.

y = x;
z = abs(x);
f = z > 1;
y(f) = sign(x(f)).*exp(z(f)-1);