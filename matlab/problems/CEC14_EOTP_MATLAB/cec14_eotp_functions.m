function [f,func_name] = cec14_eotp_functions(x, no)
%CEC14_EOTP_FUNCTIONS Implement CEC14 expensive optimization test problems.
%   [F,FUNC_NAME] = CEC14_EOTP_FUNCTIONS(X, NO) with X as the design
%   points and FUNC_NO as functions' number (in [1,2,3,4,5,6,7,8]). F
%   should be the evaluation of F_no(x). In X, which should be a vector of
%   one design point. FUNC_NAME return the functions' name. Output argument
%   FUNC_NAME could be ommited.
%   
%   Example    
%         [f,name]=cec14_eotp_functions(zeros(2,1), 1);
%         printf('%s : f%d([0;0])=%f.\n',name, 1, f);
%     calculate the 1st function at (0,0), print its name and value.
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
assert(no>=1 && no <= 8,'CEC14 expensive optimization test problems based on 8 functions.');
[row, col] = size(x);
assert(row==1 | col ==1, 'X should be a vector.');
x = reshape(x, max(row,col), 1);
assert(max(row,col)>=2,'Functions should at least be 2-D.');

names = {'Sphere function',...
    'Ellipsoid function',...
    'Rotated Ellipsoid function',...
    'Step function',...
    'Ackley function',...
    'Griewank function',...
    'Rosenbrock function',...
    'Rastrigin function'};

functions = {@sphere,...
    @ellipsoid,...
    @rotated_ellipsoid,...
    @step,...
    @ackley,...
    @griewank,...
    @rosenbrock,...
    @rastrigin};

if nargout >= 2
    func_name = names{no};
end

x = rotate_shift(x, no);

f = feval(functions{no},x);






