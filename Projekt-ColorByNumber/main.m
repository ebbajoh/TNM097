clear; close all; 

% read img
img = im2double(imread('img/GrapeFruit.jpg'));

% smoothing (reduces texture noise)
img = imgaussfilt(img, 2);

% convert to cieLab 
lab = rgb2cielab(img);

figure
imshow(img)
title('Original (Smoothed)')

% cluster into many colors

%vi börjar med flera clusters
K = 15;   

% hämtar storleken på bilden i cielab formatet
[h,w,~] = size(lab);

%varje pixel blir en datapunkt i ett "3D färgrum"
lab_reshaped = reshape(lab, [], 3);

% --- Stable kmeans (improved) ---
[idx, centers] = kmeans(lab_reshaped, K, 'Replicates', 10, ...
    'MaxIter', 500, ...
    'Start', 'plus');

% reshape into image format
label_map = reshape(idx, h, w);

% Reconstruct quantized image
lab_quant = centers(idx, :);
lab_quant = reshape(lab_quant, h, w, 3);

rgb_quant = lab2rgb(lab_quant);

figure
imshow(rgb_quant)
title('10 Dominant Colors')

% remove small regions

% Justera radien vid behov (större värde = mer aggressiv borttagning)
se = strel('disk', 5);   

% create empty map
clean_map = zeros(size(label_map));

% Tar bort små strukturer baserat på geometrisk form (morfologisk opening)
for k = 1:K
    mask = (label_map == k);
    mask_clean = imopen(mask, se);   % ersätter bwareaopen
    clean_map(mask_clean) = k;
end

% Fill removed pixels using nearest valid neighbor
valid_mask = clean_map > 0;
[~, idx_nearest] = bwdist(valid_mask);
clean_map(~valid_mask) = clean_map(idx_nearest(~valid_mask));

% Reconstruct cleaned image
lab_clean = centers(clean_map(:), :);
lab_clean = reshape(lab_clean, h, w, 3);

rgb_clean = lab2rgb(lab_clean);

figure
imshow(rgb_clean)
title('After Removing Small Regions')

% Hittar gränser mellan färgområden

% Detect boundaries via label difference
boundaries = false(h, w);

boundaries(:,1:end-1) = (clean_map(:,1:end-1) ~= clean_map(:,2:end));

boundaries(1:end-1,:) = boundaries(1:end-1,:) | ...
                        (clean_map(1:end-1,:) ~= clean_map(2:end,:));

% Thin to single-pixel lines
boundaries = bwmorph(boundaries, 'thin', 1);

% Make lines slightly thicker (better for printing)
boundaries = imdilate(boundaries, strel('disk',1));

outline = ones(h, w);
outline(boundaries) = 0;

figure
imshow(outline)
title('Final Clean Region Boundaries')

createPaletteLegend(outline, centers, clean_map);

palette_rgb = lab2rgb(centers);

interactivePaint(outline, palette_rgb, clean_map);