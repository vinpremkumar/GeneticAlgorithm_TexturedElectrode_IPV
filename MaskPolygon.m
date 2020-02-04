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
figure(2)
imshow(binaryImage);
%%


end

