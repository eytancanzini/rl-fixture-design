%% Front Spar Fixture Generation
% TODO:
% - Insert random point generator that maintains distance between points
% - Redo the force function to return just a force (might get rid of it?)
% - Add support for multiple points on a single surface
% - FUTURE: Turn it into a function that runs alongside the RL algorithm

model = createpde('structural', 'static-solid');
importGeometry(model, '../models/front_wing_spar.stl');
rotate(model.Geometry, 90, [0 0 0],[1 0 0]); % Rotate to correct orientation

vertexID = addVertex(model.Geometry, 'Coordinates', [0 -500 90]);

figure
pdegplot(model, 'FaceLabels','on')
view(90,45)
title('Front Spar')

E = 69E09;
nu = 0.34;
rho = 2710;

structuralProperties(model, 'YoungsModulus',E, ... 
    'PoissonsRatio',nu, ...
    'MassDensity',rho);
structuralBC(model, "Constraint", "fixed", "Face", [3 14]);
structuralBoundaryLoad(model, 'Vertex', vertexID, 'Force', @multiPointForce);
generateMesh(model);
results = solve(model);

figure
pdeplot3D(model, 'ColorMapData', results.Displacement.x);
title('Z-displacement')
colormap('jet')

figure
histfit(results.Displacement.x, 20)
grid on




