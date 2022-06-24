%% Visualisation of Component

model = createpde('structural', 'static-solid');
importGeometry(model, '../models/skin_panel.stl');
% rotate(model.Geometry, 90, [0 0 0], [1 0 0]); % Rotate the part
drillList = linspace(-990, -10, 100);

% fixtureVertices = generateGrid(-990, -10, 20, 180, 20, 10);
% drillingVertices = drillingVerticesGenerator(drillList);
% for i=1:size(drillingVertices, 1)
%     drillingVertexID = addVertex(model.Geometry, 'Coordinates', drillingVertices(i, :));
% end

% figure(1)
% scatter(fixtureVertices(:, 2), fixtureVertices(:,3))
% grid on
% xlabel('Y Direction Points')
% ylabel('Z Direction Points')
% ylim([10 190])
% saveas(gcf, './images/fixture_vertices.eps', 'epsc')

figure(2)
pdegplot(model, "VertexLabels","on")
saveas(gcf, './images/pde_model.png')







