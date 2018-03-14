%filename = input('Please enter the file name: ');
filename = '.\Test_Images\police_dog_training_PubD.jpg';
img = imread(filename);
imshow(img);

rect=getrect                           % select rectangle

I2=imcrop(img,rect);
imshow(I2)