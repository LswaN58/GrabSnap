%filename = input('Please enter the file name: ');
%filename = './Test_Images/police_dog_training_PubD.jpg';
% filename = './Test_Images/dog-jumping_CC-BY-SA_west-midlands-police.jpg';
 filename = 'Test_Images/small_img2.jpg';
%filename = 'Test_Images/small_img3.jpg';
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
    disp('Starting GetPixelComponents');
    tic
    compAssignments = GetPixelComponents(GMMData, trimap, alpha, GMM_fg, GMM_bg); % step 1 of algo.
    toc
    [GMM_fg, GMM_bg] = LearnGMMParams(GMMData, alpha, compAssignments); % step 2 of algo
    [energy, alpha] = MinCutImg(img, alpha, trimap, compAssignments, GMM_fg, GMM_bg); % step 3 of algo
    epsilon = 0.01 * energy;
    converged = (abs(energy-prev_energy) < epsilon); % step 4 of algo, sorta.
    prev_energy = energy;
    imshow(alpha);
    iter = iter+1;
end
matte = GenBorderMatte(img, alpha);
paint = GetUserEdit(img);

% show result:
bg_img = imread('Test_Images/42504671_3b368de9f5_b_CC-BY-schizoform.jpg');
dim_img = size(img);
bg_img = imresize(bg_img, dim_img(1:2));
masked_fg = alpha.*double(img);
masked_bg = (~alpha).*double(bg_img);
comp = round(masked_fg + masked_bg)/255;
imshow(comp);