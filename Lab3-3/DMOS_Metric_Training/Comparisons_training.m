%% Train DMOS prediction model using selected metrics and regression method
% This script allows the user to:
% 1. Choose which regression method to use (Linear, Polynomial, or KNN)
% 2. Choose which input metrics to include (SNR, SSIM, SCIELab)
% 3. Train and test the model, then compute correlations with DMOS

clear; clc;

%% Load data
load('Dmos_all.mat');
load('SNR_all.mat');
load('ssim_all.mat');
load('scielab_all.mat');

%% User selection for features
disp('Select input metrics to include (e.g., [1 3] for SNR and SCIELab):');
disp('1 = SNR,  2 = SSIM,  3 = SCIELab');
features_choice = input('Your choice: ');

% Build feature matrix based on selection
X = [];
if any(features_choice == 1)
    X = [X, SNR_all(:)];
end
if any(features_choice == 2)
    X = [X, ssim_all(:)];
end
if any(features_choice == 3)
    X = [X, scielab_all(:)];
end

y = Dmos_all(:);
N = length(y);

%% Split into training and test sets
train_rate = 0.8;
idx = randperm(N);
Ntrain = round(train_rate * N);

trainIdx = idx(1:Ntrain);
testIdx  = idx(Ntrain+1:end);

Xtrain = X(trainIdx, :);
ytrain = y(trainIdx);
Xtest = X(testIdx, :);
ytest = y(testIdx);

%% Choose regression method
disp('Select regression method:');
disp('1 = Linear Regression');
disp('2 = Second-Degree Polynomial Regression');
disp('3 = KNN Regression');
method = input('Your choice: ');

%% Train model and make predictions
switch method
    case 1  % Linear Regression
        disp('--- Linear Regression selected ---');
        Xtrain_aug = [ones(size(Xtrain,1),1), Xtrain];
        Xtest_aug  = [ones(size(Xtest,1),1), Xtest];
        b = Xtrain_aug \ ytrain;
        ypred = Xtest_aug * b;

    case 2  % Polynomial Regression (degree 2)
        disp('--- Second-Degree Polynomial Regression selected ---');
        % Add quadratic and interaction terms
        Xtrain_poly = [ones(size(Xtrain,1),1), Xtrain, Xtrain.^2];
        Xtest_poly  = [ones(size(Xtest,1),1), Xtest, Xtest.^2];
        b = Xtrain_poly \ ytrain;
        ypred = Xtest_poly * b;

    case 3  % KNN Regression (manual version, no toolbox needed)
        disp('--- KNN Regression selected ---');
        k = input('Enter number of neighbors (k): ');
        ypred = zeros(size(ytest));
        for i = 1:length(ytest)
            % Compute Euclidean distances from test point to all training points
            dists = sqrt(sum((Xtrain - Xtest(i,:)).^2, 2));
            % Find indices of k nearest neighbors
            [~, idx_sorted] = sort(dists);
            neighbors = ytrain(idx_sorted(1:k));
            % Predict DMOS as the mean of nearest neighbors
            ypred(i) = mean(neighbors);
        end

    otherwise
        error('Invalid choice. Please select 1, 2, or 3.');
end

%% Compute correlations
r_pearson = corr(ypred, ytest);
r_spearman = corr(ypred, ytest, 'Type', 'Spearman');

fprintf('\nResults from this training session:\n');
fprintf('   Pearson correlation (Predicted vs DMOS): %.4f\n', r_pearson);
fprintf('   Spearman correlation (Predicted vs DMOS): %.4f\n', r_spearman);

%% Optional: Compare individual metrics (if available)
disp('------------------------------------------------------');
fprintf('\nResults for each selected metric compared to DMOS, without training, for reference:\n');
metric_names = {'SNR', 'SSIM', 'SCIElab'};
for f = features_choice
    r_lin = corr(Xtest(:,features_choice == f), ytest);
    r_spear = corr(Xtest(:,features_choice == f), ytest, 'Type', 'Spearman');
    fprintf('  %s -> DMOS (Pearson): %.4f, (Spearman): %.4f\n', ...
        metric_names{f}, r_lin, r_spear);
end

disp('------------------------------------------------------');
disp('Training and evaluation complete.');
