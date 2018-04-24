function [Dis, K] = MinimumDistance(GMM, imgPixel)
% Takes a list of pixels (each column is a pixel, rows are RGB).
% Returns a row vector of minimum distances to a component in given GMM.
    w = GMM.NumComponents;
    num_pix = size(imgPixel, 2);
    D = zeros(w, num_pix, 'double');
    for i = 1:w;
        a = Distance(i,GMM, imgPixel)';
        D(i, :) = a;
    end
    [Dis, K] = min(D);
end

