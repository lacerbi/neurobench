function f = cec14_eotp_problems(x, no)
%CEC14_EOTP_PROBLEMS Implement CEC14 expensive optimization test problems.
%   [F] = CEC14_EOTP_PROBLEMS(X, NO) with X as the design
%   points and FUNC_NO as functions' number (in [1,2,...,24]). F
%   should be the evaluation of F_no(x). X is a vector coresponds to
%   one design point. 
%   
%   Example    
%         f=cec14_eotp_problems(zeros(10,1), 1);
%         printf('problem %d([0;0;0;0;0;0;0;0;0;0])=%f.\n', 1, f);
%       calculate the 1st function at (0;0;0;0;0;0;0;0;0;0), 
%       print its name and value.
%   
%   Details are to be found in B. Liu, Q. Chen and Q. Zhang, J. J. Liang, 
%   P. N. Suganthan, B. Y. Qu, "Problem Definitions and Evaluation Criteria
%   for Computationally Expensive Single Objective Numerical Optimization", 
%   Technical Report.
%
%   If you have any question, please contact Qin Chen (cheqin1980@gmail.com)
%
%   $Autor   : Qin Chen$
%   $E-mail  : cheqin1980@gmail.com$
%   $Revision: 1.0 $  $Date: 2013/12/21 20:14:00 $


%% Revision to include rotation and shifting 
% For shifting, 
%   1. Except Griewank and Ackley, we change the ranges of variables to 
%       [-20, 20].  [done test script]
%   2. We randomly generate data from [-10,10] for 10d, 20d, 30d. 
%       Their shifted data is from [-80,80] ([-20,20] is not enough), 
%       and we can divide them by 8. This is because if the search range 
%       is too large (except Griewank), the modeling often needs to use 
%       log and this may hide the performance of surrogate model 
%       assisted EA since different persons use different normalisation 
%       methods. [Get their shift data, make them a one-eighth]

% For rotating, 
%   we use their matrix. It may not be necessary to define our owns. 
%   For the sphere function, we shift and rotate it. sphere(M*(x-o))
%   For the ellipsoid function, we had better not shift and rotate it 
%       so as to compare with rotated ellipsoid function.
%   For the rotated ellipsiod function, leave it as it is. 
%   For f4, we rotate it. step(M*x)
%   For Ackley, we shift it. Ackley(x-o)
%   For Griewank, we shift it. Griewank(x-o)
%   For Rosenbrock, we shift and rotate it. Rosenbrock(M*(x-o))
%   For Rastrigin, we shift and rotate it. Rastrigin(M*(x-o))

%
assert(no>=1 && no <= 24,'Should be CEC14 expensive optimization test problem 1-24.');

[row, col] = size(x);


switch no 
    case {1,4,7,10, 13,16, 19,22}
        assert(max(row,col)==10,'Problem %d should be one of %d-D problems.', no,10);
    case {2,5,8,11, 14,17, 20,23}
        assert(max(row,col)==20, 'Problem %d should be one of %d-D problems.', no,20);
    case {3,6,9,12, 15,18, 21,24}
        assert(max(row,col)==30, 'Problem %d should be one of %d-D problems.', no,30);       
end

   
f = cec14_eotp_functions(x,ceil(no/3));







