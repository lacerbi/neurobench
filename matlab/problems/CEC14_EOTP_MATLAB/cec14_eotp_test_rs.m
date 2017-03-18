
function cec14_eotp_test_rs(test_no)
%% CEC 14 expensive optimization problem test script
% If you have any question, please contact Qin Chen (cheqin1980@gmail.com)
%
% Usage:
%       cec14_eotp_test_rs(1);
%       cec14_eotp_test_rs(2);
%       cec14_eotp_test_rs(3);
% Test Cast                 contents
% 1                         2D function draw
% 2                         minimum design point in 2D
% 3                         optimizing with Matlab procedure

%% Functions test
% Draw 2D surf and contour of all 8 functions

tm = [1 0 -0.5 0; 0 1 0 0; 0 0 2 0; 0 0 1 -0.5];
functions = {'Sphere function',...
    'Ellipsoid function',...
    'Rotated Ellipsoid function',...
    'Step function',...
    'Ackley''s function',...
    'Griewank''s function',...
    'Rosenbrock''s function',...
    'Rastrigin''s function'};
ranges = {[-20,20],...
    [-20,20],...
    [-20,20],...
    [-20,20],...
    [-32,32],...
    [-50,50],...
    [-20,20],...
    [-20,20]
    };

    minimums = {[0,0]',...
        [0,0]',...
        [0,0]',...
        [0,0]',...
        [0,0]',...
        [0,0]',...
        [1,1]',...
        [0,0]'};

if (sum(test_no==1)>0)
    close all
    orig_pos = get(0, 'DefaultFigurePosition');
    for func_num=1:8
        
        xmin =  rotate_shift(minimums{func_num}, func_num,1);

        
        lim = ranges{func_num};
        if func_num == 6 || func_num == 4
            grid_num = 100;
        else
            grid_num = 40;
        end
        grids = lim(1):range(lim)/grid_num:lim(2);
        [x,y] = meshgrid(grids, grids);
        [row,col] = size(x);
        xx = reshape(x,numel(x),1);
        yy = reshape(y,numel(y),1);
        
        z = zeros(size(xx));
        for i=1:numel(z);
            z(i) = cec14_eotp_functions([xx(i),yy(i)]', func_num);
        end
        h = figure(func_num);
        set(h, 'Position', (tm * orig_pos')',...
            'Name', functions{func_num},'NumberTitle','off');

        subplot(1,2,1);
        contour(x,y,reshape(z,row,col),50);colorbar
        %     title(functions{func_num});
        title(sprintf('Global Optimizer : (%.2f,%.2f)', xmin));
        hold on
        plot(xmin(1),xmin(2),'x','MarkerSize',24);
        subplot(1,2,2);
        surfc(x,y,reshape(z,row,col));colorbar
        %     title(functions{func_num});
    end
    drawnow
end
%% Test miminum design point and ones(D,1) point with dimension 10
% we don't know that now.
if (sum(test_no==2)>0)
    

    
    
    for func_num = 1:8
        x_min =  rotate_shift(minimums{func_num}, func_num,1);
        fprintf('Global minimum(%30s) --> f%d([%f,%f]) = %f.\n', functions{func_num},...
            func_num,x_min(1:2),cec14_eotp_functions(x_min(1:2), func_num));
    end
    
    
    ones_x = ones(10,1);
    zeros_x = zeros(10,1);
    
    for func_num=1:8
        fprintf('f%d([', func_num);
        fprintf('%d,', ones_x(1:end-1));
        fprintf('%d])=%f\n', ones_x(end), cec14_eotp_functions(ones_x, func_num));
        fprintf('f%d([', func_num);
        fprintf('%d,', zeros_x(1:end-1));
        fprintf('%d])=%f\n', zeros_x(end), cec14_eotp_functions(zeros_x, func_num));
    end
    
end


%% Optimization test with MATLAB algorithms
if (sum(test_no==3)>0)
    
    tic;
    for i=1:1000000
        x= 0.55 + i;
        x=x + x; x=x/2; x=x*x; x=sqrt(x); x=log(x); x=exp(x); x=x/(x+2);
    end
    t0 = toc;
    
    fprintf('%45s %70s\n', 'Mimimum Fi(x)', 'Function evaluation count (Time cost)');
    fprintf('%10s %-20s %-20s %-20s %-20s %-20s %-20s\n', 'Problem no.','ga','pattern search', 'fminunc','ga','pattern search', 'fminunc')
    for no = 1:24
        func_no = ceil(no/3);
        switch mod(no,3)
            case 0
                dim = 30;
            case 1
                dim = 10;
            case 2
                dim = 20;
        end
        lu_lim = ranges{func_no};
        lb = lu_lim(1) * ones(dim,1);
        ub = lu_lim(2) * ones(dim,1);
        % GA test
        tic;
        [x1,fval1,exitflag1,output1] = ga(@(x)cec14_eotp_problems(x,no),dim,[],[],[],[],...
            lb, ub,[],gaoptimset('Display','off'));
        t1 = toc;
        % Pattern search test with GA result as start
        tic;
        [x2,fval2,exitflag2,output2] = patternsearch(@(x)cec14_eotp_problems(x,no),x1,[],[],[],[],...
            lb,ub,[],psoptimset('Display','off'));
        t2 = toc;
        warning off
        % fmincon test with GA result as start
        tic;
        [x3,fval3,exitflag3,output3] = fminunc(@(x)cec14_eotp_problems(x,no),x1,optimset('Display','off'));
        t3 = toc;
        fprintf('%10d %-20.4e %-20.4e %-20.4e %-8d %-11.2f %-8d %-11.2f %-8d %-11.2f\n', no,...
            fval1, fval2,fval3, output1.funccount, t1/t0, output2.funccount, t2/t0, ...
            output3.funcCount,t3/t0);
        
    end
end



