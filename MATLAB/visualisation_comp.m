%% Visualisation of Component

model = createpde('structural', 'static-solid');
importGeometry(model, '../models/front_wing_spar.stl');
rotate(model.Geometry, 90, [0 0 0], [1 0 0]); % Rotate the part

fixtureVertices = generateGrid(-990, -10, 20, 180, 20, 10);

figure(1)
scatter(fixtureVertices(:, 2), fixtureVertices(:,3))
grid on
xlabel('Y Direction Points')
ylabel('Z Direction Points')
ylim([10 190])

figure(2)
pdegplot(model)







