%% Basic Deflection Analysis of Component
% Author: Ethan Canzini MEng (Hons) MIEEE

%% Load CAD model into system
model = createpde('structural', 'static-solid');
importGeometry(model, './2020-beam-alu.stl')

figure
pdegplot(model, 'FaceLabels','on')
view(90,45)
title('20x20mm Aluminium Extrusion')

%% Assign structural properties and boundary loads to the component

structuralProperties(model, 'YoungsModulus', 69e9, ...
    'PoissonsRatio', 0.31);

structuralBC(model,'Face',86,'Constraint','fixed');
structuralBC(model,'Face',87,'Constraint','fixed');

structuralBoundaryLoad (model,'Face',56,'SurfaceTraction',[0;1e4;0]);
structuralBoundaryLoad (model,'Face',74,'SurfaceTraction',[0;1e4;0]);

%% Generate the mesh, apply the solver and plot the results

generateMesh(model);
figure
pdeplot3D(model)
title('Mesh with Quadratic Tetrahedral Elements');

result = solve(model);
figure
pdeplot3D(model,'ColorMapData',result.Displacement.x)
title('x-displacement')
colormap('jet')

%% Examine the displacement for every point in the component

x_displacement = result.Displacement.x;

figure
histogram(x_displacement, 10) % Histogram to look at the displacement values for each point in the array