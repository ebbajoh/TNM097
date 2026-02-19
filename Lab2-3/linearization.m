function [out] = linearization(inputTRC,inputRamp)


 x = 0:0.01:1;

  %pchip - Piecewise Cubic Hermite Interpolation
  %interp1(y,x,034,pchip)
  out(:,:,1) = interp1(inputTRC(:,:,1), x ,inputRamp(:,:,1),'pchip');
  out(:,:,2) = interp1(inputTRC(:,:,2), x, inputRamp(:,:,2),'pchip');
  out(:,:,3) = interp1(inputTRC(:,:,3), x, inputRamp(:,:,3),'pchip');

end

