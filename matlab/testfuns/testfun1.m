function [f,df] = testfun1(x)

f = sum(sin(x));
df = cos(x);

end