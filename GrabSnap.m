%filename = input('Please enter the file name: ');
% filename = './Test_Images/police_dog_training_PubD.jpg';
% filename = './Test_Images/dog-jumping_CC-BY-SA_west-midlands-police.jpg';
% filename = './Test_Images/tourist-selfie-2_CC-BY-NC-SA_Scott-Ableman.jpg';
filename = './Test_Images/dog_training_2.jpg';
%  filename = 'Test_Images/small_img2.jpg';
%filename = 'Test_Images/small_img3.jpg';
img = imread(filename);
bg_img = imread('Test_Images/42504671_3b368de9f5_b_CC-BY-schizoform.jpg');
% bg_img = imread('Presentation_Images/Bird_Alphas/FinalBird.jpg');

[im_graph, beta] = GenImageGraph(img);
trimap = InitializeTrimap(img);
alpha = RunCut(img, im_graph, beta, trimap);
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
%     imshow(trimap./2);
%     input('Continue?');
%     imshow(alpha);
%     input('Continue?');
%     [~, alpha] = MinCutImg(img, alpha, trimap, GMM_fg, GMM_bg);
    alpha = RunCut(img, im_graph, beta, trimap);
    imshow(double(img).*alpha/255);
    answer = questdlg('Paint more pixels into foreground/background?', 'Edit Trimap', 'Foreground', 'Background', 'No', 'No');
end
% show result:
dim_img = size(img);
bg_img = imresize(bg_img, dim_img(1:2));
img = double(img)/255;
bg_img = double(bg_img)/255;
minmin_bg_r = min(min(bg_img(:,:,1)));
minmin_bg_g = min(min(bg_img(:,:,2)));
minmin_bg_b = min(min(bg_img(:,:,3)));
minmin_fg_r = min(min(img(:,:,1)));
minmin_fg_g = min(min(img(:,:,2)));
minmin_fg_b = min(min(img(:,:,3)));

bg_r_down = bg_img(:,:,1) - minmin_bg_r;
bg_g_down = bg_img(:,:,2) - minmin_bg_g;
bg_b_down = bg_img(:,:,3) - minmin_bg_b;
fg_r_down = img(:,:,1) - minmin_fg_r;
fg_g_down = img(:,:,2) - minmin_fg_g;
fg_b_down = img(:,:,3) - minmin_fg_b;

maxmax_bg_r = max(max(bg_r_down));
maxmax_bg_g = max(max(bg_g_down));
maxmax_bg_b = max(max(bg_b_down));
maxmax_fg_r = max(max(fg_r_down));
maxmax_fg_g = max(max(fg_g_down));
maxmax_fg_b = max(max(fg_b_down));

ratio_r = maxmax_bg_r / maxmax_fg_r;
ratio_g = maxmax_bg_g / maxmax_fg_g;
ratio_b = maxmax_bg_b / maxmax_fg_b;
fg_adj = img;
fg_adj(:,:,1) = fg_r_down.*ratio_r + minmin_bg_r;
fg_adj(:,:,2) = fg_g_down.*ratio_g + minmin_bg_g;
fg_adj(:,:,3) = fg_b_down.*ratio_b + minmin_bg_b;

% masked_fg = alpha.*double(img);
masked_fg_adj = alpha.*double(fg_adj);
masked_bg = (~alpha).*double(bg_img);
% comp = masked_fg + masked_bg;
comp_adj = masked_fg_adj + masked_bg;
imshow(comp_adj);