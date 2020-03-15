%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reconstructs the polygon as vertices from the binary image.
%
% Parameters:
% Inputs: binaryImage        - Outputs of MaskPolygon function
% 
% Output: newPolygonVertices - x and y vertices of the polygon are the
%                              first and second columns of this variable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function newPolygonVertices = ReconstructPolygon(binaryImage)
%% Find the binary image's boundaries and ignore holes
boundaries = bwboundaries(flip(binaryImage), 4, 'noholes');

%% Plotting the biggest continuous structure only
% Find the biggest continuous structure
boundariesSize =  arrayfun(@(x) size(x{:},1),boundaries);
% Ouput the structure to newPolygonVertices variable
newPolygonVertices = boundaries{boundariesSize == max(boundariesSize)};
% Changing x to first column and y to second column
newPolygonVertices = newPolygonVertices(:,[2,1]);
%% Plot (for testing purpose only)
% figure(6)
% hold on
% plot(newPolygonVertices(:,1), newPolygonVertices(:,2), 'g', 'LineWidth', 2);
% xlim ([0, size(binaryImage,1)])
% ylim ([0, size(binaryImage,1)])
% hold off

%% Setting midpoint to (0,0)
newPolygonVertices(:,1) = newPolygonVertices(:,1)-round((min(newPolygonVertices(:,1))+max(newPolygonVertices(:,1)))/2);

% Dividing vertices by 100 to since it was 100 times bigger for geometry creation purpose.
newPolygonVertices = newPolygonVertices./100;

% Change the units to nm
nm = 10^-9;
newPolygonVertices = newPolygonVertices.*nm;

% % Reducing the number of vertices using polyshape
% polyshapePolygon = polyshape(PolygonVertices(:,1), PolygonVertices(:,2));
% 
% newPolygonVertices = polyshapePolygon.Vertices;

%% Testing for structures with holes (for testing purpose only)
% figure(7)
% hold on
% boundaries = bwboundaries(flip(binaryImage));
% arrayfun(@(x) plot(x{:}(:,2),x{:}(:,1)),boundaries)
% xlim ([0, size(binaryImage,1)])
% ylim ([0, size(binaryImage,1)])
% % end
% hold off

end