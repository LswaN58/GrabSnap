function [ GMM_data ] = ConvertImDataToGMMData( img )
    [sizeY, sizeX, ~] = size(img);
    [X,Y] = meshgrid(1:sizeX,1:sizeY);
    GMM_data = cat(img, X, Y);
end

