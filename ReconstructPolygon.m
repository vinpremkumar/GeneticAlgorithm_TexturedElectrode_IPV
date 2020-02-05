function thisBoundary = ReconstructPolygon(binaryImage)

figure(6)
hold on
boundaries = bwboundaries(flip(binaryImage),4,'holes');
numberOfBoundaries = size(boundaries, 1);
for k = 1 : numberOfBoundaries;
thisBoundary = boundaries{k};
plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
end
hold off
end