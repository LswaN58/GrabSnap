%filename = input('Please enter the file name: ');
%filename = './Test_Images/police_dog_training_PubD.jpg';
% filename = './Test_Images/dog_training_2.jpg';
 filename = 'Test_Images/small_img2.jpg';
%filename = 'Test_Images/small_img3.jpg';
img = imread(filename);
bg_img = imread('Test_Images/42504671_3b368de9f5_b_CC-BY-schizoform.jpg');

trimap = InitializeTrimap(img);
alpha = RunCut(img, trimap);
matte = GenBorderMatte(img, alpha);

answer = questdlg('Paint pixels into foreground/background?', 'Edit Trimap', 'Foreground', 'Background', 'No', 'No');
while strcmp(answer, 'No') == 0
    trimap = GetUserEdit(double(img).*alpha/255, trimap, answer);
    % create masks from the trimap, so we can update the alpha.
    fg_mask = min(2, trimap) - 1;
    bg_mask = double(~~trimap);
    % take max with fg_mask to force all fg into alpha=1.
    % mult by bg_mask to force all in bg to alpha=0.
    alpha = max(fg_mask, alpha).*bg_mask;
    imshow(trimap./2);
    input('Continue?');
    imshow(alpha);
    input('Continue?');
%     [~, alpha] = MinCutImg(img, alpha, trimap, GMM_fg, GMM_bg);
    alpha = RunCut(img, trimap);
    imshow(double(img).*alpha/255);
    answer = questdlg('Paint more pixels into foreground/background?', 'Edit Trimap', 'Foreground', 'Background', 'No', 'No');
end
% show result:
dim_img = size(img);
bg_img = imresize(bg_img, dim_img(1:2));
masked_fg = alpha.*double(img);
masked_bg = (~alpha).*double(bg_img);
comp = round(masked_fg + masked_bg)/255;
imshow(comp);