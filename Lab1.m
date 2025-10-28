%% Lab 1: Image as a 2D Signal (Sampling, Quantization, Histograms, Enhancement)
%
% -------------------------------------------------------------------------
% Quick Notes:
% - If 'peppers.png' is not available, use 'cameraman.tif' or any local image.
% - Emphasize mapping: quantization->bit-depth; dynamic range->contrast; sampling->resize.
% - Gamma is nonlinear; contrast stretching is linear remapping.
% -------------------------------------------------------------------------
% HOW TO SUBMIT: include screenshots and short explanations for each section in the GitHub. Submit only the GitHub URL.

close all;
clear;
clc;

%% 0) Load and inspect an image
% Load RGB image (fallback to cameraman). Convert to grayscale.
% Show class, range, and size to understand pixel data.

if exist('peppers.png','file')
    I_rgb = imread('peppers.png');
else
    I_rgb = repmat(imread('cameraman.tif'),1,1,3); % fallback
end

figure;
imshow(I_rgb);
title('Original RGB');

% Convert to grayscale (luminance)
if size(I_rgb,3)==3
    I = rgb2gray(I_rgb);
else
    I = I_rgb;
end

figure;
imshow(I);
title('Grayscale');

% Basic info
fprintf('Class: %s | Range: [%g, %g] | Size: %d x %d\n', class(I), double(min(I(:))), double(max(I(:))), size(I,1), size(I,2));

%% 1) Quantization and dynamic range
% Reduce bit-depth (8, ~6, ~4 bits). Lower depth => fewer gray levels,
% visible banding/posterization in smooth regions.

I8 = I; % 8-bit (0..255)
I6 = uint8(floor(double(I)/4)*4); % ~6 bits (step 4)
I4 = uint8(floor(double(I)/16)*16); % ~4 bits (step 16)

figure;
montage({I8,I6,I4},'Size',[1 3]);
title('Quantization: 8-bit vs ~6-bit vs ~4-bit');

%% 2) Histogram and contrast stretching
% Histogram shows intensity distribution. Normalization rescales to [0,1].
% Contrast stretching linearly expands mid-range -> better detail visibility.

figure;
subplot(1,2,1);
imhist(I);
title('Histogram (original)');

I_norm = mat2gray(I); % scales to [0,1]
I_stretch = imadjust(I,[0.2 0.8],[0 1]); % stretch mid-range

subplot(1,2,2);
imhist(I_stretch);
title('Histogram (stretched)');

figure;
montage({I, im2uint8(I_norm), im2uint8(I_stretch)},'Size',[1 3]);
title('Original | Normalized | Contrast-stretched');

%% 3) Gamma correction (nonlinear amplitude scaling)
% Nonlinear mapping. Gamma<1 brightens darks, Gamma>1 darkens brights.
% Affects mid-tones differently than linear stretching.

I_gamma_low = imadjust(I,[],[],0.6); % gamma < 1 brightens
I_gamma_high = imadjust(I,[],[],1.6); % gamma > 1 darkens

figure;
montage({I,I_gamma_low,I_gamma_high},'Size',[1 3]);
title('Gamma: original | gamma=0.6 | gamma=1.6');

%% 4) Sampling and aliasing (downsample then upsample)
% Downsample then upsample. Detail lost, blockiness appears.
% Aliasing occurs when sampling < 2x highest frequency (Nyquist).

scale = 0.1; % 10% of size
I_small = imresize(I, scale, 'nearest'); % naive sampling
I_back = imresize(I_small, size(I), 'nearest');

figure;
montage({I, I_small, I_back}, 'Size', [1 3]);
title('Original | Aggressively downsampled | Upscaled back (aliasing artifacts)');
%% 5) OPTIONAL: Moiré demo
% If you have a striped/high-frequency texture image, repeat Section 4 and
% observe interference patterns (moiré).

%% 6) Short reflections (add to your report)
% 1) Relate bit-depth to visible banding/posterization you observed.
% Reducing bit-depth decreases the number of available gray levels.
% Smooth gradients become visible steps (banding), especially in flat
% regions like skies or shadows.

% 2) How does contrast stretching change the histogram and visibility of details?
% Histogram is spread out across the full intensity range.
% Darker and lighter details become more visible, improving contrast.
% Enhances visibility of features that were previously compressed into a
% narrow intensity band.

% 3) Explain why aggressive downsampling causes aliasing (reference Nyquist).
% According to the Nyquist theorem, to represent a signal without aliasing,
% the sampling rate must be at least twice the highest frequency present.
% Aggressive downsampling reduces the sampling rate below this threshold.
% High-frequency details (edges, textures) fold into lower frequencies,
% creating distortions and artifacts.