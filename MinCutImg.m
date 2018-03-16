function [energy, cut] = MinCutImg(img, GMM_fg, GMM_bg)
    warning('STUB! MinCutImg puts all pixels in foreground.')
    energy = 100;
    [height, width, depth] = size(img);
    cut = ones(height, width);
end