AMIN =[-10; -10];
AMAX =[ 10;  10];
    
OPT.N100    = 50;
OPT.NG0     = 6;
OPT.NSIG    = 6;
OPT.METHOD  = 'bfgs';
OPT.DISPLAY = 'final';
FUN = @griewank;

[X0,F0,NC,NFE] = GLOBAL(FUN, AMIN, AMAX, OPT);