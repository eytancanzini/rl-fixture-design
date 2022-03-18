%% Front Spar Fixture Generation
% TODO:
% - Insert random point generator that maintains distance between points
% - Redo the force function to return just a force (might get rid of it?)
% - Add support for multiple points on a single surface
% - FUTURE: Turn it into a function that runs alongside the RL algorithm

model = createpde('structural', 'transient-solid');
importGeometry(model, '../models/front_wing_spar.stl');
rotate(model.Geometry, 90, [0 0 0],[1 0 0]); % Rotate to correct orientation

vertexID = addVertex(model.Geometry, 'Coordinates', [0 -500 90]);

figure
pdegplot(model, 'FaceLabels','on')
view(90,45)
title('Front Wing Spar')

E = 69E09;
nu = 0.34;
rho = 2710;

structuralProperties(model, 'YoungsModulus',E, ... 
    'PoissonsRatio',nu, ...
    'MassDensity',rho);
structuralBC(model, "Constraint", "fixed", "Face", [3 14]);
structuralBoundaryLoad(model, 'Vertex', vertexID, 'Force', @multiPointForce);
structuralBoundaryLoad(model, 'Face', 7, 'Pressure', @processPressureDistribution);
d0=[0,0,0];
v0=[0,0,0];
structuralIC(model,'Displacement',d0,'Velocity',v0);
tmax = 10;
tlist = 0:1:tmax;
generateMesh(model);
results = solve(model, tlist);

for i = 1:numel(results.SolutionTimes)
    sgt = sgtitle(['Deflection of bridge at Time = ' num2str(results.SolutionTimes(i))]);
    subplot(1,2,1)
    pdeplot3D(model, 'ColorMapData', results.Displacement.ux(:,i))
    subplot(1,2,2)
    pdeplot3D(model, 'ColorMapData', results.Displacement.uz(:,i))
    pause
end

x = results.Displacement.ux(:,end);
y = results.Displacement.uy(:,end);
z = results.Displacement.uz(:,end);
u = [x y z];

titles = ["Distribution in X";
    "Distribution in Y";
    "Distribution in Z"];

figure
for i=1:3
    subplot(1, 3, i)
    histfit(u(:, i), 20)
    title(titles(i))
    xlabel('Displacement (m)')
    grid on
end





