function [] = runTests()
    test_ConvertData()
end
function [] = test_ConvertData()
    orig_img = imread('Test_Images/small_img1.jpg');
    [ GMM_data ] = ConvertImDataToGMMData(orig_img)
end