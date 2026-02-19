function out_struct = retrieve_image(n)
% retrieve_image Returns a structure containing image data and DMOS
%   out_struct = retrieve_image(n) takes an index n (1 to 779) and returns:
%     - out_struct.originalImage : the original reference image
%     - out_struct.Image         : the corrupted/distorted image
%     - out_struct.dmos          : the DMOS value for the distorted image
%
%   Example usage:
%     img_struct = retrieve_image(10);
%     imshow(img_struct.Image);
%     disp(img_struct.dmos);

% Load required DMOS and helper data
load dmos.mat
load Dmos_all.mat
load dmos_new.mat
load new_counter.mat

% Find the index in dmos_new corresponding to the DMOS value at position n
value = Dmos_all(n);
out1 = find(abs(dmos_new - value) < 0.0000001);

% Collect image information using the mapped index
out_struct = Collect_image(new_counter(out1));

%% Nested function to load images based on distortion type
function out_struct = Collect_image(i)
% Collect_image Loads original and distorted images given a global index i
%   Determines which distortion folder the image belongs to:
%     - JP2K: indices 1-227
%     - JPEG: indices 228-460
%     - White Noise (WN): indices 461-634
%     - Gaussian Blur (GBlur): indices 635-808
%     - Fast Fading: indices 809-779
%
%   Returns:
%     - originalImage: the reference image
%     - Image: the distorted image
%     - dmos: DMOS value corresponding to the distorted image

load dmos.mat
load refnames_all.mat

% Determine folder and local index based on i
if i <= 227
    folder = 'jp2k';
    ind = i;
elseif i <= 460
    folder = 'jpeg';
    ind = i - 227;
elseif i <= 634
    folder = 'wn';
    ind = i - 460;
elseif i <= 808
    folder = 'gblur';
    ind = i - 634;
else
    folder = 'fastfading';
    ind = i - 808;
end

% Load and normalize the original reference image
originalImage = im2double(imread(fullfile('refimgs', refnames_all{i})));
out_struct.originalImage = originalImage;

% Load and normalize the distorted image
imname = ['img' num2str(ind) '.bmp'];
image1 = im2double(imread(fullfile(folder, imname)));
out_struct.Image = image1;

% Assign the DMOS value for this distorted image
out_struct.dmos = dmos(i);
