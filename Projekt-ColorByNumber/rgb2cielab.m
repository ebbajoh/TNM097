function lab = rgb2cielab(rgb)
rgb = im2double(rgb);

rgb_lin = rgb;
mask = rgb <= 0.04045;
rgb_lin(mask)  = rgb(mask)/12.92;
rgb_lin(~mask) = ((rgb(~mask)+0.055)/1.055).^2.4;

M = [0.4124 0.3576 0.1805;
     0.2126 0.7152 0.0722;
     0.0193 0.1192 0.9505];

[h,w,~] = size(rgb_lin);
rgb_lin = reshape(rgb_lin, [], 3);
XYZ = (M * rgb_lin')';

% Referensvit D65
Xn = 0.95047;
Yn = 1.00000;
Zn = 1.08883;

X = XYZ(:,1) / Xn;
Y = XYZ(:,2) / Yn;
Z = XYZ(:,3) / Zn;

f = @(t) (t > 0.008856).*t.^(1/3) + ...
         (t <= 0.008856).*(7.787*t + 16/116);

fx = f(X);
fy = f(Y);
fz = f(Z);

L = 116*fy - 16;
a = 500*(fx - fy);
b = 200*(fy - fz);

lab = reshape([L a b], h, w, 3);

end