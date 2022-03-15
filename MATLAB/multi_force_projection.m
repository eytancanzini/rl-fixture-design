%% Multi-Point Fixture Force Generation
% TODO:
% - Insert random point generator that maintains distance between points
% - Redo the force function to return just a force (might get rid of it?)
% - Add support for multiple points on a single surface
% - FUTURE: Turn it into a function that runs alongside the RL algorithm

model = createpde('structural','static-solid');
gm=multicuboid(100,40,0.3);
model.Geometry = gm;

E = 69E09;
nu = 0.34;
rho = 2710;

structuralProperties(model, 'YoungsModulus',E, ... 
    'PoissonsRatio',nu, ...
    'MassDensity',rho);

structuralBC(model,'Face',[5 3],'Constraint', 'fixed');

% Add vertex at random point on face
vertexID = addVertex(model.Geometry, 'Coordinates', [3 0 0.3]);

figure
pdegplot(model, 'VertexLabels','on', 'FaceAlpha', 0.5)
title("Simple Plate Diagram with added vertex")

structuralBoundaryLoad(model, 'Vertex', vertexID, 'Force', @multiPointForce);
generateMesh(model);

structuralResults = solve(model);

figure
pdeplot3D(model,'ColorMapData',structuralResults.Displacement.z)
title('Z-displacement')
colormap('jet')

[y, x0] = hist(structuralResults.Displacement.x, 40);

figure
histfit(structuralResults.Displacement.x, 20)
xlim([-1e-5 1e-5])
grid on
