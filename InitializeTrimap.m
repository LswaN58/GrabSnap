function trimap = InitializeTrimap(img)
    rect=getrect                           % select rectangle

    [height, width, depth] = size(img);
    trimap = zeros(height, width);
    trimap(round(rect(2)):round(rect(2)+rect(4)), round(rect(1)):round(rect(1)+rect(3))) = 1;
    figure;
    imshow(trimap);

    figure;
    I2=imcrop(img,rect);
    imshow(I2)
end