%% Front Spar Deflection
% TODO:
% - Add the list of points to the top surface for adding deflection
% - Insert a random point placer to insert fixture applications

model = createpde('structural', 'static-solid');
importGeometry(model, '../models/front_wing_spar.stl');
rotate(model.Geometry, 90, [0 0 0], [1 0 0]); % Rotate the part

% Creating the vertices that are used for the fixturing force
fixtureVertices = generateGrid(-990, -10, 20, 180, 20, 10);

% Generate the vertices for the applied load from the drilling/riveting.
% These have to be added to the model during the PDE calculation
drill_list = linspace(-950, -50, 50);
drill_pos = zeros(size(drill_list,2), 3);
for idx=1:size(drill_list,2)
    drill_pos(idx, :) = [20 drill_list(idx) 200];
end

% % Generate quick figure of what the component looks like
% figure
% pdegplot(model, 'VertexLabels','on', 'FaceAlpha', 0.5)
% view(225,30) 
% title('Front Wing Spar')
% % saveas(gcf, '../images/pde-plot-item.png')
% pause

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
for idx=1:size(drill_pos, 1)
    temp_model = model;
    int = randi([1 100]);
    fixtureVertexID = addVertex(temp_model.Geometry, "Coordinates", fixtureVertices(int,:));
    drillVertexID = addVertex(temp_model.Geometry, 'Coordinates', drill_pos(idx,:));
    structuralBoundaryLoad(temp_model, 'Vertex', drillVertexID, 'Force', [0 0 F_drill]);
    structuralBoundaryLoad(temp_model, 'Vertex',fixtureVertexID, 'Force', calculateMagneticForce(0.4, 'x'));
    X = sprintf('Drilling Position = %d || Fixture Position = (%d, %d, %d)', idx, fixtureVertices(int, 1), fixtureVertices(int, 2), fixtureVertices(int, 3));
    disp(X)
    drilling_meshes{idx} = generateMesh(temp_model);
    results = solve(temp_model);
    drilling_results_z{idx} = results.Displacement.z;
    drilling_results_x{idx} = results.Displacement.x;
end

max_vals_z = zeros(50,1);
max_vals_x = zeros(50,1);
for i=1:50
    max_vals_z(i) = max(drilling_results_z{i});
    max_vals_x(i) = max(drilling_results_x{i});
end

% Plot the deflection in the y and z directions to observe the impact of
% the drilling and fixturing forces

% nImages = 19;
% fileName = "testAnimated.gif";
% 
% fig = figure;
% fig.Position = [100 100 1080 800];
% for idx=1:size(drilling_results_z,2)
%     vals_z = cell2mat(drilling_results_z(idx));
%     vals_y = cell2mat(drilling_results_x(idx));
%     subplot(1,2,1)
%     pdeplot3D(drilling_meshes{idx},'ColorMapData',vals_z)
%     title('Z-direction Displacement (m)')
%     subplot(1,2,2)
%     pdeplot3D(drilling_meshes{idx}, 'ColorMapData', vals_y)
%     title('Y-direction Displacement (m)')
%     sgtitle(['Deformation at drilling point = ' num2str(idx)]);
%     pause
% %     drawnow
% %     frame = getframe(fig);
% %     im{idx} = frame2im(frame);
% %     [A, map] = rgb2ind(im{idx}, 256);
% %     if idx == 1
% %         imwrite(A, map, fileName, 'gif', "LoopCount", Inf, "DelayTime", 1);
% %     else
% %         imwrite(A, map, fileName, 'gif', "WriteMode", "append", "DelayTime", 1);
% %     end
% end

