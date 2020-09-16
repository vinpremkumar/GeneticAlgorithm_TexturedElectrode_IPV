%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Merges two binary images into 1 image.
% A random binary matrix of size numOfMeshes x numOfMeshes is created to
% indicate which section of the 2 binary images are chosen for making the
% final merged image.
% This is the reproduction/cross-over section for Genetic Algorithm.
%
% Parameters:
% Inputs: parent1            - First binary image and dBetweenGratings
%         parent2            - Second binary image and dBetweenGratings
%         mutationProability - In GA, a probability of mutation is
%                             introduced in the cross over step.
%                             One of the random binary matrix's value is
%                             switched if mutationProbability condition is
%                             satisfied
%         numOfMeshes        - Decides how the binaryImages are partitioned
%         Radius             - Radius of the circle within which the random
%                              polygon is generated
%
% Output: mergedImage        - Output binary image and distance between
%                              gratings of the polygon created from
%                              binaryImages 1 and 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mergedImage = MergePolygon(parent1, parent2, mutationProbability, numOfMeshes, Radius)
yes_mutation = 0;
maxImageSize = max(size(parent1.binaryImage,2), size(parent2.binaryImage,1));

%% MeshSpacing
spacing = round(linspace(0, maxImageSize, numOfMeshes+1));

%% Obtain both the meshed polygons
quadrant_PolyMaskValues1 = MeshPolygon(parent1.binaryImage, numOfMeshes);
quadrant_PolyMaskValues2 = MeshPolygon(parent2.binaryImage, numOfMeshes);

%% Create a randomized matrix of size NumOfMeshes x NumOfMeshes
RandomizedImageMergerMatrix = randi([0 1],numOfMeshes,numOfMeshes);

%% Find new distance between gratings
numOfBits = length(de2bi(max(parent1.dBetweenGratings, parent2.dBetweenGratings)));
parent1_bin.dBetweenGratings = de2bi(round(parent1.dBetweenGratings), numOfBits);
parent2_bin.dBetweenGratings = de2bi(round(parent2.dBetweenGratings), numOfBits);

% Pre-allocation of memory
child_bin.dBetweenGratings = zeros(1, numOfBits);

% Random array of 1s and 0s
% 1 = parent1 and 0 = parent2
RandomizedGratingDistaneMatrix = randi([0 1], 1 ,numOfBits);

% Find the indexes where matrix value is 1 and 0
index_dBG1 = find(RandomizedGratingDistaneMatrix == 1);
index_dBG2 = find(RandomizedGratingDistaneMatrix ~= 1);

child_bin.dBetweenGratings(index_dBG1) = parent1_bin.dBetweenGratings(index_dBG1);
child_bin.dBetweenGratings(index_dBG2) = parent2_bin.dBetweenGratings(index_dBG2);

%% Mutation
% Change 1 bit in RadomizedMatrix if rand() < mutationProbability
if rand() < mutationProbability
    yes_mutation = 1;
    
    i = randi([1, numel(RandomizedImageMergerMatrix)]);
    RandomizedImageMergerMatrix(i)  = RandomizedImageMergerMatrix(i)+2;
    
    j = randi([1, numel(RandomizedGratingDistaneMatrix)]);
    child_bin.dBetweenGratings(j) = ~child_bin.dBetweenGratings(j);
    
    % Generate a new random polygon to use for mutation gene
    numVerts                = randi([3 14], 1);
    if numVerts > 12 % Limiting too many rounded structures
        numVerts            = 35;
    end
    AspectRatio             = randi([1 12], 1)*25/100;
    [x, y]                  = GenerateRegularPolygon (Radius, numVerts, AspectRatio);
    mutantBinaryImage = MaskPolygon(x,y,Radius);
    quadrant_MutantPolyMask = MeshPolygon(mutantBinaryImage, numOfMeshes);
end

%% Child dBetweenGratings
mergedImage.dBetweenGratings           = bi2de(child_bin.dBetweenGratings);

%% Merge Image
% Find the indexes where matrix value is 1 and 0
index_Image1          = find(RandomizedImageMergerMatrix == 1);
index_Image2          = find(RandomizedImageMergerMatrix == 0);
if yes_mutation == 1
    index_MutantImage = find(RandomizedImageMergerMatrix  > 1);
end
% Initialize a temporary mergedImage.binaryImage size
temp_MergedImage = cell(numOfMeshes,numOfMeshes);

% Place the Image 1 and 2's binary matrix values into the assigned meshgrid
% according to the RandomizedMatrix
for i = 1: size(index_Image1,1)
    temp_MergedImage{index_Image1(i)} =  quadrant_PolyMaskValues1{index_Image1(i)};
end

for i = 1: size(index_Image2,1)
    temp_MergedImage{index_Image2(i)} =  quadrant_PolyMaskValues2{index_Image2(i)};
end

if yes_mutation == 1
    for i = 1: size(index_MutantImage,1)
        temp_MergedImage{index_MutantImage(i)} =  quadrant_MutantPolyMask{index_MutantImage(i)};
    end
end

% Initialize final mergedImage.binaryImage
mergedImage.binaryImage = false(spacing(end),spacing(end));

% Merge the Image into one image
spacingDistance = spacing(2);
for i = 1:numOfMeshes
    xSpacing = spacing(i);
    for j = 1:numOfMeshes
        ySpacing = spacing(j);
        [indexX,indexY]=meshgrid(1:spacingDistance,1:spacingDistance);
        mergedImage.binaryImage(indexX(1,:)+xSpacing,indexY(:,1)+ySpacing) = temp_MergedImage{i,j};
    end
end


%% Plot mergedImage.binaryImage
% figure(1)
% imshow(mergedImage.binaryImage)

end