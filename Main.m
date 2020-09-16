clearvars;
close all;
clc;

% When polygons are merged, the 2 polygons are first slipt into
% numOfMeshes x numOfMeshes and when mixed to make a new polygon.
numOfMeshes = 4;

%% Generic Algorithm's paramteres
maxPopulation       = 50;
maxGeneration       = 100;
mutationProbability = 0.1;
numOfChildren       = 2;

currentGeneration = 0;
rng('shuffle');

%% Input the radius in which polygon is created (Unit: nm)
                                                     %%%%%%%%%%%%%%%%%%%%%%%
                                                     % Enter circle radius %
inputDiameter = 350;                                 %   within which the  %
                                                     %  random polygon is  %
sizingFactor  = 10;                                  %       created       %
Radius        = ((inputDiameter/2) * sizingFactor);  %%%%%%%%%%%%%%%%%%%%%%%

%% Pre-allocation of memory
x = cell(1, maxPopulation);
y = cell(1, maxPopulation);

population.binaryImage  = cell(1, maxPopulation);
fitnessValue            = zeros(1,maxPopulation);
popBreed.binaryImage    = cell(1,maxPopulation-1);

%% If maxGeneration hasn't reached yet, run the simulation
while currentGeneration <= maxGeneration
    tStart = tic;
    
    if currentGeneration == 0
        %% Polygon parameter initilization
        numVerts                    = randi([3 14], 1, maxPopulation);
        vertIndex                   = find(numVerts > 12); % Limiting too many rounded structures
        numVerts(vertIndex)         = 35;
        AspectRatio                 = randi([1 12], 1, maxPopulation)*25/100;
        population.dBetweenGratings = randi([1 40], 1, maxPopulation) * 50;
        
        %% Creating initial population
        for i = 1:maxPopulation
            
            % Generate random convex polygons
            [x{i},y{i}] = GenerateRegularPolygon (Radius, numVerts(i), AspectRatio(i));
            
            % Obtain binary image of the polygons
            population.binaryImage{i} = MaskPolygon(x{i},y{i},Radius);
            
            %     figure(i)
            %     imshow(binaryImage{i});
        end
        %% Calculate the Fitness
        for i = 1:maxPopulation
            fitnessValue(i) = FitnessFunction (population.dBetweenGratings(i), population.binaryImage{i}, sizingFactor);
            
            % For testing purpose only
            % fitnessValue(i) = rand(1);
        end
    else
        for i = 2:maxPopulation
            fitnessValue(i) = FitnessFunction (population.dBetweenGratings(i), population.binaryImage{i}, sizingFactor);
            
            % For testing purpose only
            % fitnessValue(i) = rand(1);
        end
    end
    
    % Display currentGeneration and fitnessValue in command window
    fprintf('Current Generation = %d\n', currentGeneration);
        
    % Rank the population by their fitnessValue (minimization problem)
    [fitnessSorted, fitIndex] = sort(fitnessValue, 'ascend');
    
    fmt=['Fitness values:\n' repmat(' %.2f',1,numel(fitnessSorted))];
    fprintf(fmt,fitnessSorted);
    
    %% Sorting population (binary image and distance between gratings) according to rank
    % popSorted.binaryImage is the sorted binaryImage population
    popSorted.binaryImage = population.binaryImage;
    for i = 1:size(popSorted.binaryImage,2)
        popSorted.binaryImage{2,i} = fitIndex(i);
    end
    popSorted.binaryImage = popSorted.binaryImage';
    popSorted.binaryImage = sortrows(popSorted.binaryImage,2);
    popSorted.binaryImage = popSorted.binaryImage';
    popSorted.binaryImage(2,:) = [];
    
    % popSorted.dBetweenGratings
    popSorted.dBetweenGratings = population.dBetweenGratings(fitIndex);
    
    %% Cloninng the best specimen as a backup of best specimen
    popBest.binaryImage      = popSorted.binaryImage{1};
    popBest.dBetweenGratings = popSorted.dBetweenGratings(1);
    
    %% Replacing the worst specimen by the cloned best specimen
    popSorted.binaryImage{end}      = [];
    popSorted.binaryImage{end}      = popBest.binaryImage;
    
    popSorted.dBetweenGratings(end) = popBest.dBetweenGratings;
    % Shifting the last element to the first since it was replaced by the best specimen
    popSorted.binaryImage           = circshift(popSorted.binaryImage,[2,1]);
    popSorted.dBetweenGratings      = circshift(popSorted.dBetweenGratings,[2,1]);
     
    %% Save the best specimen
    path = pwd;
    
    filenamePoly            = strcat(path,'\Results\Polygons\Gen',int2str(currentGeneration),'.txt');
    polyBest                = ReconstructPolygon(popBest.binaryImage, sizingFactor);
    save(filenamePoly, 'polyBest', '-ascii');
    
    filenamedBetweenGratings = strcat(path,'\Results\dBetweenGratings\Gen',int2str(currentGeneration),'.txt');
    dBetweenGratingsBest     = popBest.dBetweenGratings;
    save(filenamedBetweenGratings, 'dBetweenGratingsBest' , '-ascii');
    
    %% Selection
    % Make population to be used for selection
    for i = 2 : size(popSorted.binaryImage,2)
        popBreed.binaryImage{i-1} = popSorted.binaryImage{i};
    end
    
    popBreed.dBetweenGratings = popSorted.dBetweenGratings(2:end);
    fitnessBreed              = fitnessSorted(2:end);
    
    % Even number of population is required to be input for selection
    if(mod(maxPopulation,2))
        nPop_withoutmax = maxPopulation - (numOfChildren - 1);
    else
        nPop_withoutmax = maxPopulation - numOfChildren;
    end
    
    if currentGeneration < maxGeneration
        nextParents = Selection(fitnessBreed, popBreed, nPop_withoutmax, numOfChildren);
        
        %% Cross-Breeding (Reproduction)
        % Pre-allocate memory
        newPopulation.binaryImage      = cell(1, maxPopulation);
        newPopulation.dBetweenGratings = zeros(1, maxPopulation);
        % Function handle CreateChild for MergePolygon
        CreateChild = @(parent1, parent2)MergePolygon(parent1, parent2, mutationProbability, numOfMeshes, Radius);
        tempCount   = 0;
        
        % Choose parents for breeding
        for i = 1:size(nextParents.binaryImage,2)
            parent1.binaryImage      = nextParents.binaryImage{i};
            parent1.dBetweenGratings = nextParents.dBetweenGratings(i);
            parent2.binaryImage      = nextParents.binaryImage{end - i + 1};
            parent2.dBetweenGratings = nextParents.dBetweenGratings(end - i + 1);
            
            for j=1:1:numOfChildren
                numOfAttempts = 0;
                tempCount = tempCount + 1;
                
                while true
                    child = CreateChild(parent1, parent2);
                    
                    % Check for center of gravity
                    % Reconstruct vertices from binary image
                    polygonVertices = ReconstructPolygon(child.binaryImage, sizingFactor);
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
                newPopulation.binaryImage{tempCount+1}      = child.binaryImage;
                newPopulation.dBetweenGratings(tempCount+1) = child.dBetweenGratings;
            end
        end
        
        % Input the clone into the newPopulation
        newPopulation.binaryImage{1}      = popBest.binaryImage;
        newPopulation.dBetweenGratings(1) = popBest.dBetweenGratings;
        
        % Fill the rest of newPopulaion with child of self cross-breeding of pop_best
        tempIndex = find(~cellfun(@isempty,newPopulation.binaryImage));
        
        for i = size(tempIndex,2)+1 : maxPopulation
            parent1.binaryImage      = popBest.binaryImage;
            parent1.dBetweenGratings = popBest.dBetweenGratings;
            parent2                  = parent1;
            
            numOfAttempts = 0;
            
            while true
                child = CreateChild(parent1, parent2);
                
                % Check for center of gravity
                % Reconstruct vertices from binary image
                polygonVertices = ReconstructPolygon(child.binaryImage, sizingFactor);
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
            
            popIndex = find(cellfun('isempty', newPopulation.binaryImage),1);
            if ~isempty(popIndex)
                newPopulation.binaryImage{popIndex}      = child.binaryImage;
                newPopulation.dBetweenGratings(popIndex) = child.dBetweenGratings;
            end
        end
        
        % Update population for Genetic Algorithm
        population.binaryImage      = newPopulation.binaryImage;
        population.dBetweenGratings = newPopulation.dBetweenGratings;
        % Update best population's fitnessValue
        fitnessValue(1) = fitnessSorted(1);
        
    end
    
    % Elapsed time
    tEnd = toc(tStart);
    fprintf('\nElapsed time is %d minutes and %f seconds', floor(tEnd/60), rem(tEnd,60));
    
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

diary outputfile
