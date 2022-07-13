function [z, x] = calculateDeformation(fixturePos, drillPos)

model = createpde('structural', 'static-solid');
importGeometry(model, '../models/skin_panel.stl');
E = 210E9; nu = 0.3; rho = 8000; 
structuralProperties(model,'YoungsModulus',E, ... 
    'PoissonsRatio',nu, ... 
    'MassDensity',rho);

fixtureVertexID = addVertex(model.Geometry, 'Coordinates', fixturePos);
structuralBC(model,'Vertex',fixtureVertexID,'Constraint', 'fixed');
structuralBC(model,'Face',[1 3],'Constraint', 'fixed');

drillVertexID = addVertex(model.Geometry, "Coordinates", drillPos);

structuralBoundaryLoad(model, 'Vertex', drillVertexID, 'Force', @multiPointForce);
generateMesh(model);

structuralResults = solve(model);

z = structuralResults.Displacement.z;
x = structuralResults.Displacement.x;

end