clearvars;
close all;
clc;

% When polygons are merged, the 2 polygons are first slipt into
% numOfMeshes x numOfMeshes and when mixed to make a new polygon.
numOfMeshes = 4;

%% Generic Algorithm's paramteres
maxPopulation       = 30;
maxGeneration       = 3;
mutationProbability = 0.1;
numOfChildren       = 2;

currentGeneration = 0;
rng('shuffle');

%% Input the radius in which polygon is created (Unit: nm)
                                          %%%%%%%%%%%%%%%%%%%%%%%
                                          % Enter circle radius % 
inputDiameter = 10;                       %   within which the  %
                                          %  random polygon is  %
                                          %       created       %
Radius      = (inputDiameter/2 * 1000)/2; %%%%%%%%%%%%%%%%%%%%%%%

%% Pre-allocation of memory
x = cell(1, maxPopulation);
y = cell(1, maxPopulation);

pop_binaryImage  = cell(1, maxPopulation);
fitnessValue     = zeros(1,maxPopulation);
popSorted_breed = cell(1,maxPopulation-1);

%% If maxGeneration hasn't reached yet, run the simulation
while currentGeneration <= maxGeneration
    tic
    %% Polygon parameter initilization
    numVerts            = randi([3 14], 1, maxPopulation);
    vertIndex           = find(numVerts > 12); % Limiting too many rounded structures
    numVerts(vertIndex) = 35;
    AspectRatio         = randi([1 5], 1, maxPopulation);
    dBetweenGratings    = randi([1 10], 1, maxPopulation) * 5;
    
    if currentGeneration == 0
        %% Creating initial population
        for i = 1:maxPopulation
            
            % Generate random convex polygons
            [x{i},y{i}] = GenerateRegularPolygon (Radius, numVerts(i), AspectRatio(i));
            
            % Obtain binary image of the polygons
            pop_binaryImage{i} = MaskPolygon(x{i},y{i},Radius);
            
            %     figure(i)
            %     imshow(binaryImage{i});
        end
        %% Calculate the Fitness
        for i = 1:maxPopulation
            fitnessValue(i) = FitnessFunction (dBetweenGratings(i), pop_binaryImage{i});
            
            % For testing purpose only
            % fitnessValue(i) = rand(1);
        end
    else
        for i = 2:maxPopulation
            fitnessValue(i) = FitnessFunction (dBetweenGratings(i), pop_binaryImage{i});
            
            % For testing purpose only
            % fitnessValue(i) = rand(1);
        end
    end
    
    % Display currentGeneration and fitnessValue in command window
    fprintf('Current Generation = %d\n', currentGeneration);
    fmt=['Fitness values:\n' repmat(' %.2f',1,numel(fitnessValue))];
    fprintf(fmt,fitnessValue);
    
    
    % Rank the population by their fitnessValue (minimization problem)
    [fitnessSorted, fitIndex] = sort(fitnessValue, 'ascend');
    
    %% Sorting population according to rank
    % pop_sort is the sorted population
    popSorted = pop_binaryImage;
    for i = 1:size(popSorted,2)
        popSorted{2,i} = fitIndex(i);
    end
    popSorted = popSorted';
    popSorted = sortrows(popSorted,2);
    popSorted = popSorted';
    popSorted(2,:) = [];
    
    %% Cloning the best specimen
    pop_best = popSorted{1};
    
    %% Selection
    % Make population to be used for selection
    for i = 2 : size(popSorted,2)
        popSorted_breed{i-1} = popSorted{i};
    end
    fitnessSorted_breed = fitnessSorted(2:end);
    % Even number of population is required to be input for selection
    if(mod(maxPopulation,2))
        nPop_withoutmax = maxPopulation - (numOfChildren - 1);
    else
        nPop_withoutmax = maxPopulation - numOfChildren;
    end
    
    if currentGeneration < maxGeneration
        nextParents = Selection(fitnessSorted_breed, popSorted_breed, nPop_withoutmax, numOfChildren);
        
        
        %% Cross-Breeding (Reproduction)
        % Pre-allocate memory
        newPopulation = cell(1, maxPopulation);
        CreateChild = @(binaryImage1, binaryImage2, mutationProbability)MergePolygon(binaryImage1, binaryImage2, mutationProbability, numOfMeshes);
        tempCount = 0;
        
        % Choose parents for breeding
        for i = 1:size(nextParents,2)
            parent1 = nextParents{i};
            parent2 = nextParents{end - i + 1};
            
            for j=1:1:numOfChildren
                numOfAttempts = 0;
                tempCount = tempCount + 1;
                
                while true
                    child = CreateChild(parent1, parent2, mutationProbability);
                    
                    % Check for center of gravity
                    % Reconstruct vertices from binary image
                    polygonVertices = ReconstructPolygon(child);
                    % Split vertices of the reconstructed polygon
                    x_vertices = polygonVertices(:,1);
                    y_vertices = polygonVertices(:,2);
                    
                    % Offset the polygon to have a vertex at (0,0)
                    if min(y_vertices) < 0
                        y_vertices = y_vertices + abs(min(y_vertices));
                    else
                        y_vertices = y_vertices - abs(min(y_vertices));
                    end
                    
                    if min(x_vertices) < 0
                        x_vertices = x_vertices + abs(min(x_vertices));
                    else
                        x_vertices = x_vertices - abs(min(x_vertices));
                    end
                    
                    % Find the centroid
                    [x_centroid, ~] = polygoncentroid(x_vertices,y_vertices);
                    
                    % If the centroid falls within the base of the polygon, then it is a balanced polygon
                    CenterOfMass_balanced = nnz(x_centroid >= min(x_vertices(y_vertices == min(y_vertices))) & x_centroid <= max(x_vertices(y_vertices == min(y_vertices))));
                    
                    % Auto-escape condition
                    numOfAttempts = numOfAttempts + 1;
                    
                    if CenterOfMass_balanced == 1  || numOfAttempts == 4
                        break;
                    end
                end
                newPopulation{tempCount+2} = child;
            end
        end
        
        % Input the clone into the newPopulation
        newPopulation{1} = pop_best;
        
        % Fill the rest of newPopulaion with child of self cross-breeding of pop_best
        tempIndex = find(~cellfun(@isempty,newPopulation));
        
        for i = size(tempIndex,2)+1 : maxPopulation
            parent1 = pop_best;
            parent2 = pop_best;
            
            numOfAttempts = 0;
            
            while true
                child = CreateChild(parent1, parent2, mutationProbability);
                
                % Check for center of gravity
                % Reconstruct vertices from binary image
                polygonVertices = ReconstructPolygon(child);
                % Split vertices of the reconstructed polygon
                x_vertices = polygonVertices(:,1);
                y_vertices = polygonVertices(:,2);
                
                % Offset the polygon to have a vertex at (0,0)
                if min(y_vertices) < 0
                    y_vertices = y_vertices + abs(min(y_vertices));
                else
                    y_vertices = y_vertices - abs(min(y_vertices));
                end
                
                if min(x_vertices) < 0
                    x_vertices = x_vertices + abs(min(x_vertices));
                else
                    x_vertices = x_vertices - abs(min(x_vertices));
                end
                
                % Find the centroid
                [x_centroid, ~] = polygoncentroid(x_vertices,y_vertices);
                
                % If the centroid falls within the base of the polygon, then it is a balanced polygon
                CenterOfMass_balanced = nnz(x_centroid >= min(x_vertices(y_vertices == min(y_vertices))) & x_centroid <= max(x_vertices(y_vertices == min(y_vertices))));
                
                % Auto-escape condition
                numOfAttempts = numOfAttempts + 1;
                
                if CenterOfMass_balanced == 1  || numOfAttempts == 4
                    break;
                end
            end
            popIndex = find(cellfun('isempty', newPopulation),1);
            if ~isempty(popIndex)
                newPopulation{popIndex} = child;
            end
        end
        
        % Update population for Genetic Algorithm
        pop_binaryImage = newPopulation;
        % Update best population's fitnessValue
        fitnessValue(1) = fitnessSorted(1);
        
    end
    
    toc
    
    % Display status in command window
    cprintf('*red',['\n----------Completion (%%) = ', num2str(round((currentGeneration/maxGeneration)*100)),' %%----------\n']);
    cprintf('*blue', 'Simulation running; Please do not shutdown\n');
    fprintf("-----------------------------------------------------------------------------------------\n\n");
    
    % Update Generation
    currentGeneration = currentGeneration + 1;
    
end

cprintf('*[0.4,0.8,0.5]', '----------Completion (%%) = 100 %%----------\n');
cprintf('*blue', 'Simulation completed\n');
fprintf("-----------------------------------------------------------------------------------------\n\n");
