%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mesh the 2D polygon into NumOfMeshes x NumOfMeshes.
% The output cells containes vertices in each mesh box.
% 
% Params:
%     x,y                 - Outputs of GenerateRegularPolygon function.
%     quadrant_x_vertices - x vertices sorted into their respective meshgrids. 
%     quadrant_y_vertices - y vertices sorted into their respective meshgrids.
%
% Returns cells as [quadrant_x_vertices, quadrant_y_vertices] which contain 
% the x and y vertices sorted into their respective meshgrids.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [quadrant_x_vertices, quadrant_y_vertices] = MeshPolygon(x,y)
%% Testing purpose only
% Radius = 100;
% Num_of_Vertices = 7;
% Aspect_ratio = 1;
%
% [x,y] = GenerateRegularPolygon (Radius, Num_of_Vertices, Aspect_ratio)

%% Setting mesh grid spacing along x and y axes
x_spacing = round(linspace(min(x),max(x),6));
y_spacing = round(linspace(max(y),min(y),6));

%% Plot (for testing purpose only)
[X_spacing, Y_spacing] = meshgrid(x_spacing,y_spacing);
plot(x,y,'r-x');
y_AspectRatio = (max(y)- min(y))/(max(x) - min(x));
pbaspect([1 y_AspectRatio 1])
hold on
plot(X_spacing,Y_spacing,'--b',X_spacing',Y_spacing','--b')
hold off

%% Allocate vertices their grid cell location
% Delete the last vertex as it is same as the first vertex
x(end) = [];
y(end) = [];

% Set the number of grids (NumOfMeshes x NumOfMeshes)
NumOfMeshes = 5;

% Preallocate memory for cells
quadrant_x_vertices = cell(NumOfMeshes,NumOfMeshes);
quadrant_y_vertices = cell(NumOfMeshes,NumOfMeshes);

% Place vertices in the specific meshgrid cell
for i = 1:NumOfMeshes
    for j = 1:NumOfMeshes
        
        if (i == 1 || i == NumOfMeshes) && (j == 1 || j == NumOfMeshes)
            index_y = (y <= y_spacing(i) & y >= y_spacing(i+1));
            index_x = (x >= x_spacing(j) & x <= x_spacing(j+1));
            index = index_y & index_x ;
            
            
        elseif  i == NumOfMeshes || j == NumOfMeshes
            index_y = (y < y_spacing(i) & y >= y_spacing(i+1));
            index_x = (x > x_spacing(j) & x <= x_spacing(j+1));
            index = index_y & index_x ;
        else
            index_y = (y <= y_spacing(i) & y > y_spacing(i+1));
            index_x = (x >= x_spacing(j) & x < x_spacing(j+1));
            index = index_y & index_x ;
        end
        
        quadrant_x_vertices{i,j} = x(index);
        quadrant_y_vertices{i,j} = y(index);
        
    end
end

end