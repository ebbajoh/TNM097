
clear; close all; 

% read img
img = im2double(imread('img/test-bild1.jpg'));

% smoothing (reduces texture noise)
img = imgaussfilt(img, 2);

% convert to cieLab 
lab = rgb2cielab(img);

figure
imshow(img)
title('Original (Smoothed)')

% cluster into many colors

%vi börjar med flera clusters
K_initial = 30;   

% hämtar storleken på bilden i cielab formatet
[h,w,~] = size(lab);

%varje pixel blir en datapunkt i ett "3D färgrum"
lab_reshaped = reshape(lab, [], 3);

[idx, centers] = kmeans(lab_reshaped, K_initial);

% Count cluster sizes
counts = histcounts(idx, 1:K_initial+1);

% Sort by dominance
[~, sortedIdx] = sort(counts, 'descend');

% Select 10 most dominant clusters
K = 15;
topK = sortedIdx(1:K);

dominant_centers = centers(topK, :);
 
%forces every pixel in the image to become one of those dominant colors

%Compute distance from every pixel to every dominant color
D = pdist2(lab_reshaped, dominant_centers);

%Find nearest dominant color
[~, nearest] = min(D, [], 2);

%Reshape into image format
label_map = reshape(nearest, h, w);

% Reconstruct quantized image
lab_quant = dominant_centers(nearest, :);
lab_quant = reshape(lab_quant, h, w, 3);

rgb_quant = lab2rgb(lab_quant);

figure
imshow(rgb_quant)
title('15 Most Dominant Colors')


% remove small regions

minSize = 2000;   

% create empty map
clean_map = zeros(size(label_map));

for k = 1:K
    mask = (label_map == k);
    mask_clean = bwareaopen(mask, minSize);
    clean_map(mask_clean) = k;
end

% Fill removed pixels using nearest valid neighbor
valid_mask = clean_map > 0;
[~, idx_nearest] = bwdist(valid_mask);
clean_map(~valid_mask) = clean_map(idx_nearest(~valid_mask));

% Reconstruct cleaned image
lab_clean = dominant_centers(clean_map(:), :);
lab_clean = reshape(lab_clean, h, w, 3);

rgb_clean = lab2rgb(lab_clean);

figure
imshow(rgb_clean)
title('After Removing Small Regions')


% Hittar gränser mellan färgområden

% Detect boundaries via label difference
boundaries = false(h, w);

boundaries(:,1:end-1) = ...
    (clean_map(:,1:end-1) ~= clean_map(:,2:end));

boundaries(1:end-1,:) = ...
    boundaries(1:end-1,:) | ...
    (clean_map(1:end-1,:) ~= clean_map(2:end,:));

% Thin to single-pixel lines
boundaries = bwmorph(boundaries, 'thin', 2);

outline = ones(h, w);
outline(boundaries) = 0;

figure
imshow(outline)
title('Final Clean Region Boundaries')

