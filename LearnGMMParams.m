function [GMM_fg, GMM_bg] = LearnGMMParams(GMM_data, A, K)
    %warning('STUB! LearnGMMParams returns a hardcoded matrix, not actual parameters.')
    %params = [10, 5; 2, 3];
    newMean = zeros(5, 5);
    newCovarience = zeros(5,5,5);
    newProp = zeros(1,5);
    for i = 1:5 % 5 is number of k
        [ky, kx] = find(A == 1 & K ==i);
        [Ay, Ax] = find(A == 1);
        [length, ~] = size(ky);
        [total, ~] = size(Ay);
        kArea = zeros(length,5);
        for j = 1:length
            kArea(j, 1) = GMM_data(ky(j), kx(j), 1);
            kArea(j, 2) = GMM_data(ky(j), kx(j), 2);
            kArea(j, 3) = GMM_data(ky(j), kx(j), 3);
            kArea(j, 4) = GMM_data(ky(j), kx(j), 4);
            kArea(j, 5) = GMM_data(ky(j), kx(j), 5);
        end          
        newMean(i, :) = mean(kArea);
        newCovarience(:, : , i) = cov(kArea);
        newProp(1,i) = length/total;
    end
    GMM_fg = gmdistribution(newMean,newCovarience,newProp);
    newMean = zeros(5, 5);
    newCovarience = zeros(5,5,5);
    newProp = zeros(1,5);
    for i = 1:5 % 5 is number of k
        [ky, kx] = find(A == 0 & K ==i);
        [Ay, Ax] = find(A == 0);
        [length, ~] = size(ky);
        [total, ~] = size(Ay);
        kArea = zeros(length,5);
        for j = 1:length
            kArea(j, 1) = GMM_data(ky(j), kx(j), 1);
            kArea(j, 2) = GMM_data(ky(j), kx(j), 2);
            kArea(j, 3) = GMM_data(ky(j), kx(j), 3);
            kArea(j, 4) = GMM_data(ky(j), kx(j), 4);
            kArea(j, 5) = GMM_data(ky(j), kx(j), 5);
        end          
        newMean(i, :) = mean(kArea);
        newCovarience(:, : , i) = cov(kArea);
        newProp(1,i) = length/total;
    end
    GMM_bg = gmdistribution(newMean,newCovarience,newProp);
end