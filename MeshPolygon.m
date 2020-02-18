%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mesh the masked polygon into NumOfMeshes x NumOfMeshes.
% The output cell containes the masked matrix values seperated into 
% NumOfMeshes x NumOfMeshes grids.
%
% Parameters:
% Inputs: binaryImage             - Outputs of MaskPolygon function
%         quadrant_PolyMaskValues - Masked polygon values sorted into their 
%                                   respective meshgrids
%
% Output: quadrant_PolyMaskValues - Masked polygon values sorted into their 
%                                   respective meshgrids
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function quadrant_PolyMaskValues = MeshPolygon(binaryImage, NumOfMeshes)
%% Testing purpose only
% Radius = 100;
% Num_of_Vertices = 7;
% Aspect_ratio = 1;
%
% [x,y] = GenerateRegularPolygon (Radius, Num_of_Vertices, Aspect_ratio)

%% Setting mesh grid spacing along x and y axes
% Set the number of grids (NumOfMeshes x NumOfMeshes)
% NumOfMeshes = 4;
spacing = round(linspace(0, size(binaryImage,1), NumOfMeshes+1));

%% Plot (for testing purpose only)
% [X_spacing, Y_spacing] = meshgrid(spacing,spacing);
% plot(x,y,'r-x');
% xlim([spacing(1)+1 spacing(end)])
% ylim([spacing(1)+1 spacing(end)])
% y_AspectRatio = (max(y)- min(y))/(max(x) - min(x));
% pbaspect([1 y_AspectRatio 1])
% hold on
% plot(X_spacing,Y_spacing,'--b',X_spacing',Y_spacing','--b')
% hold off

%% Preallocate memory for cells
quadrant_PolyMaskValues = cell(NumOfMeshes,NumOfMeshes);

%% Place vertices in the specific meshgrid cell

for i = 1:NumOfMeshes
    for j = 1:NumOfMeshes
        
        % Grid Boundaries are calculated
        SpacingIndex_y = spacing(i)+1:1:spacing(i+1);
%         SpacingIndex_y = spacing(NumOfMeshes-i+1)+1:1:spacing(NumOfMeshes-i+2);
        SpacingIndex_x = spacing(j)+1:1:spacing(j+1);
        
        % Input the mask values into the respective grid
        quadrant_PolyMaskValues{i,j} = binaryImage(SpacingIndex_y,SpacingIndex_x);
        
        % Testing purpose only
        
        % Explanation for what is happening in he previous vectorized line
        % for k = SpacingIndex_y
        %   for l = SpacingIndex_x
        %      temp(k-(SpacingIndex_y(1)-1),l) = binaryImage(k,l);
        %   end
        %  end
        %  figure(1)
        %  imshow(flip(temp))
        %  figure(2)
        %  imshow(flip(MaskedValues))
        %
    end
end

end