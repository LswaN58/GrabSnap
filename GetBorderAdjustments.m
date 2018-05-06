function curMask = GetBorderAdjustments(alpha_map,orig_img)
%GETBORDERADJUSTMENTS Summary of this function goes here
%   Detailed explanation goes here
    %img = imread('Presentation_Images/Bird_Alphas/Bird_alpha6.jpg');
    %orig_img = imread('Test_Images/bird_test.jpg');
    %Kaverage = filter2(fspecial('average',3),img)/255;
    BW = im2bw(alpha_map, .6);
    BW2 = bwareaopen(BW, 80);
    %imshow(BW2);
    %T = edge(BW2, 'Canny');
    %T = InitializeTrimap(img);
    B = bwboundaries(BW2);
    imshow(orig_img)
    %imshow(BW)
    w = length(B);
    curMask = [];
    for k = 1:w
        boundary = B{k};
        if size(boundary,1) >20
            corrected = [boundary(:,2), boundary(:, 1)];
            h = impoly(gca, corrected(1:10:end, :));
            pos = wait(h);
            mask = h.createMask();
            if k == 1
                curMask = mask;
            else
                curMask = xor(curMask, mask);
            end
            imshow(orig_img)
        end
    end
    %imshow((double(orig_img)/255 .* double(curMask)) + 0.5 * double(~curMask))
end

