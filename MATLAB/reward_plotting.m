xvec = linspace(0, 10, 1000);
yvec = linspace(0, 10, 1000);

[xmat, ymat] = meshgrid(xvec, yvec);

a = 1;
b = 1;
c = 0;

R = (1./(1 + ((xmat-c)./a).^(2*b)) + 1./(1 + ((ymat-c)./a).^(2*b)))./2;

figure(1)
contour3(xvec, yvec, R, 500)
view(115, 40);
xlabel('X deformation ($10^{-6}\ mm$)', 'Interpreter','latex', 'FontWeight','bold')
ylabel('Z deformation ($10^{-6}\ mm$)', 'Interpreter','latex', 'FontWeight','bold')
zlabel('Reward ($R$)', 'Interpreter', 'latex')
axis tight

xh = get(gca,'XLabel'); % Handle of the x label
set(xh, 'Units', 'Normalized')
pos = get(xh, 'Position');
set(xh, 'Position',pos.*[1.1,-2.2,1],'Rotation',44)
yh = get(gca,'YLabel'); % Handle of the y label
set(yh, 'Units', 'Normalized')
pos = get(yh, 'Position');
set(yh, 'Position',pos.*[1,0.1,1],'Rotation',-10)
saveas(gcf, './images/reward_surface.png')
