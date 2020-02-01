%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creates the polygon by sampling points on a Ellipse.
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
angleSteps(1:numVerts) = (2*pi / numVerts);

% now generate the points
angle = unifrnd(0, 1);
angle(2:numVerts+1) = angleSteps(1:numVerts);
angle = cumsum(angle);
angle(end) = [];

x_vertices = round((1/AspectRatio)*(aveRadius*cos(angle)));
y_vertices = round(aveRadius*sin(angle));
    
    
x_vertices(end+1) = x_vertices(1);
y_vertices(end+1) = y_vertices(1);

index = find(y_vertices==min(y_vertices), 1 );
if index == numVerts
    y_vertices(index-1) = y_vertices(index);
else
    y_vertices(index+1) = y_vertices(index);
end

y_vertices = y_vertices - min(y_vertices);

[x_centroid, ~] = polygoncentroid(x_vertices,y_vertices);

CenterOfMass_balanced = nnz(x_centroid >= min(x_vertices(y_vertices == min(y_vertices))) & x_centroid <= max(x_vertices(y_vertices == min(y_vertices))));
if CenterOfMass_balanced == 1
    fprintf("\nBalanced structure\n");
else
    fprintf("\nUnBalanced structure\n");
end

end

function output =  clip(x, min, max)
if min > max
    output = x;
elseif x < min
    output = min;
elseif x > max
    output = max;
else
    output = x;
end
end

function [xc,yc] = polygoncentroid(x,y)
xn = circshift(x,-1);
yn = circshift(y,-1);
A = x.*yn-xn.*y;
a = 3*sum(A);
xc = sum((x+xn).*A)/a;
yc = sum((y+yn).*A)/a;
end