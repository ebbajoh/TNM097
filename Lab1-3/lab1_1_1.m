% Lab 1 – Uppgift 1.1
clear; close all; clc

load Ad.mat
load Ad2.mat

lambda = 400:5:700;

figure

subplot(1,2,1)
plot(lambda, Ad(:,1), 'r', ...
     lambda, Ad(:,2), 'g', ...
     lambda, Ad(:,3), 'b', 'LineWidth', 1.5)
title('Camera 1 (Ad)')
xlabel('Wavelength (nm)')
ylabel('Sensitivity')
legend('R','G','B')
grid on

subplot(1,2,2)
plot(lambda, Ad2(:,1), 'r', ...
     lambda, Ad2(:,2), 'g', ...
     lambda, Ad2(:,3), 'b', 'LineWidth', 1.5)
title('Camera 2 (Ad2)')
xlabel('Wavelength (nm)')
ylabel('Sensitivity')
legend('R','G','B')
grid on
