EPSILON_CONVERGENCE = 1.0;

%filename = input('Please enter the file name: ');
filename = '.\Test_Images\police_dog_training_PubD.jpg';
img = imread(filename);

trimap = InitializeTrimap(img);
GMMData = ConvertImDataToGMMData(img);
[GMM_fg, GMM_bg] = InitializeGMM(GMMData);
converged = false;
prev_energy = 0;
while converged == false
    compAssignments = GetPixelComponents(img, GMM_fg); % step 1 of algo.
    % Probably need something for GMM_bg as well.
    params = LearnGMMParams(img, compAssignments, GMM_fg); % step 2 of algo
    % Probably need something for GMM_bg as well.
    [energy, cut] = MinCutImg(img, GMM_fg, GMM_bg); % step 3 of algo
    converged = (abs(energy-prev_energy) < EPSILON_CONVERGENCE); % step 4 of algo, sorta.
    prev_energy = energy;
end
matte = GenBorderMatte(img, cut);
paint = GetUserEdit(img);

