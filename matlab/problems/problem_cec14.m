function probstruct = problem_cec14(prob,subprob,noise,id,options)

% Problem names (ordered)
problist = {'sphere',...
    'ellipsoid',...
    'rotated_ellipsoid',...
    'step',...
    'ackley',...
    'griewank',...
    'rosenbrock',...
    'rastrigin',...
    'stybtang',...
    'cliff'};

% Initialize problem structure
if ischar(subprob); D = extractnum(subprob); else D = subprob; end
probstruct = initprob(prob,problist,'cec14',[num2str(D) 'D'],id);
[~,probstruct.Title] = cec14_eotp_functions_revised(zeros(1,2),probstruct.Number);
probstruct.func = ['@(x_,probstruct_) cec14_eotp_functions_revised(x_,' num2str(probstruct.Number) ', probstruct_)'];

switch probstruct.Number
    case {1,2,3,4,7,8,10}; probstruct.InitRange = [-20*ones(1,D); 20*ones(1,D)];
    case 5; probstruct.InitRange = [-32*ones(1,D); 32*ones(1,D)];
    case 6; probstruct.InitRange = [-600*ones(1,D); 600*ones(1,D)];
    case 9; probstruct.InitRange = [-5*ones(1,D); 5*ones(1,D)];
end

probstruct.LowerBound = probstruct.InitRange(1,:);
probstruct.UpperBound = probstruct.InitRange(2,:);
probstruct.D = D;

probstruct.Noise = noise;
probstruct.NoiseEstimate = 0;       % Function are intrinsically not-noisy

% Reduced number of function evaluations for noisy functions
if ~isempty(probstruct.Noise); probstruct.MaxFunEvals = 100*probstruct.D; end

% Randomize problem
shiftBounds = [-80;80]*ones(1,probstruct.D);
probstruct.RandomShift = rand(1,probstruct.D).*diff(shiftBounds,[],1) + shiftBounds(1,:);
R = grammSchmidt(randn(probstruct.D));
% Check that it is a rotation matrix
if det(R) < 0; temp = R(:,1); R(:,1) = R(:,2); R(:,2) = temp; end
assert(sum(sum(R'*R-eye(probstruct.D))) < 1e-12, 'Random rotation matrix is not a rotation matrix.');
probstruct.RandomRotation = R;

% Compute minima location
switch probstruct.Prob
    case 'rosenbrock'
        x0 = ones(probstruct.D,1);    
    case 'stybtang'
        x0 = -2.903532049983945*ones(probstruct.D,1);
    otherwise
        x0 = zeros(probstruct.D,1);
end
probstruct.TrueMinX = cec14_rotate_shift_revised(x0,probstruct.Number,probstruct,1);
probstruct.TrueMinX = probstruct.TrueMinX(:)';
func = str2func(probstruct.func);
assert(abs(func(probstruct.TrueMinX(:),probstruct)) < 1e-10,'Error in function initialization: f(x*) is not 0.');
probstruct.TrueMinFval = 0;

%--------------------------------------------------------------------------
function probstruct = initprob(prob,problist,ProbSet,SubProb,id)
%INITPROB Initialize problem structure.

if isnumeric(prob); prob = problist{prob}; end
probstruct.ProbSet = ProbSet;
probstruct.Number = find(strcmp(problist,prob),1);
probstruct.Prob = prob;
probstruct.SubProb = SubProb;
probstruct.Id = id;
