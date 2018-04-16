function [ GMM_data ] = ConvertImDataToGMMData( img )
    [sizeY, sizeX, ~] = size(img);
    [X,Y] = meshgrid(1:sizeX,1:sizeY);
    GMM_data = cat(3, img, (X/sizeX * 255), (Y/sizeY * 255));
    %GMM_data = img;
end

