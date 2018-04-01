function compAssignments = GetPixelComponents(GMM_data, Trimap, A,  GMM_fg, GMM_bg)
    [height, width, depth] = size(GMM_data);
    compAssignments = zeros(height, width);
    [compY, compX] = find(Trimap == 1);
    [compYb, compXb] = find(Trimap ~= 1);
    [length, ~] = size(compY);
    [lengthb, ~] = size(compYb);
    for i = 1:length
        mink = -1;
        min = 100000000;
        X = compX(i);
        Y = compY(i);
        for j = 1:5
            [D] = Distance(A(Y,X), j, GMM_fg, GMM_bg, squeeze(GMM_data(Y,X, :)));
            if(D < min)
                mink = j;
                min = D;
            end
        end
        compAssignments(Y, X) = mink;
    end
    %not sure if the following code is needed, this labels all the points
    %that are not trimap 1 incase it is still important later, remove all
    %following to follow the paper more closely
    for i = 1:lengthb
        mink = -1;
        min = 100000000;
        X = compXb(i);
        Y = compYb(i);
        for j = 1:5
            [D] = Distance(A(Y,X), j, GMM_fg, GMM_bg, squeeze(GMM_data(Y,X, :)));
            if(D < min)
                mink = j;
                min = D;
            end
        end
        compAssignments(Y, X) = mink;
    end
end

