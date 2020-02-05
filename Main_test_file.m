clear all;
close all
clc

Radius = 1000;
numVerts = 11;
AspectRatio = 2;
NumOfMeshes = 4;
[x1,y1] = GenerateRegularPolygon ( Radius, numVerts, AspectRatio );
[x2,y2] = GenerateRegularPolygon ( Radius, 7, 1 );


binaryImage1 = MaskPolygon(x1,y1,Radius);
binaryImage2 = MaskPolygon(x2,y2,Radius);

figure(8)
imshow(binaryImage1);
figure(9)
imshow(binaryImage2);

spacing = round(linspace(0, size(binaryImage1,1), NumOfMeshes+1));

%% Plot (for testing purpose only)
[X_spacing1, Y_spacing1] = meshgrid(spacing,spacing);
adjust_factor = round((Radius) - ((max(x1) - min(x1))/2));
x1 = x1 + adjust_factor;
figure(10)
plot(x1,y1,'r-x');
xlim([spacing(1)+1 spacing(end)])
ylim([spacing(1)+1 spacing(end)])
y_AspectRatio = (max(y1)- min(y1))/(max(x1) - min(x1));
pbaspect([1 y_AspectRatio 1])
hold on
plot(X_spacing1,Y_spacing1,'--b',X_spacing1',Y_spacing1','--b')
hold off

[X_spacing2, Y_spacing2] = meshgrid(spacing,spacing);
adjust_factor = round((Radius) - ((max(x2) - min(x2))/2));
x2 = x2 + adjust_factor;
figure(11)
plot(x2,y2,'r-x');
xlim([spacing(1)+1 spacing(end)])
ylim([spacing(1)+1 spacing(end)])
y_AspectRatio = (max(y2)- min(y2))/(max(x2) - min(x2));
pbaspect([1 y_AspectRatio 1])
hold on
plot(X_spacing2,Y_spacing2,'--b',X_spacing2',Y_spacing2','--b')
hold off

quadrant_PolyMaskValues1 = MeshPolygon(binaryImage1);
quadrant_PolyMaskValues2 = MeshPolygon(binaryImage2);

RandomizedMatrix = randi([1 2],NumOfMeshes,NumOfMeshes);

Index_Image1 = find(RandomizedMatrix == 1);
Index_Image2 = find(RandomizedMatrix ~= 1);

temp_MergedImage = cell(NumOfMeshes,NumOfMeshes);
for i = 1: size(Index_Image1,1)
    temp_MergedImage{Index_Image1(i)} =  quadrant_PolyMaskValues1{Index_Image1(i)};
end

for i = 1: size(Index_Image2,1)
    temp_MergedImage{Index_Image2(i)} =  quadrant_PolyMaskValues2{Index_Image2(i)};
end


MergedImage = false(spacing(end),spacing(end));
temp_count = 0;

for i = 1:NumOfMeshes
    for j = 1:NumOfMeshes
        
        % Grid Boundaries are calculated
%         SpacingIndex_y = spacing(i)+1:1:spacing(i+1);
        SpacingIndex_y = spacing(NumOfMeshes-i+1)+1:1:spacing(NumOfMeshes-i+2);
        SpacingIndex_x = spacing(j)+1:1:spacing(j+1);
        
%         MergedImage(SpacingIndex_y,SpacingIndex_x) = temp_MergedImage{i,j};
                
        for k = 1:spacing(2)
           for l = 1:spacing(2)
             MergedImage(k+spacing(i),l+spacing(j)) = temp_MergedImage{i,j}(k,l);
          end
         end
        
    end
end

figure(1)
imshow(MergedImage)

PolygonVertices = ReconstructPolygon(MergedImage);