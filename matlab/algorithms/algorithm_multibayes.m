function [history,x,fval,algoptions] = algorithm_multibayes(algo,algoset,probstruct)
nvars = probstruct.D;

algoptions.TolFun = probstruct.TolFun;             % Standard TolFun
algoptions.MaxFunEvals = probstruct.MaxFunEvals;
algoptions.Ninit = 20 + 4*nvars;

localoptions.TolFun = probstruct.TolFun;

switch algoset
    case {1,'1','base'}; algoset = 'base';  % Use defaults
    otherwise
        error(['Unknown algorithm setting ''' algoset ''' for algorithm ''' algo '''.']);
end

PLB = probstruct.InitRange(1,:);
PUB = probstruct.InitRange(2,:);
LB = probstruct.LowerBound;
UB = probstruct.UpperBound;
x0 = probstruct.InitPoint;

X = initSobol(x0,LB,UB,PLB,PUB,algoptions.Ninit,[],[]);
Y = NaN(size(X,1),1);
for i = 1:size(X,1)
    Y(i) = benchmark_func(X(i,:),probstruct); 
end

hyp = [];
while 1
    [xnew,optimState,gpstruct] = multibayes(X,Y,LB,UB,hyp,algoptions);
    hyp = gpstruct.hyp;
    
    if 1        
        localoptions.MaxFunEvals = 200 + 20*nvars;
        [x,fval,exitFlag,output,funValues,gpstruct] = ...
                bps(@(x) benchmark_func(x,probstruct),x0,LB,UB,PLB,PUB,localoptions);
        X = [X; funValues.X];
        Y = [Y; funValues.Y];
    else
        [x,fval] = ...
            fmincon(@(x) benchmark_func(x,probstruct),xnew,[],[],[],[],LB,UB,[],localoptions);
        X = [X; x];
        Y = [Y;fval];
    end
end    

[fval,idx] = min(Y);
x = X(idx,:);

history = benchmark_func(); % Retrieve history

% Clean output files
%trashfile = [pwd filesep 'glsinput.mat']; 
%if exist(trashfile, 'file'); delete(trashfile); end