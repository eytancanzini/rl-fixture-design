%% Front Spar Deflection
% TODO:
% - Fix issue with the model not wanting to generate a mesh on the
% component
% - Add the list of points to the top surface for adding deflection
% - Insert a random point placer to insert fixture applications

model = createpde('structural', 'static-solid');
importGeometry(model, '../models/front_wing_spar.stl');
rotate(model.Geometry, 90, [0 0 0], [1 0 0]); % Rotate the part

% Creating the vertices that are used for the fixturing force
desired_precision = 45; % Reasonable value for number of points (320 vertices)
arr = generateGrid(-990, -10, 20, 180, desired_precision);
% fixtureVertices = addVertex(model.Geometry, 'Coordinates', arr);

% Creating the vertices for the applied load
drill_list = -950:50:-50;
drill_pos = zeros(size(drill_list,2), 3);
for i=1:size(drill_list,2)
    drill_pos(i, :) = [20 drill_list(i) 200];
end
drillVertices = addVertex(model.Geometry, 'Coordinates', drill_pos);

% Generate quick figure of what the component looks like
figure
pdegplot(model, 'VertexLabels','on', 'FaceAlpha', 0.5)
view(225,30) 
title('Front Wing Spar')
% saveas(gcf, '../images/pde-plot-item.png')

% Set the material parameters and the boundary constraints
E = 69E09;
nu = 0.34;
rho = 2710;

structuralProperties(model, 'YoungsModulus',E, ... 
    'PoissonsRatio',nu, ...
    'MassDensity',rho);
structuralBC(model, "Constraint", "fixed", "Face", [3 14]);

F = rivetingForce(4e-3, 0, 3e+8);
structuralBoundaryLoad(model, 'Vertex', drillVertices(1), 'Force', [0 0 F]);
generateMesh(model);
results = solve(model);

% for i=1:size(drillVertices,1)
%     F = rivetingForce(4e-3, 0, 3e+8);
%     structuralBoundaryLoad(model, 'Vertex', i, 'Force', [0 0 F]);
%     generateMesh(model);
%     results = solve(model);
% end

