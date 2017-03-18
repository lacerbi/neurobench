AMIN =[-2; -2];
AMAX =[ 2;  2];
    
OPT.N100    = 50;
OPT.NG0     = 2;
OPT.NSIG    = 6;
OPT.METHOD  = 'unirandi';
OPT.DISPLAY = 'final';
FUN = @ros2;

[X0,F0,NC,NFE] = GLOBAL(FUN, AMIN, AMAX, OPT);