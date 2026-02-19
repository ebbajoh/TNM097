function diff = colordiffernce(ref,est)

[L,A,B] = xyz2lab(ref(1,:), ref(2,:), ref(3,:));
[L2,A2,B2] = xyz2lab(est(1,:), est(2,:), est(3,:));

diff = sqrt((L - L2).^2 + (A - A2).^2 + (B - B2).^2);

end