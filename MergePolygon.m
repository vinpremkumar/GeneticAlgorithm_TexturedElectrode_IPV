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
%
% Output: mergedImage        - Output binary image and distance between
%                              gratings of the polygon created from
%                              binaryImages 1 and 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mergedImage = MergePolygon(parent1, parent2, mutationProbability, numOfMeshes)
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
    i = randi([1, numel(RandomizedImageMergerMatrix)]);
    RandomizedImageMergerMatrix(i)  = ~RandomizedImageMergerMatrix(i);
    j = randi([1, numel(RandomizedGratingDistaneMatrix)]);
    child_bin.dBetweenGratings(j) = ~child_bin.dBetweenGratings(j);
end

%% Child dBetweenGratings
mergedImage.dBetweenGratings           = bi2de(child_bin.dBetweenGratings);

%% Merge Image
% Find the indexes where matrix value is 1 and 0
Index_Image1 = find(RandomizedImageMergerMatrix == 1);
Index_Image2 = find(RandomizedImageMergerMatrix ~= 1);

% Initialize a temporary mergedImage.binaryImage size
temp_MergedImage = cell(numOfMeshes,numOfMeshes);

% Place the Image 1 and 2's binary matrix values into the assigned meshgrid
% according to the RandomizedMatrix
for i = 1: size(Index_Image1,1)
    temp_MergedImage{Index_Image1(i)} =  quadrant_PolyMaskValues1{Index_Image1(i)};
end

for i = 1: size(Index_Image2,1)
    temp_MergedImage{Index_Image2(i)} =  quadrant_PolyMaskValues2{Index_Image2(i)};
end

%% Make binaryImage 1 and 2 same size as maxImageSize
for i = 1: numOfMeshes*numOfMeshes
    if(size(temp_MergedImage{i},1) ~= maxImageSize)
        temp_MergedImage{i}(end+1:maxImageSize,end+1:maxImageSize) = 0;
    end
end

% Initialize final mergedImage.binaryImage
mergedImage.binaryImage = false(spacing(end),spacing(end));

% Merge the Image into one image
for i = 1:numOfMeshes
    for j = 1:numOfMeshes
        for k = 1:spacing(2)
            for l = 1:spacing(2)
                mergedImage.binaryImage(k+spacing(i),l+spacing(j)) = temp_MergedImage{i,j}(k,l);
            end
        end
        
    end
end

%% Plot mergedImage.binaryImage
% figure(1)
% imshow(mergedImage.binaryImage)

end