%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tournament selection method for Genetic Algorithm. K number of 
% candidates are chosen from the population and ranked from best to worst.
%
% Parameters:
% Inputs: fitnessSorted_breed - Fitness scores sorted in ascending order
%         popSorted.binaryImage     - Population sorted in ascending order
%                               according to their fitness value
%         nPop_withoutBest    - Number of population members excluding the
%                               best member
%         numOfChildren       - Number of children resulting from
%                               cross-over
% Output: nextParents.binaryImage         - Set of parents used for reproduction for
%                               the next generation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function nextParents = Selection(fitnessBreed, popBreed, nPop_withoutBest, numOfChildren)
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
nextParents.binaryImage      = cell(1, childrenPopulation);
nextParents.dBetweenGratings = zeros(1, childrenPopulation);
candidates_pop.binaryImage   = cell(1, K);

% Selection:
j = 1;
for i = 1:childrenPopulation
    % Find 5 random indexes
    candidates = randperm(nPop_withoutBest, K);
    % Find those indexes' fitness and populations
    candidates_fitness = fitnessBreed(candidates);
    for ii = 1:K
        candidates_pop.binaryImage{ii} = popBreed.binaryImage{candidates(ii)};
    end
    candidates_pop.dBetweenGratings =  popBreed.dBetweenGratings(candidates);
    
    % Chose best fitness from candidates
    [~, idx] = min(candidates_fitness);  % minimization problem
    % Keep the winning parent candidate
    nextParents.binaryImage{j}      = candidates_pop.binaryImage{idx};
    nextParents.dBetweenGratings(j) = candidates_pop.dBetweenGratings(idx);
    
    j = j + 1;
end

end