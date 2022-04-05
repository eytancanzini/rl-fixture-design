%% Front Spar Deflection
% TODO:
% - Add the list of points to the top surface for adding deflection
% - Insert a random point placer to insert fixture applications

model = createpde('structural', 'static-solid');
importGeometry(model, '../models/front_wing_spar.stl');
rotate(model.Geometry, 90, [0 0 0], [1 0 0]); % Rotate the part

% Creating the vertices that are used for the fixturing force
desired_precision = 45; % Reasonable value for number of points (320 vertices)
fixtureVertices = generateGrid(-990, -10, 20, 180, desired_precision);
% fixtureVertices = addVertex(model.Geometry, 'Coordinates', arr);

% Generate the vertices for the applied load from the drilling/riveting.
% These have to be added to the model during the PDE calculation
drill_list = -950:50:-50;
drill_pos = zeros(size(drill_list,2), 3);
for i=1:size(drill_list,2)
    drill_pos(i, :) = [20 drill_list(i) 200];
end

% Generate quick figure of what the component looks like
figure
pdegplot(model, 'VertexLabels','on', 'FaceAlpha', 0.5)
view(225,30) 
title('Front Wing Spar')
% saveas(gcf, '../images/pde-plot-item.png')
pause

% Set the material parameters and the boundary constraints
E = 69E09;
nu = 0.34;
rho = 2710;
F_drill = rivetingForce(4e-3, 0, 3e+8);

structuralProperties(model, 'YoungsModulus',E, ... 
    'PoissonsRatio',nu, ...
    'MassDensity',rho);
structuralBC(model, "Constraint", "fixed", "Face", [3 14]);

% Apply the drilling forces at each point and store the data results
drilling_results_z = {};
drilling_results_x = {};
drilling_meshes = {};
for i=1:size(drill_pos, 1)
    temp_model = model;
    fixtureVertexID = addVertex(temp_model.Geometry, "Coordinates", fixtureVertices(i,:));
    drillVertexID = addVertex(temp_model.Geometry, 'Coordinates', drill_pos(i,:));
    structuralBoundaryLoad(temp_model, 'Vertex', drillVertexID, 'Force', [0 0 F_drill]);
    structuralBoundaryLoad(temp_model, 'Vertex',fixtureVertexID, 'Force', calculateMagneticForce(0.4, 'x'));
    drilling_meshes{i} = generateMesh(temp_model);
    results = solve(temp_model);
    X = sprintf('Drilling Position = %d || Fixture Position = %d', i, fixtureVertexID);
    disp(X)
    drilling_results_z{i} = results.Displacement.z;
    drilling_results_x{i} = results.Displacement.x;
end

% Plot the deflection in the y and z directions to observe the impact of
% the drilling and fixturing forces
figure
for i=1:size(drilling_results_z,2)
    vals_z = cell2mat(drilling_results_z(i));
    vals_y = cell2mat(drilling_results_x(i));
    subplot(1,2,1)
    pdeplot3D(drilling_meshes{i},'ColorMapData',vals_z)
    title('Z-direction Displacement (m)')
    subplot(1,2,2)
    pdeplot3D(drilling_meshes{i}, 'ColorMapData', vals_y)
    title('Y-direction Displacement (m)')
    sgtitle(['Deformation at drilling point = ' num2str(i)]);
    pause
end

