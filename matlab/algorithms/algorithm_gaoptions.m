function gaoptions = algorithm_gaoptions(algoset,probstruct)

if probstruct.D <= 5; PopSize = 50; else PopSize = 200; end
Generations = max(1,floor(probstruct.MaxFunEvals/PopSize)-1);
CrossoverFraction = 0.8;

MutationFcn = @mutationadaptfeasible;
% MutationFcn = @mutationgaussiancon;

switch algoset
    case 'hixover'; CrossoverFraction = 0.8;
    case 'mexover'; CrossoverFraction = 0.5;
    case 'loxover'; CrossoverFraction = 0.2;
    case 'gausscon'; MutationFcn = @mutationgaussiancon;
    case 'megausscon'; CrossoverFraction = 0.5; MutationFcn = @mutationgaussiancon;
end
             
gaoptions = gaoptimset(...
    'TolFun', probstruct.TolFun, ...
    'PopInitRange', probstruct.InitRange, ...
    'PopulationSize', PopSize, ...
    'Display', 'iter', ...
    'InitialPopulation', [], ...
    'MutationFcn', MutationFcn, ...
    'CrossoverFcn', @crossoverscattered, ...
    'Generations', Generations, ...
    'CrossoverFraction',CrossoverFraction ...
    );

% No elitism with noisy functions
%if ~isempty(probstruct.Noise) || probstruct.IntrinsicNoisy
%    gaoptions.EliteCount = 0;
%end

end