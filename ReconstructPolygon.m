function thisBoundary = ReconstructPolygon(binaryImage)

figure(6)
hold on
boundaries = bwboundaries(flip(binaryImage));
numberOfBoundaries = size(boundaries, 1);
% for k = 1 : numberOfBoundaries
% thisBoundary = boundaries{k};
% plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
arrayfun(@(x) plot(x{:}(:,2),x{:}(:,1)),boundaries)
xlim ([0, size(binaryImage,1)])
ylim ([0, size(binaryImage,1)])
% end
hold off
end