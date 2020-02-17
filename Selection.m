%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tournament selection method for Genetic Algorithm. K number of 
% candidates are chosen from the population and ranked from best to worst.
%
% Parameters:
% Inputs: fitnessSorted_breed - Fitness scores sorted in ascending order
%         popSorted_breed     - Population sorted in ascending order
%                               according to their fitness value
%         nPop_withoutBest    - Number of population members excluding the
%                               best member
%         numOfChildren       - Number of children resulting from
%                               cross-over
% Output: nextParents         - Set of parents used for reproduction for
%                               the next generation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function nextParents = Selection(fitnessSorted_breed, popSorted_breed, nPop_withoutBest, numOfChildren)
rng('shuffle');
%% Tounament selection method:
% Number of children output from selection
childrenPopulation = round(nPop_withoutBest / numOfChildren);

% Set k-value
if(nPop_withoutBest >= 5)
    K = 5;
else
    K = nPop_withoutBest;
end

% Pre-allocation of memory
nextParents   = cell(1, childrenPopulation);
candidates_pop = cell(1, K);

% Selection:
j = 1;
for i = 1:childrenPopulation
    % Find 5 random indexes
    candidates = randperm(nPop_withoutBest, K);
    % Find those indexes' fitness and populations
    candidates_fitness = fitnessSorted_breed(candidates);
    for ii = 1:K
        candidates_pop{ii} = popSorted_breed{candidates(ii)};
    end
    % Chose best fitness from candidates
    [~, idx] = min(candidates_fitness);  % minimization problem
    nextParents{j} = candidates_pop{idx};
    j = j + 1;
end

end