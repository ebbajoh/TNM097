%% ------------------------------------------------------------------------
%  This script compares three objective image quality metrics
%  (SNR, SSIM, and S-CIELab) with subjective quality scores (DMOS)
%  from the LIVE Image Quality Assessment Database.
%
%  It calculates both Pearson and Spearman correlation coefficients
%  between each objective metric and the DMOS values to measure
%  how well the metrics align with human perception of image quality.
%
%  A high (positive) correlation means that the metric agrees well
%  with subjective human ratings. DMOS values have been scaled so that
%  higher values indicate better quality.
% ------------------------------------------------------------------------

% Load precomputed quality metric values and subjective DMOS scores
% All metric and DMOS values have been normalized to the range [0, 1],
% where 0 represents the lowest perceived quality and 1 the highest.

load Dmos_all.mat       % Subjective quality scores (Difference Mean Opinion Score)
load SNR_all.mat        % Signal-to-Noise Ratio values
load ssim_all.mat       % Structural Similarity (SSIM) values
load scielab_all.mat    % S-CIELab color-based perceptual difference values

%% Pearson correlation (measures linear correlation)
% Compute the Pearson correlation between each objective metric and DMOS.
% This shows how strongly and linearly each metric relates to the subjective quality scores.

r_ssim_dmos     = corr(ssim_all', Dmos_all');      % SSIM vs DMOS
r_snr_dmos      = corr(SNR_all', Dmos_all');       % SNR vs DMOS
r_scielab_dmos  = corr(scielab_all', Dmos_all');   % S-CIELab vs DMOS

disp('----------------------------------------------------------------')
% Display correlation results in the Command Window
disp(['Pearson Correlation SSIM vs DMOS: ' num2str(r_ssim_dmos)])
disp(['Pearson Correlation SNR  vs DMOS: ' num2str(r_snr_dmos)])
disp(['Pearson Correlation S-CIELab vs DMOS: ' num2str(r_scielab_dmos)])

%% Spearman correlation (measures rank correlation)
% This correlation checks how well the *ranking* of images according
% to each objective metric agrees with the ranking given by DMOS.
% It is less sensitive to nonlinear relationships than Pearson.

r_ssim_dmos_s     = corr(ssim_all', Dmos_all', 'Type', 'Spearman');     % SSIM vs DMOS
r_snr_dmos_s      = corr(SNR_all', Dmos_all', 'Type', 'Spearman');      % SNR vs DMOS
r_scielab_dmos_s  = corr(scielab_all', Dmos_all', 'Type', 'Spearman');  % S-CIELab vs DMOS

% Display the Spearman correlation results
disp('----------------------------------------------------------------')
disp(['Spearman correlation SSIM vs DMOS: ' num2str(r_ssim_dmos_s)])
disp(['Spearman correlation SNR  vs DMOS: ' num2str(r_snr_dmos_s)])
disp(['Spearman correlation S-CIELab vs DMOS: ' num2str(r_scielab_dmos_s)])
