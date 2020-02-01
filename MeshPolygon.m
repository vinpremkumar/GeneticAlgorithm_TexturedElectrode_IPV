Radius = 100;
Num_of_Vertices = 4;
Aspect_ratio = 1;

[x,y] = GenerateRegularPolygon (Radius, Num_of_Vertices, Aspect_ratio)

x_spacing = round(linspace(min(x),max(x),6));
y_spacing = round(linspace(max(y),min(y),6));
[X_spacing, Y_spacing] = meshgrid(x_spacing,y_spacing);


%% Plot
plot(x,y,'r-x');
y_AspectRatio = (max(y)- min(y))/(max(x) - min(x));
pbaspect([1 y_AspectRatio 1])
hold on
plot(X_spacing,Y_spacing,'--b',X_spacing',Y_spacing','--b')
hold off

%%
for i = 1:4
    for j = 1:4
        
        index_y = (y <= y_spacing(i) & y > y_spacing(i+2))
        index_x = (x >= x_spacing(j) & x < x_spacing(j+2))
        index = index_y & index_x ;
        
    end
end