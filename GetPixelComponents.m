function compAssignments = GetPixelComponents(GMM_data, Trimap, A,  GMM_fg, GMM_bg)
    disp('In pix comps, started init')
    tic
    [height, width, ~] = size(GMM_data);
    compAssignments = zeros(height, width);
    [compY, compX] = find(Trimap == 1);
    [compYb, compXb] = find(Trimap ~= 1);
    [length, ~] = size(compY);
    [lengthb, ~] = size(compYb);
    toc
    disp('In pix comps, started assignment loop')
    tic
    for i = 1:length
        mink = -1;
        min = 100000000;
        X = compX(i);
        Y = compY(i);
        if(A(Y,X) == 0)
            theta = GMM_bg;
        else
            theta = GMM_fg;
        end
        for j = 1:theta.NumComponents
            [D] = Distance(j, theta, squeeze(GMM_data(Y,X, :)));
            if(D < min)
                mink = j;
                min = D;
            end
        end
        compAssignments(Y, X) = mink;
    end
    toc
    %not sure if the following code is needed, this labels all the points
    %that are not trimap 1 incase it is still important later, remove all
    %following to follow the paper more closely
    disp('In pix comps, started loop that isn''t known if it''s needed or not.')
    tic
    for i = 1:lengthb
        mink = -1;
        min = 100000000;
        X = compXb(i);
        Y = compYb(i);
        if(A(Y,X) == 0)
            theta = GMM_bg;
        else
            theta = GMM_fg;
        end
        for j = 1:theta.NumComponents
            [D] = Distance(j, theta, squeeze(GMM_data(Y,X, :)));
            if(D < min)
                mink = j;
                min = D;
            end
        end
        compAssignments(Y, X) = mink;
    end
    toc
end

