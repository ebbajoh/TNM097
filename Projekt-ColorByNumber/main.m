%hej hej

% hej!

% rgb till cielab
img = im2double(imread('img/ArthurImage.jpg'));

lab = rgb2cielab(img);

figure
imshow(img)
title('Original')

figure
imshow(lab2rgb(lab))
title('LAB -> RGB')

