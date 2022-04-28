xvec = linspace(0.2, 10, 1000);
yvec = linspace(0.2, 10, 1000);

[xmat, ymat] = meshgrid(xvec, yvec);

R = (heaviside(-xmat+0.2) + exp(-8*(xmat-0.2).^2) + heaviside(-ymat+0.2) + exp(-8*(ymat-0.2).^2))/3;

figure(1)
contour3(xvec, yvec, R, 100)
