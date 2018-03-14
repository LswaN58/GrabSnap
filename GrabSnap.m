%filename = input('Please enter the file name: ');
filename = '.\Test_Images\police_dog_training_PubD.jpg';
img = imread(filename);

trimap = InitializeTrimap(img)
GMMData = ConvertImDataToGMMData()
[GMM_fg, GMM_bg] = InitializeGMM()
converged = false;
while converged == false
    compAssignments = GetPixelComponents(); % step 1 of algo
    params = LearnGMMParams(); % step 2 of algo
    [energy, cut] = MinCutImg(); % step 3 of algo
    converged = TestConvergence(); % step 4 of algo, sorta.
end
matte = GenBorderMatte();
paint = GetUserEdit();

