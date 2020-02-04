%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Masks the 2D polygon in a static reference plane of size 2*Radius x 2*Radius.
% This will convert the vertices into a solid 2D polygon
% The polygon is meshed over the reference plane and is indicated by logic 1, 
% while the empty area is indicated by logic 0
% 
% Params:
%     Radius      - The average radius of the ellipse inside which the polygon will be plotted
%                   This is obtained from GenerateRegularPolygon.m
%     x,y         - Vertices of the 2D polygon. 
%     binaryImage - Masked image of the 2D polygon. Size: 2*Radius x 2*Radius
%
% Returns binaryImage (1 = area covered by polygon, 0 = uncovered area).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function binaryImage = MaskPolygon(x,y,Radius)
%% Testing purpose only
% clear all;
% 
% Diameter = 1000;
% Radius = Diameter/2;
% Num_of_Vertices = 4;
% Aspect_ratio = 9;
% 
% [x,y] = GenerateRegularPolygon (Radius, Num_of_Vertices, Aspect_ratio);

%% Masking the polygon to form a logical image matrix of size 2*Radius x 2*Radius

adjust_factor = round((Radius) - ((max(x) - min(x))/2));
x = x + adjust_factor;

% Poly2mask is used to make the logical image matrix (or mask matrix)
binaryImage = flip(poly2mask(x,y, 2*Radius, 2*Radius));

%% Testing purpose only
% figure(2)
% imshow(binaryImage);
%%%

end

