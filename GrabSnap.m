EPSILON_CONVERGENCE = 1.0;

%filename = input('Please enter the file name: ');
%filename = '.\Test_Images\police_dog_training_PubD.jpg';
filename = 'Test_Images/small_img2.jpg';
img = imread(filename);

trimap = InitializeTrimap(img);
alpha = trimap;
GMMData = ConvertImDataToGMMData(img);
[GMM_fg, GMM_bg] = InitializeGMM(GMMData, trimap);
converged = false;
prev_energy = 0;
iter = 1;
while converged == false
    disp(['Started iteration ', num2str(iter), '. Previous energy was ', num2str(prev_energy)]);
    compAssignments = GetPixelComponents(GMMData, trimap, alpha, GMM_fg, GMM_bg); % step 1 of algo.
    params = LearnGMMParams(GMMData, alpha, compAssignments); % step 2 of algo
    [energy, cut] = MinCutImg(img, alpha, trimap, compAssignments, GMM_fg, GMM_bg); % step 3 of algo
    alpha = cut;
    converged = (abs(energy-prev_energy) < EPSILON_CONVERGENCE); % step 4 of algo, sorta.
    prev_energy = energy;
    imshow(cut);
    iter = iter+1;
end
matte = GenBorderMatte(img, cut);
paint = GetUserEdit(img);

