function [GMM_fg, GMM_bg] = LearnGMMParams(GMM_data, A, K)
    [~, ~, num_data_dimensions] = size(GMM_data);
    num_k = 2;
    %params = [10, 5; 2, 3];
    newMean = zeros(num_k, num_data_dimensions);
    newCovarience = zeros(num_data_dimensions,num_data_dimensions,num_k);
    newProp = zeros(1,num_k);
    for i = 1:num_k % 5 is number of k
        [ky, kx] = find(A == 1 & K ==i);
        [Ay, Ax] = find(A == 1);
        [length, ~] = size(ky);
        [total, ~] = size(Ay);
        kArea = zeros(length,num_data_dimensions);
        for j = 1:length
            kArea(j, :) = GMM_data(ky(j), kx(j), :);
%             kArea(j, 1) = GMM_data(ky(j), kx(j), 1);
%             kArea(j, 2) = GMM_data(ky(j), kx(j), 2);
%             kArea(j, 3) = GMM_data(ky(j), kx(j), 3);
%             kArea(j, 4) = GMM_data(ky(j), kx(j), 4);
%             kArea(j, 5) = GMM_data(ky(j), kx(j), 5);
        end          
        newMean(i, :) = mean(kArea);
        newCovarience(:, : , i) = cov(kArea);
        newProp(1,i) = length/total;
    end
    GMM_fg = gmdistribution(newMean,newCovarience,newProp);
    newMean = zeros(num_k, num_data_dimensions);
    newCovarience = zeros(num_data_dimensions, num_data_dimensions,num_k);
    newProp = zeros(1,num_k);
    for i = 1:num_k % 5 is number of k
        [ky, kx] = find(A == 0 & K ==i);
        [Ay, Ax] = find(A == 0);
        [length, ~] = size(ky);
        [total, ~] = size(Ay);
        kArea = zeros(length,num_data_dimensions);
        for j = 1:length
            kArea(j, :) = GMM_data(ky(j), kx(j), :);
%             kArea(j, 1) = GMM_data(ky(j), kx(j), 1);
%             kArea(j, 2) = GMM_data(ky(j), kx(j), 2);
%             kArea(j, 3) = GMM_data(ky(j), kx(j), 3);
%             kArea(j, 4) = GMM_data(ky(j), kx(j), 4);
%             kArea(j, 5) = GMM_data(ky(j), kx(j), 5);
        end          
        newMean(i, :) = mean(kArea);
        newCovarience(:, : , i) = cov(kArea);
        newProp(1,i) = length/total;
    end
    GMM_bg = gmdistribution(newMean,newCovarience,newProp);
end