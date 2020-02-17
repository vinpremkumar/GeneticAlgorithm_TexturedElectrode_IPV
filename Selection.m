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