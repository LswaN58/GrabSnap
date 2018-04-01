function [] = runTests()
    %test_ConvertData()
    %test_InitializeGMM()
    %test_Distance()
    %test_GetPixelComponents()
    test_LearnGMMParams()
end
function [] = test_ConvertData()
    orig_img = imread('Test_Images/small_img1.jpg');
    T = InitializeTrimap(orig_img);
    %mu1 = [1 2];
    %Sigma1 = [2 0; 0 0.5];
    %mu2 = [-3 -5];
    %Sigma2 = [1 0;0 1];
    %rng(1); % For reproducibility
    %#X = [mvnrnd(mu1,Sigma1,1000);mvnrnd(mu2,Sigma2,1000)];
    [GMM_data] = ConvertImDataToGMMData(orig_img);
    %GMModel = fitgmdist(GMM_data,5);
end
function [] = test_InitializeGMM()
    orig_img = imread('Test_Images/small_img1.jpg');
    T = InitializeTrimap(orig_img);
    [GMM_data] = ConvertImDataToGMMData(orig_img);
    [GMM_fg, GMM_bg] = InitializeGMM(GMM_data, T);
    %disp(GMM_fg.mu)
    %disp(GMM_bg.mu)
end
   
function [] = test_Distance()
    orig_img = imread('Test_Images/small_img1.jpg');
    T = InitializeTrimap(orig_img);
    [GMM_data] = ConvertImDataToGMMData(orig_img);
    [GMM_fg, GMM_bg] = InitializeGMM(GMM_data, T);
    [D] = Distance(0, 1, GMM_fg, GMM_bg, squeeze(GMM_data(1,1, :)))
    [D] = Distance(0, 2, GMM_fg, GMM_bg, squeeze(GMM_data(1,1, :)))
    [D] = Distance(0, 3, GMM_fg, GMM_bg, squeeze(GMM_data(1,1, :)))
    [D] = Distance(0, 4, GMM_fg, GMM_bg, squeeze(GMM_data(1,1, :)))
    [D] = Distance(0, 5, GMM_fg, GMM_bg, squeeze(GMM_data(1,1, :)))
end

function [] = test_GetPixelComponents()
    orig_img = imread('Test_Images/small_img1.jpg');
    T = InitializeTrimap(orig_img);
    [GMM_data] = ConvertImDataToGMMData(orig_img);
    [GMM_fg, GMM_bg] = InitializeGMM(GMM_data, T);
    compAssignments = GetPixelComponents(GMM_data, T, T,  GMM_fg, GMM_bg);
end

function [] = test_LearnGMMParams()
    orig_img = imread('Test_Images/small_img1.jpg');
    T = InitializeTrimap(orig_img);
    [GMM_data] = ConvertImDataToGMMData(orig_img);
    [GMM_fg, GMM_bg] = InitializeGMM(GMM_data, T);
    compAssignments = GetPixelComponents(GMM_data, T, T,  GMM_fg, GMM_bg);
    [GMM_fgn, GMM_bgn] = LearnGMMParams(GMM_data, T, compAssignments);
    %disp(GMM_bgn.mu)
    %disp(GMM_bg.mu)
    
end