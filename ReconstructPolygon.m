figure(2)
hold on;
boundaries = bwboundaries(flip(binaryImage));
numberOfBoundaries = size(boundaries, 1);
k = 1 : numberOfBoundaries;
thisBoundary = boundaries{k};
plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
hold off;

figure(3)
plot(x,y);