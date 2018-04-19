function [Dis, K] = MinimumDistance(GMM, imgPixel)
%MINIMUMDISTANCE Summary of this function goes here
%   Detailed explanation goes here
    w = GMM.NumComponents;
    D = zeros(w, 1, 'double');
    for i = 1:w;
        a = Distance(i,GMM, imgPixel);
        D(i, 1) = a;
    end
    [Dis, K] = min(D);
end

