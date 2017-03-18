function probstruct = problem_bbob09(prob,subprob,noise,id,options)

% Problem names (ordered)
funs = bbob09_benchmarks();
for i = 1:numel(funs); problist{i} = ['f' num2str(funs(i))]; end

% Initialize problem structure
if ischar(subprob); D = extractnum(subprob); else D = subprob; end
probstruct = initprob(prob,problist,'bbob09',[num2str(D) 'D'],id);
% [~,probstruct.Title] = prob;
probstruct.Title = probstruct.Prob;
probstruct.func = ['@(x_) bbob09_fgeneric_nowrite(x_(:))'];

probstruct.InitRange = [-5*ones(1,D); 5*ones(1,D)];
probstruct.LowerBound = probstruct.InitRange(1,:);
probstruct.UpperBound = probstruct.InitRange(2,:);
probstruct.D = D;

probstruct.Noise = noise;
probstruct.NoiseEstimate = 0;       % Function are intrinsically not-noisy

% Reduced number of function evaluations for noisy functions
if ~isempty(probstruct.Noise); probstruct.MaxFunEvals = 200*probstruct.D; end

% Initialize function
fmin = bbob09_fgeneric_nowrite('initialize', probstruct.Number, id, []);

probstruct.TrueMinX = NaN(1,D);
probstruct.TrueMinFval = fmin;

%--------------------------------------------------------------------------
function probstruct = initprob(prob,problist,ProbSet,SubProb,id)
%INITPROB Initialize problem structure.

if isnumeric(prob); prob = problist{prob}; end
probstruct.ProbSet = ProbSet;
probstruct.Number = find(strcmp(problist,prob),1);
probstruct.Prob = prob;
probstruct.SubProb = SubProb;
probstruct.Id = id;
