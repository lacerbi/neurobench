function x_rs = rotate_shift(x, no, bInv)
%ROTATE_SHIFT Summary of this function goes here
%   Detailed explanation goes here
% do rotation and shifting
% no    Name         Rotation        Shifting               Range                Extra
% 1     Sphere       no              orig / 8               [-20,20]
% 2     Ellipsoid    no              orig / 8               [-20,20]
% 3     REllipsoid   no              orig / 8               [-20,20]
% 4     Step         no              orig / 8               [-20,20]
% 5     Ackley       no              orig / 8               [-32, 32]
% 6     Griewank     no              orig / 8               [-600,600]
% 7     Rosenbrock   M*2.08/20       orig / 8               [-20, 20]                 +1
% 8     Rastrigin    M*5.12/20       orig / 8               [-20,20]
if nargin < 3
    bInv = 0;
end

dim = numel(x);
sd = shift_data(no);
ma = rotate_data(no,dim);
ma = reshape(ma, dim, dim);
ma = ma';

if bInv == 0
    switch no
        case {1,2,3,4,5,6}
            x_rs = x - reshape(sd(1:dim), size(x)) / 8;
        case 7
            x_rs = x - reshape(sd(1:dim), size(x)) / 8;
            x_rs = 2.08 / 20 * ma * x_rs + 1;
        case 8
            x_rs = x - reshape(sd(1:dim), size(x)) / 8;
            x_rs = 5.12 / 20 * ma * x_rs;
    end
else
    switch no
        case {1,2,3,4,5, 6}
            x_rs = x + reshape(sd(1:dim), size(x)) / 8;
        case 7
            x_rs = 20 / 2.08 * ma \ (x - 1) + reshape(sd(1:dim), size(x)) / 8;
        case 8
            x_rs = 20 / 5.12 * ma \ x + reshape(sd(1:dim), size(x)) / 8;
    end
    
end



