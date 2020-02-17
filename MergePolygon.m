%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Merges two binary images into 1 image.
% A random binary matrix of size numOfMeshes x numOfMeshes is created to
% indicate which section of the 2 binary images are chosen for making the
% final merged image.
% This is the reproduction/cross-over section for Genetic Algorithm.
%
% Parameters:
% Inputs: binaryImage 1      - First binary image
%         binaryImage 2      - Second binary image
%         mutationProability - In GA, a probability of mutation is
%                             introduced in the cross over step.
%                             One of the random binary matrix's value is
%                             switched if mutationProbability condition is
%                             satisfied
%         numOfMeshes        - Decides how the binaryImages are partitioned
% 
% Output: mergedImage        - Output binary image of the polygon created 
%                              from binaryImages 1 and 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mergedImage = MergePolygon(binaryImage1, binaryImage2, mutationProbability, numOfMeshes)
maxImageSize = max(size(binaryImage1,2), size(binaryImage2,1));

%% MeshSpacing
spacing = round(linspace(0, maxImageSize, numOfMeshes+1));

%% Obtain both the meshed polygons
quadrant_PolyMaskValues1 = MeshPolygon(binaryImage1, numOfMeshes);
quadrant_PolyMaskValues2 = MeshPolygon(binaryImage2, numOfMeshes);

%% Create a randomized matrix of size NumOfMeshes x NumOfMeshes
RandomizedMatrix = randi([0 1],numOfMeshes,numOfMeshes);

%% Mutation
% Change 1 bit in RadomizedMatrix if rand() < mutationProbability
if rand() < mutationProbability
    i = randi([1, numel(RandomizedMatrix)]);
    RandomizedMatrix(i) = ~RandomizedMatrix(i);
end
    
% Find the indexes where matrix value is 1 and 0
Index_Image1 = find(RandomizedMatrix == 1);
Index_Image2 = find(RandomizedMatrix ~= 1);

%% Merge Image
% Initialize a temporary MergedImage size
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

% Initialize final MergedImage
mergedImage = false(spacing(end),spacing(end));

% Merge the Image into one image
for i = 1:numOfMeshes
    for j = 1:numOfMeshes
        for k = 1:spacing(2)
            for l = 1:spacing(2)
                mergedImage(k+spacing(i),l+spacing(j)) = temp_MergedImage{i,j}(k,l);
            end
        end
        
    end
end

%% Plot MergedImage
% figure(1)
% imshow(MergedImage)

end