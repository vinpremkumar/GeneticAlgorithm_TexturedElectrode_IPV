%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function finds the centroid (Center of gravity) of the 2D polygon
% 
% It was answered by Bruno Luong to a question in Mathworks's forum
% Link: https://www.mathworks.com/matlabcentral/answers/469852-how-do-i-find-the-centre-of-gravity-for-an-irregular-shape#answer_383244
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xc,yc] = polygoncentroid(x,y)
xn = circshift(x,-1);
yn = circshift(y,-1);
A = x.*yn-xn.*y;
a = 3*sum(A);
xc = sum((x+xn).*A)/a;
yc = sum((y+yn).*A)/a;
end