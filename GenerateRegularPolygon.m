%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creates a 2D polygon by sampling points on a Ellipse.
%
% Params:
%     aveRadius   - The average radius of the ellipse inside which the polygon will be plotted
%                   This roughly controls how large the polygon will be.
%     numVerts    - Number of vertices of the polygon. 
%     AspectRatio - VerticalAxesLength/HorizontalAxesLength (b/a) of the Ellipse.
%
% Returns a list of vertices as (x,y).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x_vertices, y_vertices] = GenerateRegularPolygon ( aveRadius, numVerts, AspectRatio )

% generate n angle steps
% Make number of angles equal to number of vertices
angleSteps(1:numVerts) = (2*pi / numVerts);

% now generate the points
angle = unifrnd(0, 1);
angle(2:numVerts+1) = angleSteps(1:numVerts);
angle = cumsum(angle); % Incrementing angle per vertex
angle(end) = []; % We wouldnt need the last angle since it is a closed polygon with a flat base

% Using polar cordinate equation for an ellipse
% The AspectRatio variables gives the ratio of a/b where a and b are vertical axis and horizontal radius lengths.
x_vertices = round((1/AspectRatio)*(aveRadius*cos(angle))); 
y_vertices = round(aveRadius*sin(angle));
    
% Close the polygon by making its end vertex = start vertex    
x_vertices(end+1) = x_vertices(1);
y_vertices(end+1) = y_vertices(1);

% Make the base of the polygon flat so that it can stand upright on a surface
index = find(y_vertices==min(y_vertices), 1 );
if index == numVerts
    y_vertices(index-1) = y_vertices(index);
else
    y_vertices(index+1) = y_vertices(index);
end

%% Check for center of gravity
y_vertices = y_vertices - min(y_vertices);

[x_centroid, ~] = polygoncentroid(x_vertices,y_vertices);

CenterOfMass_balanced = nnz(x_centroid >= min(x_vertices(y_vertices == min(y_vertices))) & x_centroid <= max(x_vertices(y_vertices == min(y_vertices))));

% Re-run of the structure's center of gravity does not fall within the base
if CenterOfMass_balanced ~= 1
    GenerateRegularPolygon ( aveRadius, numVerts, AspectRatio )
end

end

%% This function finds the centroid (Center of gravity) of the 2D polygon
function [xc,yc] = polygoncentroid(x,y)
xn = circshift(x,-1);
yn = circshift(y,-1);
A = x.*yn-xn.*y;
a = 3*sum(A);
xc = sum((x+xn).*A)/a;
yc = sum((y+yn).*A)/a;
end